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
        Remove-Variable -Scope 'Script' -Name 'quserOutput' -Force -ErrorAction SilentlyContinue

        Context $test.Name {
            [hashtable] $parameters = $test.Parameters

            if ($test.ServerExists) {
                It "Invoke-Quser" {
                    { $script:quserOutput = Invoke-Quser @parameters } | Should Not Throw
                }

                It "Validate output is like CSV" {
                    { $script:quserOutput -replace '\s{2,}', ',' | ConvertFrom-Csv } | Should Not Throw
                }
            } else {
                It "Invoke-Quser" {
                    { $script:quserOutput = Invoke-Quser @parameters } | Should Not Throw
                }

                It "Validate output is null" {
                    $script:quserOutput | Should BeNullOrEmpty
                }
            }
        }
    }
}