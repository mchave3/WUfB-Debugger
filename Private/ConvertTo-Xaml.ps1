<#
.SYNOPSIS
Converts a string to XAML format.

.DESCRIPTION
The ConvertTo-Xaml function takes a string as input and converts it to XAML format. It performs the following operations:
- Trims the input string.
- Checks if the string starts with "<". If not, it returns.
- Checks if the string contains "x:" but does not contain the default XAML namespace. If so, it adds the default XAML namespace.
- Checks if the string is empty. If so, it returns.
- Attempts to convert the string to an XML object. If unsuccessful, it returns.
- Selects the first XML node and adds the default XAML namespace if it doesn't already exist.
- Returns the outer XML of the selected node.

.PARAMETER text
The string to be converted to XAML format.

.EXAMPLE
ConvertTo-Xaml -text $text
Output: <Button xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Content="Click Me" Width="100" Height="50" />

#>
function ConvertTo-Xaml 
{
    [CmdletBinding()]
    param([string]$text)
    
    $text = $text.Trim()
    if ($text[0] -ne "<") { return } 
    if ($text -like "*x:*" -and $text -notlike '*http://schemas.microsoft.com/winfx/2006/xaml*') {
        $text = $text.Trim()
        $firstSpace = $text.IndexOfAny(" >".ToCharArray())    
        $text = $text.Insert($firstSpace, ' xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" ')
    }

    if (-not $text) { return }
    $xml = $text -as [xml]
    if (-not $xml) { return } 
    $xml.SelectNodes("//*") |
        Select-Object -First 1 | 
        Foreach-Object {
            if (-not $_.xmlns) {
                $_.SetAttribute("xmlns", 'http://schemas.microsoft.com/winfx/2006/xaml/presentation')
            }
            $_.OuterXml
        }            
}