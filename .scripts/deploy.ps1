<#
    Deployed with PSDeploy
        - https://github.com/RamblingCookieMonster/PSDeploy
#>
$PSScriptRootParent = Split-Path $PSScriptRoot -Parent
Write-Host "[Deploy] APPVEYOR_PROJECT_NAME: ${env:APPVEYOR_PROJECT_NAME}" -Foregroundcolor 'Magenta' -BackgroundColor 'Blue'
Write-Host "[Deploy] PSScriptRootParent: ${PSScriptRootParent}" -Foregroundcolor 'Magenta' -BackgroundColor 'Blue'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}): $(Test-Path $PSScriptRootParent)" -Foregroundcolor 'Magenta' -BackgroundColor 'Blue'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}\dev): $(Test-Path "${PSScriptRootParent}\dev")" -Foregroundcolor 'Magenta' -BackgroundColor 'Blue'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}\dev\BuildOutput): $(Test-Path "${PSScriptRootParent}\dev\BuildOutput")" -Foregroundcolor 'Magenta' -BackgroundColor 'Blue'
Write-Host "[Deploy] Path Exists (${PSScriptRootParent}\dev\BuildOutput\QuserObject): $(Test-Path "${PSScriptRootParent}\dev\BuildOutput\QuserObject")" -Foregroundcolor 'Magenta' -BackgroundColor 'Blue'

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
