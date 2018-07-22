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

        $quser = if ($Server) { '{0} /SERVER:{1}' -f (Get-Command 'quser').Path, $Server } else { (Get-Command 'quser').Path }
        Write-Debug "[QuserObject Invoke-Quser] QUSER Command: ${quser}"

        $result = (Invoke-Expression $quser) 2>&1
        Write-Verbose "[QuserObject Invoke-Quser] QUSER Result (${LASTEXITCODE}):`n$($result | Out-String)"

        if ($LASTEXITCODE -eq 0) {
            Write-Output $result
        } else {
            $message = if ($result.Exception) { $result.Exception.Message } else { $result }
            Write-Warning " ${Server}: $($message -join ', ')"
        }
    }
}
