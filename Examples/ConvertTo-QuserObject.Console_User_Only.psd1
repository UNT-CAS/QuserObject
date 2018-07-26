@{
    Parameters = @{
        QuserOutput = @{
            Server = 'localhost'
            Result = @(
                'USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME',
                '>vertigoray            console             1  Active      none   7/13/2018 11:26 AM'
            )
        }
    }
    Output = @(
        @{
            Server      = 'localhost'
            Username    = 'vertigoray'
            Sessionname = 'console'
            Id          = 1
            State       = 'Active'
            IdleTime    = @{
                Type        = 'System.Void'
                Value       = $null
            }
            LogonTime   = @{
                Type        = 'System.DateTime'
                Value       = '07/13/2018 11:26:00'
            }
        }
    )
}