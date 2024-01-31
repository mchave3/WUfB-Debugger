<#
.SYNOPSIS
Retrieves the Windows version information for a specified computer.

.DESCRIPTION
The Get-MyWindowsVersion function retrieves the Windows edition, version, and OS build information for a specified computer. If no computer name is provided, it retrieves the information for the local computer.

.PARAMETER ComputerName
The name of the computer for which to retrieve the Windows version information. If not specified, the local computer name is used.

.OUTPUTS
A custom object with the following properties:
- ComputerName: The name of the computer.
- WindowsEdition: The edition of Windows installed on the computer.
- Version: The version of Windows installed on the computer.
- OSBuild: The OS build number of Windows installed on the computer.

.EXAMPLE
PS> Get-MyWindowsVersion
Retrieves the Windows version information for the local computer.

.NOTES
# https://smsagent.blog/2021/04/20/get-the-current-patch-level-for-windows-10-with-powershell/

#>

Function Get-MyWindowsVersion {
    [CmdletBinding()]
    Param (
        $ComputerName = $env:COMPUTERNAME
    )

    $ProgressPreference = "SilentlyContinue"

    $Table = [PSCustomObject]@{
        ComputerName = $ComputerName
        "Windows Edition" = ""
        Version = ""
        "OS Build" = ""
    }

    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"

    $Table."Windows Edition" = (Get-ItemPropertyValue -Path $RegistryPath -Name ProductName -ErrorAction SilentlyContinue) -replace "\s+"
    $Table.Version = (Get-ItemPropertyValue -Path $RegistryPath -Name ReleaseID -ErrorAction SilentlyContinue) -replace "\s+"
    $CurrentBuild = (Get-ItemPropertyValue -Path $RegistryPath -Name CurrentBuild -ErrorAction SilentlyContinue) -replace "\s+"
    $UBR = (Get-ItemPropertyValue -Path $RegistryPath -Name UBR -ErrorAction SilentlyContinue) -replace "\s+"
    $Table."OS Build" = "$CurrentBuild.$UBR"

    return $Table
}

Get-MyWindowsVersion