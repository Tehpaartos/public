<#PSScriptInfo
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri osdcloud.codoit.com.au)
This is abbreviated as
powershell iex (irm osdcloud.codoit.com.au)
#>
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    PowerShell Script which supports the OSDCloud environment
.DESCRIPTION
    PowerShell Script which supports the OSDCloud environment
.NOTES
    Version 23.6.10.1
.LINK
    https://raw.githubusercontent.com/Tehpaartos/public/refs/heads/main/codux.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm osdcloud.codoit.com.au)
#>
[CmdletBinding()]
param()
$ScriptName = 'osdcloud.codoit.com.au'
$ScriptVersion = '23.6.10.1'

#region Initialize
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-$ScriptName.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

if ($env:SystemDrive -eq 'X:') {
    $WindowsPhase = 'WinPE'
}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

Write-Host -ForegroundColor Green "[+] $ScriptName $ScriptVersion ($WindowsPhase Phase)"
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)
#endregion

#region Admin Elevation
$whoiam = [system.security.principal.windowsidentity]::getcurrent().name
$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($isElevated) {
    Write-Host -ForegroundColor Green "[+] Running as $whoiam (Admin Elevated)"
}
else {
    Write-Host -ForegroundColor Red "[!] Running as $whoiam (NOT Admin Elevated)"
    Break
}
#endregion

#region Transport Layer Security (TLS) 1.2
Write-Host -ForegroundColor Green "[+] Transport Layer Security (TLS) 1.2"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
#endregion

#region WinPE
if ($WindowsPhase -eq 'WinPE') {
    #Process OSDCloud startup and load Azure KeyVault dependencies
    osdcloud-StartWinPE -OSDCloud
    Write-Host -ForegroundColor Cyan "To start a new PowerShell session, type 'start powershell' and press enter"
    Write-Host -ForegroundColor Cyan "Start-OSDCloud, Start-OSDCloudGUI, or Start-OSDCloudAzure, can be run in the new PowerShell window"
    
    #Configure OSDCloudGUI
    # Import-module OSD -Force
    # $OSDModuleResource.StartOSDCloudGUI.BrandName = 'Codux'

    #Start OSDCloudGUI
    # Start-Process powershell -ArgumentList "-Command Start-OSDCloudGUI"


    $configureOSDCloudGUI = @"
\Import-Module OSD -Force
`$OSDModuleResource.StartOSDCloudGUI.BrandName = 'Codux'
`$OSDModuleResource.StartOSDCloudGUI.BrandColor = '#ED7D31'
`$OSDModuleResource.StartOSDCloudGUI.WindowsUpdate = 'True'
`$OSDModuleResource.StartOSDCloudGUI.WindowsUpdateDrivers = 'True'
`$OSDModuleResource.StartOSDCloudGUI.ClearDiskConfirm = 'False'
`$OSDModuleResource.StartOSDCloudGUI.restartComputer = 'True'
`$OSDModuleResource.StartOSDCloudGUI.updateFirmware = 'True'
`$OSDModuleResource.OSDCloud.Default.ImageIndex = '9'
`$OSDModuleResource.OSDCloud.Default.Edition = 'Pro'
`$OSDModuleResource.OSDCloud.Default.Activation = 'Retail'
`$OSDModuleResource.OSDCloud.Values.Name = @('Windows 11 24H2 x64', 'Windows 10 22H2 x64')
`$OSDModuleResource.OSDCloud.Values.Language = @('en-us', 'en-gb')
`$OSDModuleResource.OSDCloud.Values.Edition = @('Home', 'Education', 'Enterprise', 'Pro')
Start-OSDCloudGUI
"@

Start-Process powershell "-Command", $configureOSDCloudGUI
    
    #Stop the startup Transcript.  OSDCloud will create its own
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Specialize
if ($WindowsPhase -eq 'Specialize') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region AuditMode
if ($WindowsPhase -eq 'AuditMode') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region OOBE
if ($WindowsPhase -eq 'OOBE') {
    #Remove built-in apps before winget upgrade
    RemoveAppx BingNews,BingWeather,GamingApp,GetHelp,Getstarted,MicrosoftOfficeHub,Office.OneNote,MicrosoftSolitaireCollection,MicrosoftStickyNotes,People,PowerAutomateDesktop,ScreenSketch,SkypeApp,Todos,WindowsAlarms,WindowsFeedbackHub,WindowsMaps,Xbox.TCUI,XboxGameOverlay,XboxGamingOverlay,XboxIdentityProvider,XboxSpeechToTextOverlay,YourPhone,ZuneMusic,ZuneVideo,XboxApp,MixedReality.Portal,Microsoft3DViewer,MSPaint,549981C3F5F10
    
    #Install.NET Framework
    NetFX

    #Updates
    UpdateDrivers
    UpdateWindows

    #Windows Feature Disablement
    $winBuild = [System.Environment]::OSVersion.Version.Build
    $settings = @()
    
    if ($winBuild -like "19*") {
        # Windows 10 settings
        $settings = @(
            @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"; Name="EnableFeeds"; Value=0; Type="DWORD"}
        )
    }
    elseif ($winBuild -like "22*") {
        # Windows 11 settings
        $settings = @(
            @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"; Name="ChatIcon"; Value=3; Type="DWORD"},
            @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name="AllowNewsAndInterests"; Value=0; Type="DWORD"}
        )
    }
    
    foreach ($s in $settings) {
        New-Item -Path $s.Path -Force -ErrorAction SilentlyContinue | Out-Null
        Set-ItemProperty -Path $s.Path -Name $s.Name -Value $s.Value -Type $s.Type
        Write-Host "Set '$($s.Name)' to '$($s.Value)' in '$($s.Path)'"
    }
    
    #Load everything needed to run AutoPilot
    osdcloud-StartOOBE -Autopilot -InstallWinGet -WinGetUpgrade

    #Install standard apps
    winget install --id Google.Chrome --silent --scope machine --accept-source-agreements --accept-package-agreements
    winget install --id 7zip.7zip --silent --scope machine --accept-source-agreements --accept-package-agreements
    winget install --id Adobe.Acrobat.Reader.64-bit --silent --scope machine --accept-source-agreements --accept-package-agreements
    
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {
    #Load OSD and Azure stuff
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
