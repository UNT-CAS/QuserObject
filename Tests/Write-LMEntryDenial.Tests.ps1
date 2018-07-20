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
            [IO.FileInfo] $csvFilePath = '{0}\{1}.csv' -f $lmEntry.QuserObject.DirectoryPath, $lmEntry.ProcessName
            
            if ($test.ExistingCsv) {
                New-Item -ItemType File -Path $csvFilePath -Force
                $csvFilePathShouldInitiallyExist = $true

                if ($test.ExistingCsv -is [string]) {
                    $test.ExistingCsv | Out-File -Encoding ascii -LiteralPath $csvFilePath
                }
            } else {
                $csvFilePathShouldInitiallyExist = $false
            }
            
            It "Confirm CSV exists (${csvFilePathShouldInitiallyExist}): ${csvFilePath}" {
                Test-Path $csvFilePath | Should Be $csvFilePathShouldInitiallyExist
            }
    
            It "Write-LMEntryDenial" {
                { Write-LMEntryDenial @lmEntry } | Should Not Throw
            }

            It "Confirm CSV exists (True): ${csvFilePath}" {
                Test-Path $csvFilePath | Should Be $true
            }

            $confirmCsv = Import-Csv -LiteralPath $csvFilePath
            $expectedCsv = ($test.ExpectedCsv -f $env:ComputerName, (Get-Date (Get-Date).AddMinutes(-1) -Format 'O')) | ConvertFrom-Csv

            It "CSVs Should Be Same Length" {
                ($confirmCsv | Measure-Object).Count | Should Be ($expectedCsv | Measure-Object).Count
            }

            [System.Collections.ArrayList] $testCases = @()
            foreach ($item in $expectedCsv[-1].PSObject.Properties) {
                $testCases.Add(@{
                    Name = $item.Name
                    Actual = $confirmCsv[-1].$($item.Name)
                    Expected = $item.Value
                })
            }

            It "Last Objects Should Be The Same: <Name>" -TestCases $testCases {
                param(
                    [Parameter()]    
                    [string]
                    $Name,
                    
                    [Parameter()]
                    [string]
                    $Actual,
                    
                    [Parameter()]
                    [string]
                    $Expected
                )

                if ($Name -eq 'Timestamp') {
                    Get-Date $Actual | Should BeGreaterThan (Get-Date $Expected)
                } else {
                    $Actual | Should Be $Expected
                }
            }
            
            Write-Verbose "Removing temp JSON file."
            Remove-Item -LiteralPath $csvFilePath -Force -ErrorAction SilentlyContinue
        }
    }
}