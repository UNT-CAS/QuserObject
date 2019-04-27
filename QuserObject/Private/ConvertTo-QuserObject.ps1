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
        $headerDone = $false
    }

    process {
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Bound Parameters: $($MyInvocation.BoundParameters | ConvertTo-Json)"
        Write-Debug "[QuserObject ConvertTo-QuserObject] Process Unbound Parameters: $($MyInvocation.UnboundParameters | ConvertTo-Json)"

        Write-Debug "[QuserObject ConvertTo-QuserObject] Culture ($(Get-Culture)) DateTime Format: $((Get-Culture).DateTimeFormat.ShortDatePattern)"
        if ((Get-Culture).Parent.Name -eq 'es') {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Culture Adjustments: ${script:Culture}"
            $QuserOutput.Result[0] = $QuserOutput.Result[0].Replace('.', ' ')
        }

        Write-Debug "[QuserObject ConvertTo-QuserObject] QuserOutput.Result: $($QuserOutput.Result | Out-String)"

        $quserCsv = (($QuserOutput.Result) -replace '\s{2,}', ',').Trim() | ForEach-Object {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Add Comma, if needed: $_"
            if ($_.Split(',').Count -eq 5) {
                Write-Output ($_ -replace '(^[^,]+)', '$1,')
            } else {
                Write-Output $_
            }
        }

        $quserCsvHeader = $quserCSV[0].Split(',').Trim()
        Write-Debug "[QuserObject ConvertTo-QuserObject] Header Row: $($userCsvHeader -join ', ')"

        $quserObj = $quserCsv | ConvertFrom-Csv

        if (($quserObj | Measure-Object).Count -eq 1) {
            $quserObj = ,$quserObj
        }
        
        foreach ($row in $quserObj) {
            Write-Debug "[QuserObject ConvertTo-QuserObject] Process Row: ${row}"

            # IdleTime
            $getQuserIdleTime = @{
                QuserIdleTime = $row.($quserCsvHeader[4])
                AsDateTime    = $script:IdleStartTime
            }

            Write-Debug "[QuserObject ConvertTo-QuserObject] Processing Row: $($row | Out-String) "
            Write-Debug "[QuserObject ConvertTo-QuserObject] Pre Output ($(($row | Measure-Object).Count)): $($row | Out-String)"

            $output = @{}

            Write-Debug "[QuserObject ConvertTo-QuserObject] Server: $($QuserOutput.Server)"
            $output.Add('Server',      ($QuserOutput.Server))

            Write-Debug "[QuserObject ConvertTo-QuserObject] Username: $(([string] $row.($quserCsvHeader[0])))"
            [string] $username = $row.($quserCsvHeader[0])

            if ($username.StartsWith('>')) {
                $output.Add('Username', $username.Substring(1))
                $output.Add('IsCurrentSession', $true)
            } else {
                $output.Add('Username', $username)
            }
            
            Write-Debug "[QuserObject ConvertTo-QuserObject] Sessionname: $(([string] $row.($quserCsvHeader[1])))"
            $output.Add('Sessionname', ([string] $row.($quserCsvHeader[1])))

            Write-Debug "[QuserObject ConvertTo-QuserObject] Id: $(([int] $row.($quserCsvHeader[2])))"
            $output.Add('Id', ([int] $row.($quserCsvHeader[2])))

            Write-Debug "[QuserObject ConvertTo-QuserObject] State: $(([string] $row.($quserCsvHeader[3])))"
            $output.Add('State', ([string] $row.($quserCsvHeader[3])))

            $quserIdleTime = Get-QuserIdleTime @getQuserIdleTime
            Write-Debug "[QuserObject ConvertTo-QuserObject] IdleTime: ${quserIdleTime}"
            $output.Add('IdleTime', $quserIdleTime)

            Write-Debug "[QuserObject ConvertTo-QuserObject] LogonTime: $(Get-Date $row.($quserCsvHeader[5]))"
            $output.Add('LogonTime', (Get-Date $row.($quserCsvHeader[5])))

            $newObject = New-Object PSObject -Property $output
            $newObject.PSTypeNames.Insert(0, 'QuserObject')
            Write-Debug "[QuserObject ConvertTo-QuserObject] Output ($(($row | Measure-Object).Count)): $($output | Out-String)"
            Write-Output $newObject
        }
    }
}
