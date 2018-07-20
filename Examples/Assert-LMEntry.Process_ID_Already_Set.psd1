@{
    Parameters   = @{
        QuserObject  = @{
            DirectoryPath = '%ProjectRoot%\dev\QuserObject'
            Processes     = @{
                '19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7' = 2
                'notepad.exe'                          = 5
                'Calculator.exe'                       = 10
            }
        }
        ProcessName     = '19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7'
        ProcessId       = 19
        ProcessUserName = 'Test\Pester'
    }
    <#
        ExpectedJson
        {0}:$env:ComputerName
    #>
    ExistingJson = @'
{
    "UserName":  "Test\\Pester",
    "ProcessId":  [
                      19
                  ],
    "ComputerName":  "{0}",
    "TimeStamp":  "Thursday, June 22, 2017 5:43:33 PM"
}
'@
    ProcessAllowed = $true
}