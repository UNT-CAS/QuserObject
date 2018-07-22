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
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string[]]
        $QuserOutput
    )

    begin {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Begin Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Begin Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"
        [string] $header = ''
    }

    process {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"
        
        ((($QuserOutput) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Add Comma, if needed: $_"
            if ($_.Split(',').Count -eq 5) {
                Write-Output ($_ -replace '(^[^,]+)', '$1,')
            } else {
                Write-Output $_
            }
        } | ForEach-Object {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Process Row: $_"
            $rowParts = $_.Split(',')
            if (-not $header) {
                [System.Collections.ArrayList] $parts = @()
                foreach ($part in $rowParts) {
                    $parts.Add((Get-Culture).TextInfo.ToTitleCase($part.ToLower()).Replace(' ', '')) | Out-Null
                }
                $header = ($parts -join ',')
                Write-Debug "[QuserObject ConvertTo-QuserObject] Processed Header Row"
            } else {
                # Id
                [int] $rowParts[2] = $rowParts[2]

                # State
                if ($rowParts[3] -eq 'Disc') {
                    $rowParts[3] = 'Disconnected'
                }

                # IdleTime
                if ($rowParts[4] -eq '.' -or $rowParts[4] -eq 'none') {
                    $rowParts[4] = $null
                } else {
                    $parts = $rowParts[4].Split('+:')
                    $now = Get-Date
                    if ($parts.Count -eq 3) {
                        $rowParts[4] = $now.AddDays(-1 * $parts[0]).AddMinutes(-1 * $parts[1]).AddSeconds(-1 * $parts[2])
                    } else {
                        $rowParts[4] = $now.AddMinutes(-1 * $parts[0]).AddSeconds(-1 * $parts[1])
                    }
                }

                # LogonTime
                $rowParts[5] = Get-Date $rowParts[5]

                Write-Debug "[QuserObject ConvertTo-QuserObject] Processed Row: $($rowParts -join ',') "

                @($header, ($rowParts -join ',')) | ConvertFrom-Csv | ForEach-Object {
                    Write-Debug "[QuserObject ConvertTo-QuserObject] Pre Output ($(($_ | Measure-Object).Count)): $($_ | Out-String)"
                    $output = @{
                        Username    = [string] $_.Username
                        Sessionname = [string] $_.Sessionname
                        Id          = [int]    $_.Id
                        State       = [string] $_.State
                        IdleTime    = if ($_.IdleTime -eq '') { $null } else { Get-Date $_.IdleTime }
                        LogonTime   = Get-Date $_.LogonTime
                    }

                    $newObject = New-Object PSObject -Property $output
                    $newObject.PSTypeNames.Insert(0, 'QuserObject')
                    Write-Debug "[QuserObject ConvertTo-QuserObject] Output ($(($_ | Measure-Object).Count)): $($output | Out-String)"
                    Write-Output $newObject
                }
            }
        }
    }
}