[string]           $projectDirectoryName = 'QuserObject'
[IO.FileInfo]      $pesterFile = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.FileInfo]      $testFile = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
. $testFile

function ConvertTo-HashtableFromPsobject {
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($object in $InputObject) { ConvertTo-HashtableFromPsobject $object }
            )

            Write-Output -NoEnumerate $collection
        } elseif ($InputObject -is [psobject]) {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-HashtableFromPsobject $property.Value
            }

            $hash
        } else {
            $InputObject
        }
    }
}

[System.Collections.ArrayList] $tests = @()
$examplesPsd1 = @( Get-ChildItem (Join-Path -Path $projectRoot -ChildPath 'Examples' -Resolve) -Filter "$($testFile.BaseName).*.psd1" -File )
$examplesJson = @( Get-ChildItem (Join-Path -Path $projectRoot -ChildPath 'Examples' -Resolve) -Filter "$($testFile.BaseName).*.json" -File )

foreach ($example in ($examplesPsd1 + $examplesJson)) {
    [hashtable] $test = @{
        Name = $example.BaseName.Replace("$($testFile.BaseName).$verb", '').Replace('_', ' ')
    }
    Write-Verbose "Test: $($test | ConvertTo-Json)"

    if ($example.Extension -eq '.psd1') {
        $exampleContents = Import-PowerShellDataFile -LiteralPath $example.FullName
    } else { # JSON
        $exampleContents = Get-Content -Path $example.FullName -Encoding UTF8 | Out-String | ConvertFrom-Json | ConvertTo-HashtableFromPsobject
    }

    foreach ($exampleData in $exampleContents.GetEnumerator()) {
        $test.Add($exampleData.Name, $exampleData.Value)
    }

    Write-Verbose "Test: $($test | ConvertTo-Json)"
    $tests.Add($test) | Out-Null
}

function Get-QuserIdleTime {
    Write-Warning "Shouldn't ever see this message. Created this function for mocking purposes"
}

Describe $testFile.Name {
    foreach ($test in $tests) {
        if (-not $test.Culture) {
            $test.Culture = 'en-US'
        }
        Write-Host "`tCulture: $(Get-Culture)" -ForegroundColor Cyan
        Write-Host "`tTest Culture: $($test.Culture)" -ForegroundColor Cyan
        
        if ((Get-Culture) -ne $test.Culture) {
            break
        }

        [hashtable] $parameters = $test.Parameters

        Context "$($test.Name) Parameters" {
            BeforeEach {
                Mock Get-QuserIdleTime {
                    return $null
                } -Verifiable
            }

            $script:results = $null

            It "ConvertTo-QuserObject Parameter" {
                # $DebugPreference = 'Continue'
                { $script:results = ConvertTo-QuserObject @parameters } | Should Not Throw
            }

            $times = ($test.Output | Measure-Object).Count

            It "${i} IdleTime: Assert-MockCalled Get-QuserIdleTime: ${times}" {
                Assert-MockCalled 'Get-QuserIdleTime' -Times $times -Exactly
            }
            # Write-Host "script:Result $(($script:results | Measure-Object).Count): $($script:results | Out-String)"

            for ($i = 0; $i -lt ($test.Output | Measure-Object).Count; $i++) {
                $result = if (($script:results | Measure-Object).Count -gt 1) { $script:results[$i] } else { $script:results }
                $testOutput = if (($test.Output | Measure-Object).Count -gt 1) { $test.Output[$i] } else { $test.Output }
                # Write-Host "Result: $($result | Out-String)"

                It "${i} Server Type: String" {
                    $result.Server | Should BeOfType 'System.String'
                }

                It "${i} Server: $($testOutput.Server)" {
                    $result.Server | Should Be $testOutput.Server
                }

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

                It "${i} State: $($testOutput.State)" {
                    $result.State | Should Be $testOutput.State
                }

                It "${i} LogonTime Type: $($testOutput.LogonTime.Type)" {
                    $result.LogonTime | Should BeOfType $testOutput.LogonTime.Type
                }

                It "${i} LogonTime: $($testOutput.LogonTime.Value)" {
                    $result.LogonTime | Should Be $testOutput.LogonTime.Value
                }
            }
        }

        Context "$($test.Name) Pipeline" {
            BeforeEach {
                Mock Get-QuserIdleTime {
                    return $null
                } -Verifiable
            }

            $script:results = $null

            It "ConvertTo-QuserObject Pipeline" {
                { $script:results = $parameters.QuserOutput | ConvertTo-QuserObject } | Should Not Throw
            }

            $times = ($test.Output | Measure-Object).Count

            It "${i} IdleTime: Assert-MockCalled Get-QuserIdleTime: ${times}" {
                Assert-MockCalled 'Get-QuserIdleTime' -Times $times -Exactly
            }

           for ($i = 0; $i -lt ($test.Output | Measure-Object).Count; $i++) {
                $result = if (($script:results | Measure-Object).Count -gt 1) { $script:results[$i] } else { $script:results }
                $testOutput = if (($test.Output | Measure-Object).Count -gt 1) { $test.Output[$i] } else { $test.Output }
                # Write-Host "Result: $($result | Out-String)"

                It "${i} Server Type: String" {
                    $result.Server | Should BeOfType 'System.String'
                }

                It "${i} Server: $($testOutput.Server)" {
                    $result.Server | Should Be $testOutput.Server
                }

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

                It "${i} State: $($testOutput.State)" {
                    $result.State | Should Be $testOutput.State
                }

                It "${i} LogonTime Type: $($testOutput.LogonTime.Type)" {
                    $result.LogonTime | Should BeOfType $testOutput.LogonTime.Type
                }

                It "${i} LogonTime: $($testOutput.LogonTime.Value)" {
                    $result.LogonTime | Should Be $testOutput.LogonTime.Value
                }
            }
        }
    }
}