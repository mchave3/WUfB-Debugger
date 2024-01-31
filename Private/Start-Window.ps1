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
    $namedElements = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
    foreach ($element in $namedElements) {
        $elementName = $element.Name
        if (-not (Get-Variable -Name $elementName -ErrorAction SilentlyContinue)) {
            New-Variable -Name $elementName -Value $window.FindName($elementName) -Force | Out-Null
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