<#
    .Synopsis

        Invoke `quser.exe` on the localhost or the target system.

    .Parameter Server

        A server to target. No validation or reachability testing is done.

    .Parameter UserOrSession

        Optional username, sessionname, or sessionid to pass on to `quser.exe`.
#>
function Invoke-Quser {
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(ValueFromPipeline)]
        [string]
        $Server,

        [string]
        $UserOrSession = ''
    )

    begin {
        Write-Debug "[QuserObject Invoke-Quser] Begin Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Invoke-Quser] Begin Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"
    }

    process {
        Write-Debug "[QuserObject Invoke-Quser] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Invoke-Quser] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        if ($Server -eq 'localhost') {
            $cmd = '{0}{1}'
        } else {
            $cmd = '{0} {1} /SERVER:{2}'
        }

        try {
            $quserPath = (Get-Command 'quser.exe' -ErrorAction 'Stop').Path
        } catch {
            $quserPath = (Get-Command "$env:SystemRoot\SysNative\quser.exe" -ErrorAction 'Stop').Path
        }

        $quser = $cmd -f $quserPath, $UserOrSession, $Server
        Write-Debug "[QuserObject Invoke-Quser] QUSER Command: ${quser}"

        try {
            $result = (Invoke-Expression $quser) 2>&1
        } catch {
            $result = $Error[0].Exception.Message
        }
        Write-Verbose "[QuserObject Invoke-Quser] QUSER Result (ExitCode: ${LASTEXITCODE}):`n$($result | Out-String)"

        if ($LASTEXITCODE -eq 0) {
            Write-Output @{
                Server = $Server
                Result = $result
            }
        } else {
            $message = if ($result.Exception) { $result.Exception.Message } else { $result }
            Write-Warning " ${Server}: $($message -join ', ')"
        }
    }
}
