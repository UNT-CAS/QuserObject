[string]           $projectDirectoryName = 'QuserObject'
[IO.FileInfo]      $pesterFile = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.FileInfo]      $testFile = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Public' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
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

function Invoke-Quser {
    Write-Warning "Shouldn't ever see this message. Created this function for mocking purposes"
}
function ConvertTo-QuserObject {
    Write-Warning "Shouldn't ever see this message. Created this function for mocking purposes"
}

Describe $testFile.Name {
    foreach ($test in $tests) {
        Mock Invoke-Quser {
            Write-Verbose "MOCK: Invoke-Quser: $($input | Out-String)"
            Write-Output $input
        } -Verifiable

        Mock ConvertTo-QuserObject {
            Write-Verbose "MOCK: ConvertTo-QuserObject: $($input | Out-String)"
            Write-Output $input
        } -Verifiable

        Context $test.Name {
            # $DebugPreference = 'Continue'
            if ($test.Parameters) {
                [hashtable] $parameters = $test.Parameters
                $serverNameCount = ($parameters.ServerName | Measure-Object).Count
                $times = if ($serverNameCount) { $serverNameCount } else { 1 }
    
                It "Get-Quser" {
                    { Get-Quser @parameters } | Should Not Throw
                }
            } elseif ($test.Pipeline) {
                [array] $pipeline = $test.Pipeline
                $serverNameCount = ($pipeline | Measure-Object).Count
                $times = if ($serverNameCount) { $serverNameCount } else { 1 }

                It "Get-Quser" {
                    { $pipeline | Get-Quser } | Should Not Throw
                }
            } elseif ($test.ADComputer) {
                $adComputer = Import-Clixml -LiteralPath (Join-Path -Path (Join-Path -Path $projectRoot -ChildPath 'Examples' -Resolve) -ChildPath $test.ADComputer -Resolve)
                $serverNameCount = ($adComputer | Measure-Object).Count
                $times = if ($serverNameCount) { $serverNameCount } else { 1 }
    
                It "Get-Quser" {
                    { $adComputer | Get-Quser } | Should Not Throw
                }
            }

            It 'Assert-VerifiableMock' {
                { Assert-VerifiableMock } | Should Not Throw
            }

            It "Assert-MockCalled Invoke-Quser: ${times}" {
                { Assert-MockCalled 'Invoke-Quser' -Times $times -Exactly } | Should Not Throw
            }

            It "Assert-MockCalled ConvertTo-QuserObject: ${times}" {
                { Assert-MockCalled 'ConvertTo-QuserObject' -Times $times -Exactly } | Should Not Throw
            }
        }
    }
}