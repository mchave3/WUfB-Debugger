function Show-Win32AppUI {
    Add-Type -AssemblyName PresentationFramework
    Add-type -AssemblyName System.Windows.Forms

    # Build UI
    $xmlMainWindow = LoadXml("$PSScriptRoot\Assets\MainWindow.xaml")
    $xmlHomePage = LoadXml("$PSScriptRoot\Assets\HomePage.xaml")
    $xmlSettingsPage = LoadXml("$PSScriptRoot\Assets\SettingsPage.xaml")

    $iconPath = Get-ChildItem -Path "$PSScriptRoot\Assets\Icons" -Filter "*.ico" -ErrorAction Stop
    $xmlMainWindow.Icon = New-Object System.Windows.Media.Imaging.BitmapImage (New-Object System.Uri($iconPath.FullName))
}
Show-Win32AppUI