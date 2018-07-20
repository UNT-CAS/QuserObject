[string]           $projectDirectoryName = 'QuserObject'
[IO.FileInfo]      $pesterFile = [io.fileinfo] ([string] (Resolve-Path -Path $MyInvocation.MyCommand.Path))
[IO.DirectoryInfo] $projectRoot = Split-Path -Parent $pesterFile.Directory
[IO.DirectoryInfo] $projectDirectory = Join-Path -Path $projectRoot -ChildPath $projectDirectoryName -Resolve
[IO.FileInfo]      $testFile = Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath ($pesterFile.Name -replace '\.Tests\.', '.')) -Resolve
. $testFile

. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Add-LMEntry.ps1') -Resolve)
. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Assert-LMEntry.ps1') -Resolve)
. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Remove-LMEntry.ps1') -Resolve)
. $(Join-Path -Path $projectDirectory -ChildPath (Join-Path -Path 'Private' -ChildPath 'Deny-LMEntry.ps1') -Resolve)

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
        Mock Add-LMEntry {
            Write-Host "Mocked Add-LMEntry" -ForegroundColor Cyan
        } -Verifiable
        Mock Assert-LMEntry {
            Write-Host "Mocked Assert-LMEntry" -ForegroundColor Cyan
            return $test.AssertReturns
        } -Verifiable
        Mock Remove-LMEntry {
            Write-Host "Mocked Remove-LMEntry" -ForegroundColor Cyan
        } -Verifiable
        Mock Deny-LMEntry {
            Write-Host "Mocked Deny-LMEntry" -ForegroundColor Cyan
        } -Verifiable
        Mock Get-Process {
            return @{
                UserName = 'Test\Pester'
            }
        }

        Context $test.Name {
            [hashtable] $lmEntry = $test.Parameters
            
            It "Invoke-LMEvent" {
                { Invoke-LMEvent @lmEntry } | Should Not Throw
            }
    
            if ($test.Parameters.Action -eq 'Start') {
                It "Was Called: Assert-LMEntry" {
                    Assert-MockCalled 'Assert-LMEntry' -Times 1 -Exactly
                }

                if ($test.AssertReturns) {
                    It "Was Called: Add-LMEntry" {
                        Assert-MockCalled 'Add-LMEntry' -Times 1 -Exactly
                    }
                } else {
                    It "Was Called: Deny-LMEntry" {
                        Assert-MockCalled 'Deny-LMEntry' -Times 1 -Exactly
                    }
                }
            } else { # Stop
                It "Was Called: Remove-LMEntry" {
                    Assert-MockCalled 'Remove-LMEntry' -Times 1 -Exactly
                }
            }
            
        }
    }
}