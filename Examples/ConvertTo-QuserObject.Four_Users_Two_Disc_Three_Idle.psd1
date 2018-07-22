@{
    Parameters = @{
        QuserOutput = @(
            'USERNAME         SESSIONNAME  ID  STATE   IDLE TIME  LOGON TIME',
            ' admin.xxxxxxxx                2  Disc     15+15:12  7/20/2017 1:19 PM',
            ' admin.xxxxx      rdp-tcp#54   3  Active       1:39  7/21/2017 5:35 AM',
            ' xxxxxxxx                      4  Disc      6+04:10  7/21/2017 9:25 AM',
            '>vertigoray          console   5  Active          .  8/9/2017 4:40 PM'
        )
    }
    GetDateNow = '8/9/2017 4:40 PM'
    Output = @(
        @{
            Username    = 'admin.xxxxxxxx'
            Sessionname = ''
            Id          = 2
            State       = 'Disconnected'
            IdleTime    = '07/25/2017 16:24:48'
            LogonTime   = '07/20/2017 13:19:00'
        },
        @{
            Username    = 'admin.xxxxx'
            Sessionname = 'rdp-tcp#54'
            Id          = 3
            State       = 'Active'
            IdleTime    = '08/09/2017 16:38:21'
            LogonTime   = '07/21/2017 05:35:00'
        },
        @{
            Username    = 'xxxxxxxx'
            Sessionname = ''
            Id          = 4
            State       = 'Disconnected'
            IdleTime    = '08/03/2017 16:35:50'
            LogonTime   = '07/21/2017 09:25:00'
        },
        @{
            Username    = 'vertigoray'
            Sessionname = 'console'
            Id          = 5
            State       = 'Active'
            IdleTime    = $null
            LogonTime   = '08/09/2017 16:40:00'
        }
    )
}

