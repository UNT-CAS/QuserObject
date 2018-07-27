# @{
#     Server        = 'Server'
#     Username      = 'Username'
#     Sessionname   = 'Sessionname'
#     Id            = 'Id'
#     State         = 'State'
#     IdleTime      = 'IdleTime'
#     LogonTime     = 'LogonTime'
# }

ConvertFrom-StringData @'

# English strings

Msg1 = "The Name parameter is missing from the command."
Msg2 = "This command requires the credentials of a member of the Administrators group on the computer."
Msg3 = "Use $_ to represent the object that is being processed."
'@