@{
    Parameters = @{
        QuserOutput = @{
            Server = 'localhost'
            Result = @(
                'USERNAME         SESSIONNAME  ID  STATE   IDLE TIME  LOGON TIME',
                ' admin.xxxxxxxx                2  Disc     15+15:12  7/20/2017 1:19 PM',
                ' admin.xxxxx      rdp-tcp#54   3  Active       1:39  7/21/2017 5:35 AM',
                ' xxxxxxxx                      4  Disc      6+04:10  7/21/2017 9:25 AM',
                '>vertigoray          console   5  Active          .  8/9/2017 4:40 PM'
            )
        }
    }
    Output = @(
        @{
            Server        = 'localhost'
            Username      = 'admin.xxxxxxxx'
            Sessionname   = ''
            Id            = 2
            State         = 'Disc'
            IdleTime     = @{
                Type        = 'System.TimeSpan'
                Value       = '15.15:12:00'
            }
            LogonTime    = @{
                Type        = 'System.DateTime'
                Value       = '07/20/2017 13:19:00'
            }
        },
        @{
            Server        = 'localhost'
            Username      = 'admin.xxxxx'
            Sessionname   = 'rdp-tcp#54'
            Id            = 3
            State         = 'Active'
            IdleTime     = @{
                Type        = 'System.TimeSpan'
                Value       = '0.01:39:00'
            }
            LogonTime    = @{
                Type        = 'System.DateTime'
                Value       = '07/21/2017 05:35:00'
            }
        },
        @{
            Server        = 'localhost'
            Username      = 'xxxxxxxx'
            Sessionname   = ''
            Id            = 4
            State         = 'Disc'
            IdleTime     = @{
                Type        = 'System.TimeSpan'
                Value       = '6.04:10:00'
            }
            LogonTime     = @{
                Type        = 'System.DateTime'
                Value       = '07/21/2017 09:25:00'
            }
        },
        @{
            Server        = 'localhost'
            Username      = 'vertigoray'
            Sessionname   = 'console'
            Id            = 5
            State         = 'Active'
            IdleTime     = @{
                Type        = 'System.Void'
                Value       = $null
            }
            LogonTime     = @{
                Type        = 'System.DateTime'
                Value       = '08/09/2017 16:40:00'
            }
        }
    )
}

