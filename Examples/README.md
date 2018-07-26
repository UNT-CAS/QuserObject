Each of these examples is a hashtable of data.
These are used for testing by the Pester Tests.
Hopefully, this document will make it a little easier to understand what's in the files.

# Description

Each Function has it's own set of examples.
It should be obvious, but the function's example's file name starts with the function's name; followed by a description of the test.

- The PSD1 Files are the Examples.
- The XML files are used for testing AD Computers. The XML was created like this: `Get-ADComputer 'ThisComputer' | Export-Clixml`.

## Test Entry

```powershell
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
```

# Example File Name

The example file name follows a pattern: `%FunctionName%.%TestDescription%.psd1`.

- `%FunctionName%`: The function name that we're testing. The Pester test will filter to examples beginning with the function name that it was written for. So, this can't have typos or it won't be included in the test.
- `%TestDescription%`: The description of the test. This is used to define the Pester *Context* that we're in. Underscores (`_`) are replaced with spaces.
- `psd1`: a PowerShell Data file; see [Import-PowerShellDataFile](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-powershelldatafile) for more information.

# Main Keys

For lack of a better term, I'm going to call each item in the hashtable a *main key*.

## ADComputer

- Type: `[string]`
- Function Tests: `Get-Quser`

If `[bool]` then we will ensure the test starts with an empty JSON (`$true`) or without a JSON at all (`$false`).

If `[string]` then we will ensure the test starts with a JSON with the contents set to value of this variable.

## GetDateNow

- Type: `[strin]`
- Function Tests: `Get-Date`, `Get-QuserIdleTime`

This specifies that `[DateTime]` that should be returned by the `Get-Date` function; for testing purposes.
Normally, calling `Get-Date` will return the current date and time.

## Output

- Type: `[array]`
- Function Tests: `Get-QuserIdleTime`

The expected output/return of the function based on the parameters used.

## Parameters

- Type: `[hashtable]`
- Default: `$null`

This is used for splatting into the function that we're testing.

## Pipeline

- Type: `[hashtable]`
- Default: `$null`

Same as the [Parameters](#parameters) key, but specifically does a pipeline test instead of splatting.

## ServerExists

- Type: `[bool]`
- Default: `$false`
- Function Tests: `Invoke-Quser`

Tell Pester if the server (defined in [Parameters](#parameters)) should exist.
