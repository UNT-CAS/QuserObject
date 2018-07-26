<#
    .Synopsis

        Invoke the `quser.exe` and return a PSObject.

    .Parameter Server

        The server to be queried. Default is current.

    .Parameter IdleStartTime

        By default, IdleTime is returned as a [timespan] making it consistent with the way quser.exe give the idle time.

        Setting this switch will return IdleTime as [datetime] of when idleness started.

    .Parameter AdComputer

        The AD computer object of the server to be queried.

    .Parameter Property

        When working with an AD computer object, you can specify which AD property to target as the Server. 

        Default is "Name", but you might want to change it to something like "DNSHostName".

    .Example

        Get-Quser

    .Example

        Get-Quser -Server 'ThisServer'

    .Example

        Get-Quser -Server 'ThisServer', 'ThatServer'

    .Example

        Get-ADComputer 'ThisServer' | Get-Quser
#>
function Get-Quser {
    [CmdletBinding(DefaultParameterSetName = 'Server')]
    [OutputType([PSObject])]
    Param(
        [Parameter(
            ParameterSetName = 'Server',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('__ServerName', 'ServerName', 'Computer', 'Name')]
        [string[]]
        $Server = 'localhost',

        [Parameter(ParameterSetName = 'Server')]
        [Parameter(ParameterSetName = 'AdComputer')]
        [switch]
        $IdleStartTime,

        [Parameter(
            ParameterSetName = 'AdComputer',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $AdComputer,

        [Parameter(ParameterSetName = 'AdComputer')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Property = 'Name'
    )

    begin {
        Write-Debug "[QuserObject Get-Quser] Begin Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Get-Quser] Begin Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        [boolean] $script:IdleStartTime = $IdleStartTime.IsPresent
    }

    process {
        Write-Debug "[QuserObject Get-Quser] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Get-Quser] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        if ($AdComputer) {
            $AdComputer.$Property | Invoke-Quser | ConvertTo-QuserObject
        } else {
            $Server | Invoke-Quser | ConvertTo-QuserObject
        }
    }
}