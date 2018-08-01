<#
    .Synopsis

        This processes the STDOUT from `quser.exe` and returns an object.

    .Parameter QuserOutput

        This is the STDOUT as returned by `quser.exe`.
#>
function ConvertTo-QuserObject {
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param(
        [Parameter(
            ValueFromPipeline = $true,
            Mandatory = $true
        )]
        [hashtable]
        $QuserOutput
    )

    begin {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Begin Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Begin Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"
        $headerDone = $false
    }

    process {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        if ($script:Culture.Parent.Name -and $script:Culture.Parent -eq 'es') {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Culture Adjustements: ${script:Culture}"
            $QuserOutput.Result[0] = $QuserOutput.Result[0].Replace('.', ' ')
        }

        Write-Debug "[QuserObject ConvertTo-QuserObject] QuserOutput.Result: $($QuserOutput.Result | Out-String)"

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
            if (-not $headerDone) {
                Write-Debug "[QuserObject ConvertTo-QuserObject] Skipping Header Row"
                $headerDone = $true
            } else {
                # IdleTime
                $getQuserIdleTime = @{
                    QuserIdleTime = $rowParts[4]
                    AsDateTime    = $script:IdleStartTime
                }

                Write-Debug "[QuserObject ConvertTo-QuserObject] Processed Row: $($rowParts -join ',') "
                Write-Debug "[QuserObject ConvertTo-QuserObject] Pre Output ($(($_ | Measure-Object).Count)): $($_ | Out-String)"

                $output = @{}

                Write-Debug "[QuserObject ConvertTo-QuserObject] Server: $($QuserOutput.Server)"
                $output.Add('Server',      ($QuserOutput.Server))

                Write-Debug "[QuserObject ConvertTo-QuserObject] Username: $(([string] $rowParts[0]))"
                $output.Add('Username',    ([string] $rowParts[0]))

                Write-Debug "[QuserObject ConvertTo-QuserObject] Sessionname: $(([string] $rowParts[1]))"
                $output.Add('Sessionname', ([string] $rowParts[1]))

                Write-Debug "[QuserObject ConvertTo-QuserObject] Id: $(([int] $rowParts[2]))"
                $output.Add('Id',          ([int] $rowParts[2]))

                Write-Debug "[QuserObject ConvertTo-QuserObject] State: $(([string] $rowparts[3]))"
                $output.Add('State',       ([string] $rowparts[3]))

                $quserIdleTime = Get-QuserIdleTime @getQuserIdleTime
                Write-Debug "[QuserObject ConvertTo-QuserObject] IdleTime: ${quserIdleTime}"
                $output.Add('IdleTime',    $quserIdleTime)

                Write-Debug "[QuserObject ConvertTo-QuserObject] LogonTime: $(([DateTime] $rowparts[5]))"
                $output.Add('LogonTime',   ([DateTime] $rowparts[5]))

                $newObject = New-Object PSObject -Property $output
                $newObject.PSTypeNames.Insert(0, 'QuserObject')
                Write-Debug "[QuserObject ConvertTo-QuserObject] Output ($(($_ | Measure-Object).Count)): $($output | Out-String)"
                Write-Output $newObject
            }
        }
    }
}
