<#
    .Synopsis

        This processes the STDOUT from `quser.exe` and returns an object.

    .Parameter QuserOutput

        A hashtable of the target server and the STDOUT (Result) as returned by `quser.exe`.
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
    }

    process {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        Write-Debug "[QuserObject ConvertTo-QuserObject] Culture ($(Get-Culture)) DateTime Format: $((Get-Culture).DateTimeFormat.ShortDatePattern)"
        if ((Get-Culture).Parent.Name -eq 'es') {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Culture Adjustments: ${script:Culture}"
            $QuserOutput.Result[0] = $QuserOutput.Result[0].Replace('.', ' ')
        }

        Write-Debug "[QuserObject ConvertTo-QuserObject] QuserOutput.Result:`n$($QuserOutput.Result | Out-String)"
        
        $quserRows = $QuserOutput.Result
        $headerRow = $quserRows[0]
        Write-Debug "[QuserObject ConvertTo-QuserObject] Header:`n$($headerRow | Out-String)"
        
        $match = [regex]::Match($headerRow, '(\s{2,})')
        $usernameSize = @(
            0,
            ($match.Index + $match.Length)
        )
        Write-Debug "[QuserObject ConvertTo-QuserObject] UserName Size: ${usernameSize}"
        
        foreach ($row in $quserRows[1..$quserRows.GetUpperBound(0)]) {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Process Row [$($row.GetType())]: ${row}"
            
            $rowUserName = $row.Substring($usernameSize[0], $usernameSize[1])
            Write-Debug "[QuserObject ConvertTo-QuserObject] Row UserName: $rowUserName"
            
            $restOfRow = $row.Substring($usernameSize[1]).Trim()
            Write-Debug "[QuserObject ConvertTo-QuserObject] Rest of Row [$($row.GetType())]: ${restOfRow}"

            [Collections.ArrayList] $rowSplit = $restOfRow -split '\s{2,}'
            Write-Debug "[QuserObject ConvertTo-QuserObject] Process RowSplit [$($rowSplit.GetType())]:`n$($rowSplit | Out-String)"


            if ($rowSplit.Count -eq 4) {
                # SessionName appears to be blank
                $rowSplit.Insert(0, '')
                Write-Debug "[QuserObject ConvertTo-QuserObject] Process RowSplit FIXED [$($rowSplit.GetType())]:`n$($rowSplit | Out-String)"
            }
            
            $getQuserIdleTime = @{
                QuserIdleTime = $rowSplit[3]
                AsDateTime    = $script:IdleStartTime
            }
            Write-Debug "[QuserObject ConvertTo-QuserObject] QuserIdleTime Splat:`n$($getQuserIdleTime | Out-String)"
            
            $quser = @{
                IsCurrentSession = $rowUserName.StartsWith('>')
                UserName = $rowUserName.TrimStart('>').Trim()
                SessionName = $rowSplit[0]
                Id = $rowSplit[1] -as [int]
                State = $rowSplit[2]
                IdleTime = (Get-QuserIdleTime @getQuserIdleTime)
                LogonTime = (Get-Date $rowSplit[4])
                Server = $QuserOutput.Server
            }
            Write-Debug "[QuserObject ConvertTo-QuserObject] Row Parsed:`n$($quser | Out-String)"
            
            $quserObject = New-Object PSObject -Property $quser
            Write-Debug "[QuserObject ConvertTo-QuserObject] QuserObject:`n$($quserObject | Out-String)"
            
            $quserObject.PSTypeNames.Insert(0, 'QuserObject')
            Write-Debug "[QuserObject ConvertTo-QuserObject] QuserObject Types:`n$($quserObject.PSTypeNames | Out-String)"

            Write-Output $quserObject
        }
    }
}