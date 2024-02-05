<#
.SYNOPSIS
Loads an XML file and returns an XmlDocument object.

.DESCRIPTION
The LoadXml function loads an XML file specified by the $filename parameter and returns an XmlDocument object.

.PARAMETER filename
The path to the XML file to be loaded.
#>

function LoadXml{
    param (
        [string]$xmlFilePath
    )
    Add-Type -AssemblyName PresentationFramework

    [xml]$xmlContent = Get-Content -Path $xmlFilePath -Raw
    $xmlReader = New-Object System.Xml.XmlNodeReader $xmlContent
    $window = [Windows.Markup.XamlReader]::Load($xmlReader)
    return $window
}