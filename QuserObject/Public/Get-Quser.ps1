<#
    .Synopsis

        Invoke the `quser.exe` and return a PSObject.

    .Parameter ServerName

        The server to be queried. Default is current.

    .Parameter ADComputer
    
        The AD computer object of the server to be queried.

    .Parameter Property

        When working with an AD computer object, you can specify which AD property to target as the ServerName. 
        
        Default is "Name", but you might want to change it to something like "DNSHostName".

    .Example

        Get-QuserObject

    .Example

        Get-QuserObject -ServerName 'ThisServer'

    .Example

        Get-QuserObject -ServerName 'ThisServer', 'ThatServer'

    .Example

        Get-ADComputer 'ThisServer' | Get-QuserObject
#>
function Get-Quser {
    [CmdletBinding(DefaultParameterSetName = 'ServerName')]
    [OutputType([PSObject])]
    Param(
        [Parameter(
            ParameterSetName = 'ServerName',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('__ServerName', 'Server', 'Computer', 'Name')]
        [string[]]
        $ServerName,

        [Parameter(
            ParameterSetName = 'ADComputer',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $ADComputer,

        [Parameter(ParameterSetName = 'ADComputer')]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Property = 'Name'
    )

    begin {
        Write-Debug "[QuserObject Get-QuserObject] Begin Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Get-QuserObject] Begin Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"
    }

    process {
        Write-Debug "[QuserObject Get-QuserObject] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject Get-QuserObject] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        if ($ServerName) {
            $ServerName | Invoke-Quser | ConvertTo-QuserObject
        } elseif ($ADComputer) {
            $ADComputer.$Property | Invoke-Quser | ConvertTo-QuserObject
        } else {
            Invoke-Quser | ConvertTo-QuserObject
        }
    }
}