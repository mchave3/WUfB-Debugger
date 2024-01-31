<#
.SYNOPSIS
Converts a parsed array into a custom object array.

.DESCRIPTION
The Convert-ParsedArray function takes an input array and converts it into a custom object array. Each item in the input array is processed to extract specific information and create a custom object with properties such as Update, KB, InfoURL, and OSBuild.

.PARAMETER Array
The input array to be converted.

.EXAMPLE
$parsedArray = Convert-ParsedArray -Array $inputArray
# Converts the input array into a custom object array.

.INPUTS
System.Object[]

.OUTPUTS
System.Collections.ArrayList

.NOTES
# https://smsagent.blog/2021/04/20/get-the-current-patch-level-for-windows-10-with-powershell/

#>

Function Convert-ParsedArray {
    Param($Array)

    $ProgressPreference = "SilentlyContinue"
    
    $ArrayList = New-Object System.Collections.ArrayList
    foreach ($item in $Array)
    {      
        [void]$ArrayList.Add([PSCustomObject]@{
            # Extract the Update information from the outerHTML of the item
            Update = $item.outerHTML.Split('>')[1].Replace('</a','').Replace('&#x2014;',' – ')
            
            # Extract the KB number from the href of the item
            KB = "KB" + $item.href.Split('/')[-1]
            
            # Create the InfoURL by combining the base URL and the href of the item
            InfoURL = "https://support.microsoft.com" + $item.href
            
            # Extract the OSBuild information from the outerHTML of the item
            OSBuild = $item.outerHTML.Split('(OS ')[1].Split()[1]
        })
    }
    Return $ArrayList
}