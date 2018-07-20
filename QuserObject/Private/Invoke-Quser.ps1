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
        Write-Debug "[QuserObject Invoke-Quser] Bound Parameters: $($MyInvocation.BoundParameters | Out-String)"
        Write-Debug "[QuserObject Invoke-Quser] Unbound Parameters: $($MyInvocation.UnboundParameters | Out-String)"
    }

    process {
        Write-Debug "[QuserObject Invoke-Quser] Pipeline Bound Parameters: $($MyInvocation.BoundParameters | Out-String)"
        Write-Debug "[QuserObject Invoke-Quser] Pipeline Unbound Parameters: $($MyInvocation.UnboundParameters | Out-String)"

        $quser = if ($Server) { '{0} /SERVER:{1}' -f (Get-Command 'quser').Path, $_ } else { (Get-Command 'quser').Path }
        Write-Debug "[QuserObject Invoke-Quser] QUSER Command: ${quser}"

        $result = & $quser
        Write-Verbose "[QuserObject Invoke-Quser] QUSER Result (${LASTEXITCODE}):`n$($result | Out-String)"

        if ($LASTEXITCODE -eq 0) {
            Write-Output $result
        } else {
            Throw [System.Management.Automation.ParameterBindingException] ('{0}: {1}' -f $Server, $Error[0].Exception.Message)
        }
    }
}
