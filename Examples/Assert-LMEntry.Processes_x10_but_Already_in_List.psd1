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
    ExistingJson = @'
[
    {
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        11
                    ],
        "ComputerName":  "Computer11",
        "TimeStamp":  "Thursday, June 22, 2017 1:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        22
                    ],
        "ComputerName":  "Computer22",
        "TimeStamp":  "Thursday, June 22, 2017 2:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        33
                    ],
        "ComputerName":  "{0}",
        "TimeStamp":  "Thursday, June 22, 2017 3:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        44
                    ],
        "ComputerName":  "Computer44",
        "TimeStamp":  "Thursday, June 22, 2017 4:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        55
                    ],
        "ComputerName":  "Computer55",
        "TimeStamp":  "Thursday, June 22, 2017 5:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        66
                    ],
        "ComputerName":  "Computer66",
        "TimeStamp":  "Thursday, June 22, 2017 6:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        77
                    ],
        "ComputerName":  "",
        "TimeStamp":  "Thursday, June 22, 2017 7:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        88
                    ],
        "ComputerName":  "Computer88",
        "TimeStamp":  "Thursday, June 22, 2017 8:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        99
                    ],
        "ComputerName":  "Computer99",
        "TimeStamp":  "Thursday, June 22, 2017 9:43:33 PM"
    },{
        "UserName":  "Test\\Pester",
        "ProcessId":  [
                        1010
                    ],
        "ComputerName":  "Computer1010",
        "TimeStamp":  "Thursday, June 22, 2017 10:43:33 PM"
    }
]
'@
    ProcessAllowed = $true
}