<#
    .Synopsis

        This is the main scaffolding the glues all the pieces together.
#>
$script:Culture = Get-Culture
if (-not ($script:CultureText = Import-LocalizedData -UICulture $script:Culture -FileName 'culture.psd1' -ErrorAction SilentlyContinue)) {
    $script:Culture = [System.Globalization.CultureInfo]::GetCultureInfo('en')
    $script:CultureText = Import-LocalizedData -UICulture $script:Culture -FileName 'culture.psd1'
}

$public = @( Get-ChildItem -Path "${PSScriptRoot}\Public\*.ps1" -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path "${PSScriptRoot}\Private\*.ps1" -ErrorAction SilentlyContinue )

foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function: $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName