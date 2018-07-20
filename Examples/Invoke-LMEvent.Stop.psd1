@{
    Parameters    = @{
        Action         = 'Stop'
        LMEvent        = @{
            SourceEventArgs = @{
                NewEvent = @{
                    CimInstanceProperties = $null
                    ProcessName           = '19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7'
                    ProcessId             = 19
                }
            }
        }
        QuserObject = @{
            DirectoryPath = '%ProjectRoot%\dev\QuserObject'
            Processes     = @{
                '19f3c7a5-8e6a-4379-ab73-b65c2f0a0ea7' = 2
                'notepad.exe'                          = 5
                'Calculator.exe'                       = 10
            }
        }
    }
}