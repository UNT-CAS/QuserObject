[![Build status](https://ci.appveyor.com/api/projects/status/d88b15ilqgkqgo4e?svg=true)](https://ci.appveyor.com/project/VertigoRay/quserobject)
[![codecov](https://codecov.io/gh/UNT-CAS/QuserObject/branch/master/graph/badge.svg)](https://codecov.io/gh/UNT-CAS/QuserObject)
[![version](https://img.shields.io/powershellgallery/v/QuserObject.svg)](https://www.powershellgallery.com/packages/QuserObject)
[![downloads](https://img.shields.io/powershellgallery/dt/QuserObject.svg?label=downloads)](https://www.powershellgallery.com/stats/packages/QuserObject?groupby=Version)

Run `quser.exe` and return a proper PowerShell Object.
I discussed this [on my blog](http://blog.vertigion.com/2018/04/27/terminal_server_sessions/?utm_source=github&utm_medium=unt-cas&utm_campaign=quserobject) to enhance [a StackOverflow answer](https://stackoverflow.com/a/49042770/615422).
I thought I'd make this into a PowerShell module for ease of use and distribution.

# Quick Setup

1. Install *QuserObject*: `Install-Module QuserObject`.
2. Import *QuserObject*: `Import-Module QuserObject`.
3. Start *QuserObject*: `Get-Quser` or `Get-LoggedOnUsers`.

# Description

The `quser.exe` program displays information about users logged on to the system.
The `quser.exe` program is already available on your Windows desktop and server OSs.

*Considerations have been  made to keep things [language agnostic](/UNT-CAS/QuserObject/issues/3).*

## Quser Usage

Running `quser.exe` from the Command Prompt or PowerShell will give you the following output:

```powershell
PS > quser.exe

 USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
>vertigoray            console             1  Active       3:11  7/26/2018 7:29 PM
```

This is useful information, but in order to use it programmatically, you will need to parse that stdout.

## QuserObject Usage

That's where the *QuserObject* module comes in.
The parsing has already been done for you:

```powershell
PS > Get-Quser

Server           : localhost
Username         : vertigoray
IsCurrentSession : True
Sessionname      : console
Id               : 1
State            : Active
IdleTime         : 03:11:00
LogonTime        : 7/26/2018 7:29:00 PM
```

## QuserObject Types

This output is a `[PSObject]`, and can be used programmatically.
Here's an example that shows you the types of each returned property:

```powershell
PS > Get-Quser | %{ $_.PSObject.Properties | %{ "{0,16}: [{1,-15}] {2}" -f $_.Name, $_.Value.GetType().FullName, $_.Value } }

          Server: [System.String  ] localhost
        Username: [System.String  ] vertigoray
IsCurrentSession: [System.Boolean ] True
     Sessionname: [System.String  ] console
              Id: [System.Int32   ] 1
           State: [System.String  ] Active
        IdleTime: [System.TimeSpan] 03:11:00
       LogonTime: [System.DateTime] 7/26/2018 7:29:00 PM
```

## `Get-LoggedOnUsers` Alias

For your convenience, I've created a `Get-LoggedOnUsers` alias for `Get-Quser`.

```powershell
PS > Get-Alias | ?{ $_.Source -eq 'QuserObject' } | select Name,ResolvedCommand,CommandType,Source

Name              ResolvedCommand CommandType Source
----              --------------- ----------- ------
Get-LoggedOnUsers Get-Quser             Alias QuserObject
```

# Parameters

## Server

- Type: `[string[]]`
- Default: `localhost`

The server to be queried. Default is current.

*See the [Quick Example](#quick-example), [IdleStartTime Example](#idlestarttime-example), [Target a Server](#target-a-server), [Target Multiple Servers](#target-multiple-servers), and [Pipeline Multiple Servers](#pipeline-multiple-servers) examples.*

## IdleStartTime

- Type: `[switch]`

By default, IdleTime is returned as a `[timespan]` making it consistent with the way `quser.exe` gives the idle time.
Setting this switch will return IdleTime as `[datetime]` of when idleness started.

*See the [IdleStartTime Example](#idlestarttime-example) example.*

### Example

Assume `quser.exe` returns an idle time of `3+04:05`, and the `[datetime]` when you run `Get-Quser` is: `8/1/2018 12:01:00 PM`.
The return `IdleTime` property will be different depending on whether or not this parameter is set:

- Parameter Not Set: `[System.TimeSpan] '3.04:05:00'`
- Parameter Is Set: `[System.DateTime] '07/29/2018 07:56:00'`

## UserOrSession

- Type: `[string]`
- Default: ``

Optional username, sessionname, or sessionid to pass on to `quser.exe`.

## AdComputer

- Type: `[PSObject]`

The AD computer object of the server(s) to be queried.

*See the [AD Computer](#ad-computer) and [AD Computers with Different Property](#ad-computers-with-different-property) examples.*

## Property

- Type: `[string]`
- Default: `Name`

When working with an AD computer object, you can specify which AD property to target as the Server. 
Default is `Name`, but you might want to change it to something like `DNSHostName`.
Just be sure the property you set is included in the results of the `Get-ADComputer` command.

*See the [AD Computers with Different Property](#ad-computers-with-different-property) example.*

# Output

- Type: `[PSObject]`

The only available function of this module (`Get-Quser`; aka `Get-LoggedOnUsers`) returns a `[PSObject]`.
Here's a description of all of the returned properties and their types.

- **Server**: `[System.String]`
  - *This is the target server. By default, `localhost` will be targetted.*
- **Username**: `[System.String]`
  - *The username of the user logged in.*
- **Sessionname**: `[System.String]`
  - *The session name of the user logged in.*
- **Id**: `[System.Int32]`
  - *The session ID of the user logged in.*
- **State**: `[System.String]`
  - *The state of the session; should be `Active` or `Disc` (Disconnectted).*
- **IdleTime**: `[System.TimeSpan]`
  - *The amount of time the user*
  - Variation: `[System.DateTime]`. If [IdleStartTime](#idlestarttime) is set.
- **LogonTime**: `[System.DateTime]`
  - *The date and time of when the user logged in.*

# Examples

## Quick Example

This will return the `quser.exe` results for the current computer (aka `localhost`).

```powershell
Get-Quser
```

## IdleStartTime Example

This will return the `quser.exe` results for the current computer (aka `localhost`).
The returned IdleTime property will be a `[datetime]` of when idleness started.

```powershell
Get-Quser -IdleStartTime
```

## Target a Server

This will return the `quser.exe` results for `ThisServer`.

```powershell
Get-Quser -ServerName 'ThisServer'
```

## Target Multiple Servers

This will return the `quser.exe` results for `ThisServer` and `ThatServer`.

```powershell
Get-Quser -ServerName 'ThisServer', 'ThatServer'
```

## Pipeline Multiple Servers

This will return the `quser.exe` results for `ThisServer` and `ThatServer`.

```powershell
@('ThisServer', 'ThatServer') | Get-Quser
```

## AD Computer

This will return the `quser.exe` results for `ThisServer`.
The value is piped from a `Get-ADComputer` query.

```powershell
Get-ADComputer 'ThisServer' | Get-Quser
```

## AD Computers with Different Property

This will return the `quser.exe` results for computers in the supplied OU.
This value is piped from a `Get-ADComputer` query and using the AD computer `DNSHostName` property instead of the default `Name` property.

```powershell
Get-ADComputer -Filter * -SearchBase 'OU=Computers,DC=ad,DC=example,DC=com' | Get-Quser -Property 'DNSHostName'
```
