[string]           $projectDirectoryName = 'QuserObject'
[IO.FileInfo]      $pesterFile           = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot          = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory     = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.FileInfo]      $testFile             = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
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
            } else {
                Write-Verbose "Starting JSON NOT required."
                $jsonFilePathShouldInitiallyExist = $false
            }
    
            It "Confirm JSON exists (${jsonFilePathShouldInitiallyExist}): ${jsonFilePath}" {
                Test-Path $jsonFilePath | Should Be $jsonFilePathShouldInitiallyExist
            }
    
            It "Add-LMEntry" {
                { Add-LMEntry @lmEntry } | Should Not Throw
            }
    
            It "Confirm JSON exists (True): ${jsonFilePath}" {
                Test-Path $jsonFilePath | Should Be $true
            }

            $jsonPostSha512 = Get-FileHash -LiteralPath $jsonFilePath -Algorithm SHA512

            if ($test.ExpectedJson) {
                $confirmJson = Get-Content $jsonFilePath | Out-String | ConvertFrom-Json
                $expectedJson = $test.ExpectedJson.Replace('{0}', $env:ComputerName).Replace('{1}', (Get-Date (Get-Date).AddMinutes(-1) -Format 'O')) | ConvertFrom-Json
    
                It "JSONs Should Be at least one item" {
                    ($confirmJson | Measure-Object).Count | Should BeGreaterThan 0
                }
    
                It "JSONs Should Be Same Length" {
                    ($confirmJson | Measure-Object).Count | Should Be ($expectedJson | Measure-Object).Count
                }
    
                $relevantConfirmJsonItem = $confirmJson | Where-Object { $_.ComputerName -eq $env:ComputerName }
                $relevantExpectedJsonItem = $expectedJson | Where-Object { $_.ComputerName -eq $env:ComputerName }
    
                It "Should be one relevant confirm JSON item." {
                    <#
                        If this test fails, ensure that only one addition is happening.
                        Check your JSON files to make sure the pester test is valid.
                        This is just a sanity check for the Pester Tests.
                    #>
                    ($relevantConfirmJsonItem | Measure-Object).Count | Should Be 1
                }
    
                It "Should be one relevant expected JSON item." {
                    <#
                        If this test fails, ensure that only one addition is happening.
                        Check your JSON files to make sure the pester test is valid.
                        This is just a sanity check for the Pester Tests.
                    #>
                    ($relevantExpectedJsonItem | Measure-Object).Count | Should Be 1
                }
    
                [System.Collections.ArrayList] $testCases = @()
                foreach ($item in $relevantExpectedJsonItem.PSObject.Properties) {
                    $testCases.Add(@{
                        Name     = $item.Name
                        Actual   = $relevantConfirmJsonItem.$($item.Name)
                        Expected = $item.Value
                    })
                }
    
                foreach ($testCase in $testCases) {
                    <#
                        Cannot use It's `-TestCases` parameter here because ProcessID has something NULL.
                        TestCases tries to validate and fails. /shrug
                    #>
                    It "Relevant Objects Should Be The Same: $($testCase.Name)" {
                        if ($testCase.Name -eq 'Timestamp') {
                            Get-Date $testCase.Actual | Should BeGreaterThan (Get-Date $testCase.Expected)
                        } elseif ($testCase.Name -eq 'ProcessId') {
                            Compare-Object $testCase.Actual $testCase.Expected | Should BeNullOrEmpty    
                        } else {
                            $testCase.Actual | Should Be $testCase.Expected
                        }
                    }
                }
            } else {
                It "JSONs Should not have changed" {
                    $jsonPreSha512.Hash | Should Be $jsonPostSha512.Hash
                }
            }
            
            Write-Verbose "Removing temp JSON file."
            Remove-Item -LiteralPath $jsonFilePath -Force
        }
    }
}