<#PSScriptInfo
Script should be executed in a Command Prompt within WinPE using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri osdcloud.codoit.com.au)
This is abbreviated as
powershell iex (irm osdcloud.codoit.com.au)
#>

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
        $configureOSDCloudGUI = @'
Import-Module OSD -Force
Start-Sleep -Seconds 1
$OSDModuleResource.StartOSDCloudGUI.ClearDiskConfirm = $false
Start-OSDCloudGUI
'@

    #Start OSDCloudGUI
    Start-Process powershell "-Command", $configureOSDCloudGUI
    
    #Stop the startup Transcript.  OSDCloud will create its own
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
