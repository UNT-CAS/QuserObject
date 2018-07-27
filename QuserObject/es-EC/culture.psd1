# @{
#     Server        = 'Servidor'
#     Username      = 'NombreUsuario'
#     Sessionname   = 'NombreSesión'
#     Id            = 'Id'
#     State         = 'Estado'
#     IdleTime      = 'TiempoIn'
#     LogonTime     = 'TiempoSesión'
# }

ConvertFrom-StringData @'
Server        = Servidor
Username      = NombreUsuario
Sessionname   = NombreSesión
Id            = Id
State         = Estado
IdleTime      = TiempoIn
LogonTime     = TiempoSesión
'@