<#
    .Synopsis

        This is the MAIN script. This script watches for events and sends found events to Invoke-LMEvent for handling.

    .Parameter QuserOutput

        This is the STDOUT as returned by `quser.exe`.
#>
function ConvertTo-QuserObject {
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [hashtable]
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

        ((($QuserOutput.Result) -replace '^>', '') -replace '\s{2,}', ',').Trim() | ForEach-Object {
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

                # IdleTime
                $getQuserIdleTime = @{
                    QuserIdleTime = $rowParts[4]
                    AsDateTime    = $script:IdleStartTime
                }
                $rowParts[4] = Get-QuserIdleTime @getQuserIdleTime

                # LogonTime
                $rowParts[5] = Get-Date $rowParts[5]

                Write-Debug "[QuserObject ConvertTo-QuserObject] Processed Row: $($rowParts -join ',') "

                @($header, ($rowParts -join ',')) | ConvertFrom-Csv | ForEach-Object {
                    Write-Debug "[QuserObject ConvertTo-QuserObject] Pre Output ($(($_ | Measure-Object).Count)): $($_ | Out-String)"
                    $output = @{
                        Server        = $QuserOutput.Server
                        Username      = [string] $_.Username
                        Sessionname   = [string] $_.Sessionname
                        Id            = [int]    $_.Id
                        State         = [string] $_.State
                        IdleTime      = if (-not $_.IdleTime) { $null } else { Get-Date $_.IdleTime }
                        LogonTime     = Get-Date $_.LogonTime
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