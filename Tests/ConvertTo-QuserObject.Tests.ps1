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
        $test.Add($exampleData.Name, $exampleData.Value)
    }
    
    Write-Verbose "Test: $($test | ConvertTo-Json)"
    $tests.Add($test) | Out-Null
}

Describe $testFile.Name {
    foreach ($test in $tests) {
        Mock Get-Date {
            # Write-Verbose "MOCK: Get-Date" -Verbose
            # Write-Verbose "BoundParameters: $($MyInvocation.BoundParameters | Out-String)" -Verbose
            # Write-Verbose "UnboundParameters: $($MyInvocation.UnboundParameters | Out-String)" -Verbose
            return ([System.DateTime] $test.GetDateNow)
        } -ParameterFilter { (-not ($MyInvocation.BoundParameters | Out-String).Trim()) -and (-not ($MyInvocation.UnboundParameters | Out-String).Trim()) }

        Context $test.Name {
            [hashtable] $parameters = $test.Parameters

            It "ConvertTo-QuserObject Parameter" {
                # $DebugPreference = 'Continue'
                { $script:results = ConvertTo-QuserObject @parameters } | Should Not Throw
            }
            # Write-Host "script:Result $(($script:results | Measure-Object).Count): $($script:results | Out-String)"

            for ($i = 0; $i -lt ($test.Output | Measure-Object).Count; $i++) {
                $result = if (($script:results | Measure-Object).Count -gt 1) { $script:results[$i] } else { $script:results }
                $testOutput = if (($test.Output | Measure-Object).Count -gt 1) { $test.Output[$i] } else { $test.Output }
                # Write-Host "Result: $($result | Out-String)"

                It "${i} Username Type: String" {
                    $result.Username | Should BeOfType 'System.String'
                }

                It "${i} Username: $($testOutput.Username)" {
                    $result.Username | Should Be $testOutput.Username
                }

                It "${i} Sessionname Type: String" {
                    $result.Sessionname | Should BeOfType 'System.String'
                }

                It "${i} Sessionname: $($testOutput.Sessionname)" {
                    $result.Sessionname | Should Be $testOutput.Sessionname
                }

                It "${i} Id Type: Int32" {
                    $result.Id | Should BeOfType 'System.Int32'
                }

                It "${i} Id: $($testOutput.Id)" {
                    $result.Id | Should Be $testOutput.Id
                }

                It "${i} State Type: String" {
                    $result.State | Should BeOfType 'System.String'
                }

                It "${i} State Set: Active, Disconnected" {
                    $result.State | Should BeIn @('Active', 'Disconnected')
                }

                It "${i} State: $($testOutput.State)" {
                    $result.State | Should Be $testOutput.State
                }

                if (-not $testOutput.IdleTime) {
                    It "${i} IdleTime Type: Null" {
                        $result.IdleTime | Should BeNullOrEmpty
                    }
                } else {
                    It "${i} IdleTime Type: DateTime" {
                        $result.IdleTime | Should BeOfType 'System.DateTime'
                    }
                }
    
                It "${i} IdleTime: $($testOutput.IdleTime)" {
                    $result.IdleTime | Should Be $testOutput.IdleTime
                }

                It "${i} LogonTime Type: DateTime" {
                    $result.LogonTime | Should BeOfType 'System.DateTime'
                }

                It "${i} LogonTime: $($testOutput.LogonTime)" {
                    $result.LogonTime | Should Be $testOutput.LogonTime
                }
            }

            It "ConvertTo-QuserObject Pipeline" {
                { $script:results = $parameters.QuserOutput | ConvertTo-QuserObject } | Should Not Throw
            }
            # Write-Host "script:Result: $($script:result | Out-String)"

           for ($i = 0; $i -lt ($test.Output | Measure-Object).Count; $i++) {
                $result = if (($script:results | Measure-Object).Count -gt 1) { $script:results[$i] } else { $script:results }
                $testOutput = if (($test.Output | Measure-Object).Count -gt 1) { $test.Output[$i] } else { $test.Output }
                # Write-Host "Result: $($result | Out-String)"

                It "${i} Username Type: String" {
                    $result.Username | Should BeOfType 'System.String'
                }

                It "${i} Username: $($testOutput.Username)" {
                    $result.Username | Should Be $testOutput.Username
                }

                It "${i} Sessionname Type: String" {
                    $result.Sessionname | Should BeOfType 'System.String'
                }

                It "${i} Sessionname: $($testOutput.Sessionname)" {
                    $result.Sessionname | Should Be $testOutput.Sessionname
                }

                It "${i} Id Type: Int32" {
                    $result.Id | Should BeOfType 'System.Int32'
                }

                It "${i} Id: $($testOutput.Id)" {
                    $result.Id | Should Be $testOutput.Id
                }

                It "${i} State Type: String" {
                    $result.State | Should BeOfType 'System.String'
                }

                It "${i} State Set: Active, Disconnected" {
                    $result.State | Should BeIn @('Active', 'Disconnected')
                }

                It "${i} State: $($testOutput.State)" {
                    $result.State | Should Be $testOutput.State
                }

                if (-not $testOutput.IdleTime) {
                    It "${i} IdleTime Type: Null" {
                        $result.IdleTime | Should BeNullOrEmpty
                    }
                } else {
                    It "${i} IdleTime Type: DateTime" {
                        $result.IdleTime | Should BeOfType 'System.DateTime'
                    }
                }
    
                It "${i} IdleTime: $($testOutput.IdleTime)" {
                    $result.IdleTime | Should Be $testOutput.IdleTime
                }

                It "${i} LogonTime Type: DateTime" {
                    $result.LogonTime | Should BeOfType 'System.DateTime'
                }

                It "${i} LogonTime: $($testOutput.LogonTime)" {
                    $result.LogonTime | Should Be $testOutput.LogonTime
                }
            }
        }
    }
}