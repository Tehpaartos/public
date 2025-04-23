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

<#
    $configureOSDCloudGUI = @"
\Import-Module OSD -Force
`$OSDModuleResource.StartOSDCloudGUI.BrandName = 'Codux'
`$OSDModuleResource.StartOSDCloudGUI.BrandColor = '#ED7D31'
`$OSDModuleResource.StartOSDCloudGUI.WindowsUpdate = 'True'
`$OSDModuleResource.StartOSDCloudGUI.WindowsUpdateDrivers = 'True'
`$OSDModuleResource.OSDCloud.Default.ImageIndex = '8'
`$OSDModuleResource.OSDCloud.Default.Edition = 'Pro'
`$OSDModuleResource.OSDCloud.Values.OSNameValues = @('Windows 11 24H2 x64', 'Windows 10 22H2 x64')
Start-OSDCloudGUI
"@

Start-Process powershell "-Command", $configureOSDCloudGUI

#>


    # Create the directory if it doesn't exist
    if (-not (Test-Path -Path "X:\Windows\TEMP")) {
        New-Item -Path "X:\Windows\TEMP" -ItemType Directory -Force | Out-Null
    }
    
    # The JSON configuration
    $osdCloudConfig = @'
{
    "BrandName":  "Codux33",
    "BrandColor":  "#ED7D31",
    "OSActivation":  "Retail",
    "OSEdition":  "Pro",
    "OSLanguage":  "en-us",
    "OSImageIndex":  9,
    "OSName":  "Windows 11 24H2 x64",
    "OSReleaseID":  "24H2",
    "OSVersion":  "Windows 11",
    "OSActivationValues":  [
                                "Retail",
                                "Volume"
                            ],
    "OSEditionValues":  [
                            "Home",
                            "Education",
                            "Enterprise",
                            "Pro"
                        ],
    "OSLanguageValues":  [
                                "en-gb",
                                "en-us"
                            ],
    "OSNameValues":  [
                            "Windows 11 24H2 x64",
                            "Windows 10 22H2 x64"
                        ],
    "OSReleaseIDValues":  [
                                "24H2",
                                "22H2"
                            ],
    "OSVersionValues":  [
                            "Windows 11",
                            "Windows 10"
                        ],
    "ClearDiskConfirm":  false,
    "restartComputer":  true,
    "updateDiskDrivers":  true,
    "updateFirmware":  true,
    "updateNetworkDrivers":  true,
    "updateSCSIDrivers":  true
}
'@

    # Write the JSON to the file (will overwrite if it exists because of -Force)
    $osdCloudConfig | Out-File -FilePath "X:\Windows\TEMP\Start-OSDCloudGUI.json" -Encoding utf8 -Force
    
    # Verify the file was created/updated
    if (Test-Path -Path "X:\Windows\TEMP\Start-OSDCloudGUI.json") {
        Write-Host "JSON configuration has been successfully deployed to X:\Windows\TEMP\Start-OSDCloudGUI.json" -ForegroundColor Green
        Write-Host "Any existing file was overwritten." -ForegroundColor Green
    } else {
        Write-Host "Failed to deploy JSON configuration" -ForegroundColor Red
    }

    #Start OSDCloudGUI
    Start-Process powershell -ArgumentList "-Command Start-OSDCloudGUI"

    
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
    #Load everything needed to run AutoPilot and Azure KeyVault
    osdcloud-StartOOBE -Display -Language -DateTime -Autopilot -KeyVault -InstallWinGet -WinGetUpgrade -WinGetPwsh
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion

#region Windows
if ($WindowsPhase -eq 'Windows') {
    #Load OSD and Azure stuff
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
