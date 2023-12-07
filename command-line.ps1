# URL of the Dell Command Update installer
$installerUrl = 'https://www.dell.com/support/home/en-us/drivers/DriversDetails?driverId=44TH5'

# Path to save the downloaded installer
$downloadPath = 'C:\Downloads\DellCommandUpdate.msi'

# Download the installer
$UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
Invoke-WebRequest -Uri $installerUrl -OutFile $downloadPath -Headers @{ 'User-Agent' = $UserAgent }

# Check if DellCommandUpdate.exe is running
if (Get-Process -Name "DellCommandUpdate" -ErrorAction SilentlyContinue) {
    Write-Host "Closing existing Dell Command Update"
    Stop-Process -Name "DellCommandUpdate" -Force
}

# Function to install Dell Command Update app
function Install-DellUpdater {
    param (
        [string]$FilePath
    )
    Write-Host "Installing Dell Command Update app"
    Start-Process -FilePath $FilePath -ArgumentList "/quiet" -Wait
}

# Function to run Dell Command Update app
# HKLM:\... abbreviation refers to the "HKEY_LOCAL_MACHINE" hive in the Windows Registry. 
function Run-DellUpdater {
    Write-Host "Disabling Dell automatic updates"
    New-Item -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\Schedule" -Name "ScheduleMode" -Value "ManualUpdates" -Force

    Write-Host "Running the Dell Command Update app"
    Start-Process -FilePath "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/ApplyUpdates" -Wait
}

# Check if dcu-cli.exe exists in Program Files\Dell\CommandUpdate
if (Test-Path "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe") {
    Run-DellUpdater
} elseif (Test-Path $downloadPath) {
    Install-DellUpdater -FilePath $downloadPath
} else {
    Write-Host "Failed to download Dell Command Update."
}

Pause
