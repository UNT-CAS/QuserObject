@{
    Parameters = @{
        QuserOutput = @(
            'USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME',
            '>vertigoray            console             1  Active      none   7/13/2018 11:26 AM'
        )
    }
    GetDateNow = '2018-07-21T11:49:09.2879117-05:00'
    Output = @(
        @{
            Username    = 'vertigoray'
            Sessionname = 'console'
            Id          = 1
            State       = 'Active'
            IdleTime    = $null
            LogonTime   = '07/13/2018 11:26:00'
        }
    )
}