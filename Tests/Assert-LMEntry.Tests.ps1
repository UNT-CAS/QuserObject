[string]           $projectDirectoryName = 'QuserObject'
[IO.FileInfo]      $pesterFile = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.FileInfo]      $testFile = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
. $testFile

[System.Collections.ArrayList] $tests = @()
$examples = Get-ChildItem (Join-Path -Path $projectRoot -ChildPath 'Examples' -Resolve) -Filter "$($testFile.BaseName).*.psd1" -File

foreach ($example in $examples) {
    [hashtable] $test = @{
        Name = $example.BaseName.Replace("$($testFile.BaseName).$verb", '').Replace('_', ' ')
    }
    Write-Verbose "Test: $($test | ConvertTo-Json)"
    
    foreach ($exampleData in (Import-PowerShellDataFile -LiteralPath $example.FullName).GetEnumerator()) {
        if ($exampleData.Name -eq 'Parameters') {
            $exampleData.Value.QuserObject.DirectoryPath = $exampleData.Value.QuserObject.DirectoryPath.Replace('%ProjectRoot%', $projectRoot)
        }
        $test.Add($exampleData.Name, $exampleData.Value)
    }
    
    Write-Verbose "Test: $($test | ConvertTo-Json)"
    $tests.Add($test) | Out-Null
}

Describe $testFile.Name {
    foreach ($test in $tests) {
        Context $test.Name {
            [hashtable] $lmEntry = $test.Parameters
            [IO.FileInfo] $jsonFilePath = '{0}\{1}.json' -f $lmEntry.QuserObject.DirectoryPath, $lmEntry.ProcessName
            
            if ($test.ExistingJson) {
                Write-Verbose "Starting JSON required."
                New-Item -ItemType File -Path $jsonFilePath -Force
                $jsonFilePathShouldInitiallyExist = $true

                if ($test.ExistingJson -is [string]) {
                    $outJson = $test.ExistingJson.Replace('{0}', $env:ComputerName)
                    $outJson | Out-File -Encoding ascii -LiteralPath $jsonFilePath
                }

                $jsonPreSha512 = Get-FileHash -LiteralPath $jsonFilePath -Algorithm SHA512
            }
            else {
                Write-Verbose "Starting JSON NOT required."
                $jsonFilePathShouldInitiallyExist = $false
            }
    
            It "Confirm JSON exists (${jsonFilePathShouldInitiallyExist}): ${jsonFilePath}" {
                Test-Path $jsonFilePath | Should Be $jsonFilePathShouldInitiallyExist
            }
    
            It "Assert-LMEntry" {
                { $script:lmEntryAssertation = Assert-LMEntry @lmEntry } | Should Not Throw
            }
    
            It "Confirm JSON exists (${jsonFilePathShouldInitiallyExist}): ${jsonFilePath}" {
                Test-Path $jsonFilePath | Should Be $jsonFilePathShouldInitiallyExist
            }
    
            if (Test-Path $jsonFilePath) {
                It "Confirm JSON hasn't changed" {
                    (Get-FileHash -LiteralPath $jsonFilePath -Algorithm SHA512).Hash | Should Be $jsonPreSha512.Hash
                }
            }
            
            It "Process Allowed: $($test.ProcessAllowed)" {
                $script:lmEntryAssertation | Should Be $test.ProcessAllowed
            }
            
            if (Test-Path $jsonFilePath) {
                Write-Verbose "Removing temp JSON file."
                Remove-Item -LiteralPath $jsonFilePath -Force
            }
        }
    }
}