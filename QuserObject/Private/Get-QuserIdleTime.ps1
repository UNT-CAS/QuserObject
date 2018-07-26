<#
    .Synopsis

        This is the MAIN script. This script watches for events and sends found events to Invoke-LMEvent for handling.

    .Parameter QuserIdleTime

        The idle time, as returned by Quser.

    .Parameter AsDateTime

        Return as [datetime] instead of [timespan].
#>
function Get-QuserIdleTime {
    [CmdletBinding()]
    [OutputType([timespan])]
    [OutputType([datetime])]
    [OutputType([void])]
    Param(
        [Parameter(Mandatory = $true)]
        [string]
        $QuserIdleTime,

        [Parameter()]
        [switch]
        $AsDateTime
    )

    $QuserIdleTime = $QuserIdleTime.Replace('+', '.')

    if ($QuserIdleTime -as [int]) {
        $QuserIdleTime = "0:${QuserIdleTime}"
    }

    if ($QuserIdleTime -as [timespan]) {
        [timespan] $idleTime = $QuserIdleTime

        if ($AsDateTime.IsPresent) {
            $now = Get-Date
            return $now.Subtract($idleTime)
        } else {
            return $idleTime
        }
    } else {
        return $null
    }
}