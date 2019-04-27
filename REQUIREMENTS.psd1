<#
    REQUIREMENTS installed with [PSDepend](https://github.com/RamblingCookieMonster/PSDepend):
    See `.appveyor.yml::install` for details on preparing the system to use PSDepend.
#>
@{
    'Prep'             = @{
        DependencyType = 'task'
        Target         = '$PWD\.scripts\requirements.prep.ps1'
        DependsOn      = @('powershell-yaml')
    }
    'Pester'           = '4.6.0'
    'powershell-yaml'  = '0.3.2'
    'psake'            = '4.7.0'
    'PSDeploy'         = '0.2.3'
    'PSScriptAnalyzer' = '1.11.0'
    'CodeCovIo.psm1'   = @{
        DependencyType = 'FileDownload'
        Source         = 'https://raw.githubusercontent.com/aaronpowell/ps-nvm/6457fd9d7b94b109b7cccbe538758081b3804a05/.scripts/CodeCovIo.psm1'
        Target         = '$PWD\.temp\CodeCovIo.psm1'
        DependsOn      = @('Prep')
    }
    'Codecov.zip'      = @{
        DependencyType = 'FileDownload'
        Source         = 'https://github.com/codecov/codecov-exe/releases/download/1.0.3/Codecov.zip'
        Target         = '$PWD\.temp\Codecov.zip'
        DependsOn      = @('Prep')
    }
    'Codecov'          = @{
        DependencyType = 'task'
        Target         = '$PWD\.scripts\requirements.codecov.ps1'
        DependsOn      = @('Codecov.zip', 'CodeCovIo.psm1')
    }
}