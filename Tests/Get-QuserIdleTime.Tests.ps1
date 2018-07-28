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
            <#
                Only Mock if no parameters are supplied.
                We're mocking `$now = Get-Date`
            #>
            return ([System.DateTime] $test.GetDateNow)
        } -ParameterFilter { (-not ($MyInvocation.BoundParameters | Out-String).Trim()) -and (-not ($MyInvocation.UnboundParameters | Out-String).Trim()) }

        Remove-Variable -Scope 'Script' -Name 'idleTime' -Force -ErrorAction SilentlyContinue

        Context $test.Name {
            [hashtable] $parameters = $test.Parameters

            It "Get-QuserIdleTime" {
                { $script:idleTime = Get-QuserIdleTime @parameters } | Should Not Throw
            }

            It "Output Type: $($test.Output.Type)" {
                if ($test.Output.Type -eq 'System.Void') {
                    $script:idleTime | Should BeNullOrEmpty
                } else {
                    $script:idleTime | Should BeOfType $test.Output.Type
                }
            }

            It "Output Value: $($test.Output.Value)" {
                $script:idleTime | Should Be ($test.Output.Value -as ($test.Output.Type -as [type]))
            }
        }
    }
}