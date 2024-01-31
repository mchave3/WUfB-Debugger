function Start-Window {
    Add-Type -AssemblyName PresentationFramework

    # Load XAML
    [xml]$xaml = Get-Content -Path ".\Private\Assets\Window.xaml" -Raw
    $xamlReader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($xamlReader)

    # Get a file from folder path
    $iconPath = Get-ChildItem -Path ".\Private\Assets\Icons" -Filter "*.ico" -ErrorAction Stop
    if ($iconPath.Count -gt 1) {
        $iconPath = $iconPath | Out-GridView -Title "Select an icon" -PassThru
    }

    # Set the Icon property of the window
    $window.Icon = New-Object System.Windows.Media.Imaging.BitmapImage (New-Object System.Uri($iconPath.FullName))

    # Create variables for each named element
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object {
        # Verify that the element variable doesn't already exist
        if (Get-Variable -Name $_.Name -ErrorAction SilentlyContinue) {
            Set-Variable -Name $_.Name -Value $window.FindName($_.Name) -Force | Out-Null
        }
        else {
            New-Variable -Name $_.Name -Value $window.FindName($_.Name) -Force | Out-Null
        }
    }

    # Load the Home page by default
    $MainFrame = $window.FindName("MainFrame")
    $MainFrame.Navigate((ConvertTo-Xaml -String ([System.Windows.Markup.XamlReader]::Parse((Get-Content ".\Private\Assets\HomePage.xaml")))))

    # Home Button Click Event
    $HomeButton = $window.FindName("HomeButton")
    $HomeButton.Add_Click({
        $MainFrame.Navigate((ConvertTo-Xaml -String ([System.Windows.Markup.XamlReader]::Parse((Get-Content ".\Private\Assets\HomePage.xaml")))))
    })

    # Settings Button Click Event
    $SettingsButton = $window.FindName("SettingsButton")
    $SettingsButton.Add_Click({
        $MainFrame.Navigate((ConvertTo-Xaml -String ([System.Windows.Markup.XamlReader]::Parse((Get-Content ".\Private\Assets\SettingsPage.xaml")))))
    })

    # Show the window
    $window.ShowDialog() | Out-Null
}

Start-Window