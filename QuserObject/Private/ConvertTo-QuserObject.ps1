<#
    .Synopsis

        This is the MAIN script. This script watches for events and sends found events to Invoke-LMEvent for handling.

    .Parameter LicenseManager

        A JSON hashtable of processes to concurrency maximum.
        Example: '{"DirectoryPath":"\\\\license\\LicenseManager","Processes":{"notepad.exe":5,"Calculator.exe":10}}'
        Done this way so we can use the default of setting this as an Environment Variable for the system. Here's the example, but a little easier to read:
            {
                "DirectoryPath":  "\\\\license\\LicenseManager",
                "Processes":  {
                                "notepad.exe":  5,
                                "Calculator.exe":  10
                            }
            }
        The number with the process name is the concurrency count.
#>
function ConvertTo-QuserObject {
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param(
        [Parameter(ValueFromPipeline, Mandatory = $true)]
        [string[]]
        $QuserOutput
    )

    begin {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Bound Parameters: $($MyInvocation.BoundParameters | Out-String)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Unbound Parameters: $($MyInvocation.UnboundParameters | Out-String)"
    }

    process {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Pipeline Bound Parameters: $($MyInvocation.BoundParameters | Out-String)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Pipeline Unbound Parameters: $($MyInvocation.UnboundParameters | Out-String)"

        $headerRowProcessed = $false
        ((($QuserOutput) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object {
            if ($_.Split(',').Count -eq 5) {
                Write-Output ($_ -replace '(^[^,]+)', '$1,')
            } else {
                Write-Output $_
            }
        } | ForEach-Object {
            $rowParts = $_.Split(',')
            if (-not $headerRowProcessed) {
                [System.Collections.ArrayList] $parts = @()
                foreach ($part in $rowParts) {
                    $parts.Add((Get-Culture).TextInfo.ToTitleCase($part.ToLower()).Replace(' ', '')) | Out-Null
                }
                Write-Output ($parts -join ',')
                $headerRowProcessed = $true
            }
            else {
                [int] $rowParts[2] = $rowParts[2]

                if ($rowParts[3] -eq 'Disc') {
                    $rowParts[3] = 'Disconnected'
                }

                if ($rowParts[4] -eq '.') {
                    $rowParts[4] = $null
                } else {
                    $parts = $rowParts[4].Split('+:')
                    $now = Get-Date
                    if ($parts.Count -eq 3) {
                        $rowParts[4] = $now.AddDays(-1 * $parts[0]).AddMinutes(-1 * $parts[1]).AddSeconds(-1 * $parts[2])
                    }
                    else {
                        $rowParts[4] = $now.AddMinutes(-1 * $parts[0]).AddSeconds(-1 * $parts[1])
                    }
                }

                $rowParts[5] = Get-Date $rowParts[5]

                Write-Output ($rowParts -join ',')
            }
        } | ConvertFrom-Csv
    }
}