@{
    Parameters = @{
        QuserObject = @{
            DirectoryPath = '%ProjectRoot%\dev\QuserObject'
            Processes     = @{
                '19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7' = 2
                'notepad.exe'                          = 5
                'Calculator.exe'                       = 10
            }
        }
        ProcessName = '19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7'
        ProcessId = 19
        ProcessUserName = 'Test\Pester'
    }
    ExistingCsv = @'
"ProcessId","Timestamp","ComputerName","ProcesssUserName","ProcessName"
"18","2018-07-02T15:27:55.4452955-05:00","Test","Pester","19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7"
'@
    <#
        ExpectedCsv
        {0}:$env:ComputerName
        {1}:Timestamp within last minute
    #>
    ExpectedCsv = @'
"ProcessId","Timestamp","ComputerName","ProcesssUserName","ProcessName"
"18","2017-07-02T15:27:55.4452955-05:00","Test","Test\Pester","19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7"
"19","{1}","{0}","Test\Pester","19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7"
'@
}