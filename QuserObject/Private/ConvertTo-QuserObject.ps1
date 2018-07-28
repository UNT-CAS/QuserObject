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
        [string] $header = ''
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
            if (-not $header) {
                [System.Collections.ArrayList] $parts = @()
                foreach ($part in $rowParts) {
                    $parts.Add($script:Culture.TextInfo.ToTitleCase($part.ToLower()).Replace(' ', '')) | Out-Null
                }
                $header = ($parts -join ',')
                Write-Debug "[QuserObject ConvertTo-QuserObject] Processed Header Row"
            } else {
                # IdleTime
                $getQuserIdleTime = @{
                    QuserIdleTime = $rowParts[4]
                    AsDateTime    = $script:IdleStartTime
                }

                Write-Debug "[QuserObject ConvertTo-QuserObject] Processed Row: $($rowParts -join ',') "

                @($header, ($rowParts -join ',')) | ConvertFrom-Csv | ForEach-Object {
                    Write-Debug "[QuserObject ConvertTo-QuserObject] Pre Output ($(($_ | Measure-Object).Count)): $($_ | Out-String)"

                    $output = @{}

                    Write-Debug "[QuserObject ConvertTo-QuserObject] Server ($($script:CultureText.Server)): $($QuserOutput.Server)"
                    $output.Add('Server',      ($QuserOutput.Server))

                    Write-Debug "[QuserObject ConvertTo-QuserObject] Username ($($script:CultureText.Username)): $(([string] $_.$($script:CultureText.Username)))"
                    $output.Add('Username',    ([string] $_.$($script:CultureText.Username)))

                    Write-Debug "[QuserObject ConvertTo-QuserObject] Sessionname ($($script:CultureText.Sessionname)): $(([string] $_.$($script:CultureText.Sessionname)))"
                    $output.Add('Sessionname', ([string] $_.$($script:CultureText.Sessionname)))

                    Write-Debug "[QuserObject ConvertTo-QuserObject] Id ($($script:CultureText.Id)): $(([int]    $_.$($script:CultureText.Id)))"
                    $output.Add('Id',          ([int]    $_.$($script:CultureText.Id)))

                    Write-Debug "[QuserObject ConvertTo-QuserObject] State ($($script:CultureText.State)): $(([string] $_.$($script:CultureText.State)))"
                    $output.Add('State',       ([string] $_.$($script:CultureText.State)))

                    $quserIdleTime = Get-QuserIdleTime @getQuserIdleTime
                    Write-Debug "[QuserObject ConvertTo-QuserObject] IdleTime ($($script:CultureText.IdleTime)): ${quserIdleTime}"
                    $output.Add('IdleTime',    $quserIdleTime)

                    Write-Debug "[QuserObject ConvertTo-QuserObject] LogonTime ($($script:CultureText.LogonTime)): $(([DateTime] $_.$($script:CultureText.LogonTime)))"
                    $output.Add('LogonTime',   ([DateTime] $_.$($script:CultureText.LogonTime)))

                    $newObject = New-Object PSObject -Property $output
                    $newObject.PSTypeNames.Insert(0, 'QuserObject')
                    Write-Debug "[QuserObject ConvertTo-QuserObject] Output ($(($_ | Measure-Object).Count)): $($output | Out-String)"
                    Write-Output $newObject
                }
            }
        }
    }
}