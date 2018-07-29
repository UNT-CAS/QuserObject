<#
    .Synopsis

        Invoke `quser.exe` on the localhost or the target system.

    .Parameter Server

        A server to target. No validation or reachability testing is done.
#>
function Invoke-Quser {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]
        $Server
    )

    begin {
        Write-Debug "[QuserObject Invoke-Quser] Begin Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Invoke-Quser] Begin Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"
    }

    process {
        Write-Debug "[QuserObject Invoke-Quser] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Invoke-Quser] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        $quser = '{0} /SERVER:{1}' -f (Get-Command 'quser').Path, $Server
        Write-Debug "[QuserObject Invoke-Quser] QUSER Command: ${quser}"

        if ((Get-Culture) -ne 'en-US') {
            $currentCulture = Get-Culture
            Set-Culture -CultureInfo 'en-US'
        }

        try {
            $result = (Invoke-Expression $quser) 2>&1
        } catch {
            $result = $Error[0].Exception.Message
        }
        Write-Verbose "[QuserObject Invoke-Quser] QUSER Result (ExitCode: ${LASTEXITCODE}):`n$($result | Out-String)"

        if ($currentCulture) {
            $currentCulture | Set-Culture
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Output @{
                Server = $Server
                Result       = $result
            }
        } else {
            $message = if ($result.Exception) { $result.Exception.Message } else { $result }
            Write-Warning " ${Server}: $($message -join ', ')"
        }
    }
}
