<#
.SYNOPSIS
    Retrieves information about the current Windows patch and the latest available patch.

.DESCRIPTION
    The Get-CurrentPatchInfo function retrieves information about the current Windows patch and the latest available patch. It uses the Invoke-WebRequest cmdlet to parse the Windows Update History webpage and filter the version data based on the current Windows version. The function can list all available patches or return a table with patch information.

.PARAMETER ListAllAvailable
    If specified, lists all available patches instead of just the current patch and the latest available patch.

.PARAMETER ExcludePreview
    If specified, excludes preview patches from the list of available patches.

.PARAMETER ExcludeOutofBand
    If specified, excludes out-of-band patches from the list of available patches.

.OUTPUTS
    If the ListAllAvailable parameter is specified, the function returns a DataTable object with the following columns:
    - Update: The name of the update.
    - KB: The KB number of the update.
    - InfoURL: The URL to the support information for the update.

    If the ListAllAvailable parameter is not specified, the function returns a DataTable object with the following columns:
    - OSVersion: The version of the current Windows operating system.
    - OSEdition: The edition of the current Windows operating system.
    - OSBuild: The build number of the current Windows operating system.
    - CurrentInstalledUpdate: The name of the currently installed update.
    - CurrentInstalledUpdateKB: The KB number of the currently installed update.
    - CurrentInstalledUpdateInfoURL: The URL to the support information for the currently installed update.
    - LatestAvailableUpdate: The name of the latest available update.
    - LastestAvailableUpdateKB: The KB number of the latest available update.
    - LastestAvailableUpdateInfoURL: The URL to the support information for the latest available update.

.EXAMPLE
    Get-CurrentPatchInfo -ListAllAvailable
    Lists all available patches.

.EXAMPLE
    Get-CurrentPatchInfo
    Retrieves information about the current Windows patch and the latest available patch.

.EXAMPLE
    Get-CurrentPatchInfo -ExcludePreview
    Retrieves information about the current Windows patch and the latest available patch, excluding preview patches.

.EXAMPLE
    Get-CurrentPatchInfo -ExcludeOutofBand
    Retrieves information about the current Windows patch and the latest available patch, excluding out-of-band patches.

.NOTES
# https://smsagent.blog/2021/04/20/get-the-current-patch-level-for-windows-10-with-powershell/

#>

function Get-CurrentPatchInfo {
    [CmdletBinding()]
    Param(
        [switch]$ListAllAvailable,
        [switch]$ExcludePreview,
        [switch]$ExcludeOutofBand
    )

    $ProgressPreference = "SilentlyContinue"
    $URI = "https://aka.ms/WindowsUpdateHistory" # Microsoft URL for Windows Update History
    
    # Invoke web request to get the response
    $Response = Invoke-WebRequest -Uri $URI -UseBasicParsing -ErrorAction Stop
        
    # Check if the response was parsed as HTML
    If (!($Response.Links)) {
        throw "Response was not parsed as HTML"
    }
    
    # Filter the version data based on the current Windows version
    $VersionDataRaw = $Response.Links | Where-Object {$_.outerHTML -match "supLeftNavLink" -and $_.outerHTML -match "KB"}
    $CurrentWindowsVersion = Get-MyWindowsVersion -ErrorAction Stop
    
    # Filter expression for excluding preview and out-of-band patches
    $FilterExpression = {
        $_.outerHTML -match $CurrentWindowsVersion."OS Build".Split('.')[0] -and
        (!$ExcludePreview -or $_.outerHTML -notmatch "Preview") -and
        (!$ExcludeOutofBand -or $_.outerHTML -notmatch "Out-of-band")
    }
    
    # List all available patches
    if ($ListAllAvailable) {
        $AllAvailablePatches = $VersionDataRaw | Where-Object $FilterExpression
        $UniquePatches = (Convert-ParsedArray -Array $AllAvailablePatches) | Sort-Object OSBuild -Descending -Unique
        $Table = New-Object System.Data.DataTable
        [void]$Table.Columns.AddRange(@("Update","KB","InfoURL"))
        foreach ($Patch in $UniquePatches) {
            [void]$Table.Rows.Add(
                $Patch.Update,
                $Patch.KB,
                $Patch.InfoURL
            )
        }
        Return $Table
    }
    
    # Get current patch and latest available patch
    $CurrentPatch = $VersionDataRaw | Where-Object {$_.outerHTML -match $CurrentWindowsVersion."OS Build"} | Select-Object -First 1
    $LatestAvailablePatch = $VersionDataRaw | Where-Object $FilterExpression | Select-Object -First 1
    
    # Create a table with patch information
    $Table = New-Object System.Data.DataTable
    [void]$Table.Columns.AddRange(@("OSVersion","OSEdition","OSBuild","CurrentInstalledUpdate","CurrentInstalledUpdateKB","CurrentInstalledUpdateInfoURL","LatestAvailableUpdate","LastestAvailableUpdateKB","LastestAvailableUpdateInfoURL"))
    [void]$Table.Rows.Add(
        $CurrentWindowsVersion.Version,
        $CurrentWindowsVersion."Windows Edition",
        $CurrentWindowsVersion."OS Build",
        $CurrentPatch.outerHTML.Split('>')[1].Replace('</a','').Replace('&#x2014;',' - '),
        "KB" + $CurrentPatch.href.Split('/')[-1],
        "https://support.microsoft.com" + $CurrentPatch.href,
        $LatestAvailablePatch.outerHTML.Split('>')[1].Replace('</a','').Replace('&#x2014;',' - '),
        "KB" + $LatestAvailablePatch.href.Split('/')[-1],
        "https://support.microsoft.com" + $LatestAvailablePatch.href
    )
    Return $Table
}