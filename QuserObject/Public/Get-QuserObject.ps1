<#
    .Synopsis

        This is the MAIN script. This script watches for events and sends found events to Invoke-LMEvent for handling.

    .Parameter LicenseManager

        A JSON hashtable of processes to concurrency maximum.
        Example: '{"DirectoryPath":"\\\\license\\LicenseManager","Processes":{"notepad.exe":5,"Calculator.exe":10}}'
        Done this way so we can use the default of setting this as an Environment Variable for the system. Here's the example, but a little easier to read:
            {
                "DirectoryPath":  "\\\\license\\LicenseManager",
                "Processes":  {
                                "notepad.exe":  5,
                                "Calculator.exe":  10
                            }
            }
        The number with the process name is the concurrency count.

    .Example

        Get-ADComputer 'TestComputer' | Get-QuserObject
#>
function Get-QuserObject {
    [CmdletBinding()]
    [OutputType([PSObject])]
    Param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $Name
    )

    begin {
        Write-Debug "[QuserObject Get-QuserObject] Bound Parameters: $($MyInvocation.BoundParameters | Out-String)"
        Write-Debug "[QuserObject Get-QuserObject] Unbound Parameters: $($MyInvocation.UnboundParameters | Out-String)"
    }

    process {
        Write-Debug "[QuserObject Get-QuserObject] Pipeline Bound Parameters: $($MyInvocation.BoundParameters | Out-String)"
        Write-Debug "[QuserObject Get-QuserObject] Pipeline Unbound Parameters: $($MyInvocation.UnboundParameters | Out-String)"

        if ($Name) {
            $Name | Invoke-Quser | ConvertTo-QuserObject
        } else {
            Invoke-Quser | ConvertTo-QuserObject
        }
    }
}

$VerbosePreference = 'continue'
$DebugPreference = 'continue'

$public = @( Get-ChildItem -Path "$(Split-Path $PSScriptRoot -Parent)\Public\*.ps1" -ErrorAction SilentlyContinue )
Write-Debug "Public functions:`n${public}"
$private = @( Get-ChildItem -Path "$(Split-Path $PSScriptRoot -Parent)\Private\*.ps1" -ErrorAction SilentlyContinue )
Write-Debug "Private functions:`n${private}"

foreach ($import in @($public + $private)) {
    Write-Debug "Importing function: $($import.FullName)"
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function: $($import.FullName): $_"
    }
}
Get-QuserObject