<#
    Deployed with PSDeploy
        - https://github.com/RamblingCookieMonster/PSDeploy
#>
$PSScriptRootParent = Split-Path $PSScriptRoot -Parent
Write-Host "[Deploy] APPVEYOR_PROJECT_NAME: ${env:APPVEYOR_PROJECT_NAME}" -Foregroundcolor 'Magenta'
Write-Host "[Deploy] PSScriptRootParent: ${PSScriptRootParent}" -Foregroundcolor 'Magenta'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}): $(Test-Path $PSScriptRootParent)" -Foregroundcolor 'Magenta'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}\dev): $(Test-Path "${PSScriptRootParent}\dev")" -Foregroundcolor 'Magenta'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}\dev\BuildOutput): $(Test-Path "${PSScriptRootParent}\dev\BuildOutput")" -Foregroundcolor 'Magenta'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}\dev\BuildOutput\QuserObject): $(Test-Path "${PSScriptRootParent}\dev\BuildOutput\QuserObject")" -Foregroundcolor 'Magenta'

Deploy Module {
    By PSGalleryModule QuserObject {
        FromSource "${PSScriptRootParent}\dev\BuildOutput\QuserObject"
        To PSGallery
        # Tagged Testing
        WithOptions @{
            ApiKey = $env:PSGalleryApiKey
        }
    }
}
