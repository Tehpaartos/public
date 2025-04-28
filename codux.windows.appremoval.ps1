<#
.SYNOPSIS
    Deploy CX MEM W10 Built In App Removal
.DESCRIPTION
    This script will remove several built-in apps based on 
.SOURCE
    Based upon the VDOT tool (Virtual Desktop Optimisation Tool) with photos and paint to remain
#>
# Start Logging
Start-Transcript -Path "$env:TEMP\CX.MEM.W10.Build.In.pp.Removal.$(Get-Date -format "yyyyMMddHHmm").log"

# Get a list of directories in the User directory
$directories = Get-ChildItem -Path "C:\Users"
# Check if there are only 2 directories and they are 'Public' and 'Default'
if ($directories.Count -eq 2 -and ($directories.Name -contains "Public") -and ($directories.Name -contains "defaultuser0")) {
    
  #JSON of apps to be removed
  $Content = @"
[
  {
    "AppxPackage": "Microsoft.BingNews",
    "URL": "https://www.microsoft.com/en-us/p/microsoft-news/9wzdncrfhvfw",
    "Description": "Microsoft News app"
  },
  {
    "AppxPackage": "Microsoft.BingWeather",
    "URL": "https://www.microsoft.com/en-us/p/msn-weather/9wzdncrfj3q2",
    "Description": "MSN Weather app"
  },
  {
    "AppxPackage": "Microsoft.GamingApp",
    "URL": "https://www.microsoft.com/en-us/p/xbox/9mv0b5hzvk9z",
    "Description": "Xbox app"
  },
  {
    "AppxPackage": "Microsoft.GetHelp",
    "URL": "https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/customize-get-help-app",
    "Description": "App that facilitates free support for Microsoft products"
  },
  {
    "AppxPackage": "Microsoft.Getstarted",
    "URL": "https://www.microsoft.com/en-us/p/microsoft-tips/9wzdncrdtbjj",
    "Description": "Windows 10 tips app"
  },
  {
    "AppxPackage": "Microsoft.MicrosoftOfficeHub",
    "URL": "https://www.microsoft.com/en-us/p/office/9wzdncrd29v9",
    "Description": "Office UWP app suite"
  },
  {
    "AppxPackage": "Microsoft.Office.OneNote",
    "URL": "https://www.microsoft.com/en-us/p/onenote-for-windows-10/9wzdncrfhvjl",
    "Description": "Office UWP OneNote app"
  },
  {
    "AppxPackage": "Microsoft.MicrosoftSolitaireCollection",
    "URL": "https://www.microsoft.com/en-us/p/microsoft-solitaire-collection/9wzdncrfhwd2",
    "Description": "Solitaire suite of games"
  },
  {
    "AppxPackage": "Microsoft.MicrosoftStickyNotes",
    "URL": "https://www.microsoft.com/en-us/p/microsoft-sticky-notes/9nblggh4qghw",
    "Description": "Note-taking app"
  },
  {
    "AppxPackage": "Microsoft.People",
    "URL": "https://www.microsoft.com/en-us/p/microsoft-people/9nblggh10pg8",
    "Description": "Contact management app"
  },
  {
    "AppxPackage": "Microsoft.PowerAutomateDesktop",
    "URL": "https://flow.microsoft.com/en-us/desktop/",
    "Description": "Power Automate Desktop app. Record desktop and web actions in a single flow"
  },
  {
    "AppxPackage": "Microsoft.ScreenSketch",
    "URL": "https://www.microsoft.com/en-us/p/snip-sketch/9mz95kl8mr0l",
    "Description": "Snip and Sketch app"
  },
  {
    "AppxPackage": "Microsoft.SkypeApp",
    "URL": "https://www.microsoft.com/en-us/p/skype/9wzdncrfj364",
    "Description": "Instant message, voice or video call app"
  },
  {
    "AppxPackage": "Microsoft.Todos",
    "URL": "https://www.microsoft.com/en-us/p/microsoft-to-do-lists-tasks-reminders/9nblggh5r558",
    "Description": "Microsoft To Do makes it easy to plan your day and manage your life"
  },
  {
    "AppxPackage": "Microsoft.WindowsAlarms",
    "URL": "https://www.microsoft.com/en-us/p/windows-alarms-clock/9wzdncrfj3pr",
    "Description": "A combination app, of alarm clock, world clock, timer, and stopwatch."
  },
  {
    "AppxPackage": "microsoft.windowscommunicationsapps",
    "URL": "https://www.microsoft.com/en-us/p/mail-and-calendar/9wzdncrfhvqm",
    "Description": "Mail & Calendar apps"
  },
  {
    "AppxPackage": "Microsoft.WindowsFeedbackHub",
    "URL": "https://www.microsoft.com/en-us/p/feedback-hub/9nblggh4r32n",
    "Description": "App to provide Feedback on Windows and apps to Microsoft"
  },
  {
    "AppxPackage": "Microsoft.WindowsMaps",
    "URL": "https://www.microsoft.com/en-us/p/windows-maps/9wzdncrdtbvb",
    "Description": "Microsoft Maps app"
  },
  {
    "AppxPackage": "Microsoft.Xbox.TCUI",
    "URL": "https://docs.microsoft.com/en-us/gaming/xbox-live/features/general/tcui/live-tcui-overview",
    "Description": "XBox Title Callable UI (TCUI) enables your game code to call pre-defined user interface displays"
  },
  {
    "AppxPackage": "Microsoft.XboxGameOverlay",
    "URL": "https://www.microsoft.com/en-us/p/xbox-game-bar/9nzkpstsnw4p",
    "Description": "Xbox Game Bar extensible overlay"
  },
  {
    "AppxPackage": "Microsoft.XboxGamingOverlay",
    "URL": "https://www.microsoft.com/en-us/p/xbox-game-bar/9nzkpstsnw4p",
    "Description": "Xbox Game Bar extensible overlay"
  },
  {
    "AppxPackage": "Microsoft.XboxIdentityProvider",
    "URL": "https://www.microsoft.com/en-us/p/xbox-identity-provider/9wzdncrd1hkw",
    "Description": "A system app that enables PC games to connect to Xbox Live."
  },
  {
    "AppxPackage": "Microsoft.XboxSpeechToTextOverlay",
    "URL": "https://support.xbox.com/help/account-profile/accessibility/use-game-chat-transcription",
    "Description": "Xbox game transcription overlay"
  },
  {
    "AppxPackage": "Microsoft.YourPhone",
    "URL": "https://www.microsoft.com/en-us/p/Your-phone/9nmpj99vjbwv",
    "Description": "Android phone to PC device interface app"
  },
  {
    "AppxPackage": "Microsoft.ZuneMusic",
    "URL": "https://www.microsoft.com/en-us/p/groove-music/9wzdncrfj3pt",
    "Description": "Groove Music app"
  },
  {
    "AppxPackage": "Microsoft.ZuneVideo",
    "URL": "https://www.microsoft.com/en-us/p/movies-tv/9wzdncrfj3p2",
    "Description": "Movies and TV app"
  },
  {
    "AppxPackage": "Microsoft.XboxApp",
    "URL": "https://www.microsoft.com/store/apps/9wzdncrfjbd8",
    "Description": "Xbox 'Console Companion' app (games, friends, etc.)"
  },
  {
    "AppxPackage": "Microsoft.MixedReality.Portal",
    "URL": "https://www.microsoft.com/en-us/p/mixed-reality-portal/9ng1h8b3zc7m",
    "Description": "The app that facilitates Windows Mixed Reality setup, and serves as the command center for mixed reality experiences"
  },
  {
    "AppxPackage": "Microsoft.Microsoft3DViewer",
    "URL": "https://www.microsoft.com/en-us/p/3d-viewer/9nblggh42ths",
    "Description": "App to view common 3D file types"
  },
  {
    "AppxPackage": "MicrosoftTeams",
    "URL": "https://www.microsoft.com/en-us/microsoft-teams/group-chat-software",
    "Description": "Microsoft communication platform"
  },
  {
    "AppxPackage": "Microsoft.Wallet",
    "URL": "https://www.microsoft.com/en-us/payments",
    "Description": "(Microsoft Pay) for Edge browser on certain devices"
  },
  {
    "AppxPackage": "Microsoft.MSPaint",
    "URL": "https://www.microsoft.com/en-us/p/paint-3d/9NBLGGH5FV99",
    "Description": "New Paint 3D App"
  },
  {
    "AppxPackage": "Microsoft.549981C3F5F10",
    "URL": "https://www.microsoft.com/en-us/p/cortana/9NFFX4SZZ23L",
    "Description": "Cortana, your personal productivity assistant"
  }
]
"@

  #Function to convert JSON content
  Function Convert-JSONContent {
    [OutputType([System.Management.Automation.PSObject])]
    Param (
      [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
      [System.String] $Content
    )
    try {
      $convertedContent = $Content | ConvertFrom-JSON -ErrorAction "SilentlyContinue"
    } catch [System.Exception] {
      Write-Warning -Message "$($MyInvocation.MyCommand): Failed to convert content."
      Throw $_.Exception.Message
    } finally {
      If ($Null -ne $convertedContent) {
        Write-Output -InputObject $convertedContent
      }
    }
  }

  #Execute JSON conversion function
  $AppxPackage = Convert-JSONContent -Content $Content

  #Clean APPX packages
  If ($AppxPackage.Count -gt 0) {
    Foreach ($Item in $AppxPackage) {
      try {                
        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like ("*{0}*" -f $Item.AppxPackage) } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
        Get-AppxPackage -AllUsers -Name ("*{0}*" -f $Item.AppxPackage) | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue 
        Get-AppxPackage -Name ("*{0}*" -f $Item.AppxPackage) | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Appx Package $($Item.AppxPackage) removed or previously uninstalled"
      } catch {
        Write-Host "Failed to remove Appx Package $($Item.AppxPackage) - $($_.Exception.Message)"
      }
    }
  } Else {
    Write-Host "No AppxPackages found to disable"
  }

    # Windows 10 Feature Disablement
    if ([System.Environment]::OSVersion.Version.Build -like "19*") {

      $settingsWin10 = @(
        @{
          Path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
          Name  = "EnableFeeds"
          Value = 0
          Type  = "DWORD"          
        }
      )
  
      foreach ($setting in $settingsWin10) {
        # Set the registry value
        $null = New-Item -Path $setting.Path -Force #-ErrorAction SilentlyContinue
        Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -Type $setting.Type
  
        # Confirm the changes
        Write-Host "Registry value '$($setting.Name)' set to '$($setting.Value)' (type: $($setting.Type)) in path '$($setting.Path)'."
      }
    }


  # Windows 11 Feature Disablement
  if ([System.Environment]::OSVersion.Version.Build -like "22*") {

    $settingsWin11 = @(
      @{
        Path  = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
        Name  = "ChatIcon"
        Value = 3
        Type  = "DWORD"
      },
      @{
        Path  = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
        Name  = "AllowNewsAndInterests"
        Value = 0
        Type  = "DWORD"
      }
    )

    foreach ($setting in $settingsWin11) {
      # Set the registry value
      $null = New-Item -Path $setting.Path -Force #-ErrorAction SilentlyContinue
      Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -Type $setting.Type

      # Confirm the changes
      Write-Host "Registry value '$($setting.Name)' set to '$($setting.Value)' (type: $($setting.Type)) in path '$($setting.Path)'."
    }
  }

} else {
  Write-Host "Condition not met to run script during AutoPilot Only.  Not running the script."
}

Stop-Transcript
