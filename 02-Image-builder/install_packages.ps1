<#
.SYNOPSIS
    Azure Image Builder software installation script.
.DESCRIPTION
    This script installs various applications for Azure Image Builder
.NOTES
    Author: Gwyn
    Version: 1.0
#>

#region Configuration
$installRoot = "C:\ImageBuilder"
$logFolder = Join-Path -Path $installRoot -ChildPath "Logs"
$logFile = Join-Path -Path $logFolder -ChildPath "$((Get-Date).ToString('yyyyMMdd'))_softwareinstall.log"
$downloadFolder = Join-Path -Path $installRoot -ChildPath "Downloads"

# Application configuration
$applications = @{
    "Google Chrome" = @{
        InstallerPath = Join-Path -Path $installRoot -ChildPath "google_chrome.msi"
        InstallArgs   = @('/i', 'c:\ImageBuilder\google_chrome.msi', '/quiet')
        TestPath      = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        DownloadUrl   = "https://storageaccountname.blob.core.windows.net/packages/google_chrome.msi"
    }
    "notepad++"     = @{
        InstallerPath = Join-Path -Path $installRoot -ChildPath "notepad++.exe"
        InstallArgs   = @('/S')
        InstallerType = "EXE"
        TestPath      = "C:\Program Files\Notepad++\notepad++.exe"
        DownloadUrl   = "https://storageaccountname.blob.core.windows.net/packages/notepad++.exe"
    }
    "RSAT"          = @{
        InstallerPath = Join-Path -Path $installRoot -ChildPath "rsat.msu"
        InstallArgs   = @('/quiet', '/norestart')
        InstallerType = "MSU"
        TestPath      = "C:\Windows\System32\dsa.msc"
        DownloadUrl   = "https://storageaccountname.blob.core.windows.net/packages/rsat.msu"
    }
    # Add more applications as needed in the same format
}
#endregion

#region Functions
function Initialize-Environment {
    [CmdletBinding()]
    param()
    
    # First create the root installation directory
    if (-not (Test-Path -Path $installRoot)) {
        New-Item -Path $installRoot -ItemType Directory -Force | Out-Null
        Write-Host "Created installation root directory at $installRoot"
    }
    
    # Create log directory
    if (-not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
        Write-Host "Created log directory at $logFolder"
    }
    
    # Create log file if it doesn't exist
    if (-not (Test-Path -Path $logFile)) {
        $null = New-Item -Path $logFile -ItemType File -Force
        Write-Host "Created log file at $logFile"
    }
    
    # Create download directory
    if (-not (Test-Path -Path $downloadFolder)) {
        New-Item -Path $downloadFolder -ItemType Directory -Force | Out-Null
        Write-Host "Created download directory at $downloadFolder"
    }
    
    # Now that all directories exist and the log file is created, we can start logging
    Write-Host "Environment initialization completed" -ForegroundColor Green
}

function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('Information', 'Warning', 'Error')]
        [string]$Level = 'Information'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Output to console with color based on level
    switch ($Level) {
        'Information' { Write-Host $logEntry -ForegroundColor Green }
        'Warning' { Write-Host $logEntry -ForegroundColor Yellow }
        'Error' { Write-Host $logEntry -ForegroundColor Red }
    }
    
    # Write to log file
    $logEntry | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Download-Installer {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        
        [Parameter(Mandatory = $true)]
        [string]$DownloadUrl,
        
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )
    
    try {
        Write-Log "Downloading installer for $AppName from $DownloadUrl"
        
        # Create directory if it doesn't exist
        $downloadDir = [System.IO.Path]::GetDirectoryName($DestinationPath)
        if (-not (Test-Path -Path $downloadDir)) {
            New-Item -Path $downloadDir -ItemType Directory -Force | Out-Null
        }
        
        # Download the file
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($DownloadUrl, $DestinationPath)
        
        if (Test-Path -Path $DestinationPath) {
            Write-Log "Successfully downloaded installer for $AppName to $DestinationPath"
            return $true
        }
        else {
            Write-Log "Failed to download installer for $AppName" -Level Error
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error downloading installer for ${AppName}: ${errorMessage}" -Level Error
        return $false
    }
}

function Install-Application {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$AppName,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$AppConfig
    )
    
    Write-Log "Starting installation of $AppName"
    
    try {
        # Check if application is already installed
        if (Test-Path -Path $AppConfig.TestPath) {
            Write-Log "$AppName is already installed at $($AppConfig.TestPath)"
            return $true
        }
        
        # Verify installer exists, if not, try to download it
        if (-not (Test-Path -Path $AppConfig.InstallerPath)) {
            Write-Log "Installer for $AppName not found at $($AppConfig.InstallerPath)" -Level Warning
            
            # Check if we have a download URL
            if ($AppConfig.ContainsKey('DownloadUrl') -and $AppConfig.DownloadUrl) {
                Write-Log "Attempting to download installer from $($AppConfig.DownloadUrl)"
                $downloadSuccess = Download-Installer -AppName $AppName -DownloadUrl $AppConfig.DownloadUrl -DestinationPath $AppConfig.InstallerPath
                
                if (-not $downloadSuccess) {
                    Write-Log "Unable to download installer for $AppName. Installation aborted." -Level Error
                    return $false
                }
            }
            else {
                Write-Log "No download URL provided for $AppName. Installation aborted." -Level Error
                return $false
            }
        }
        
        # Install the application
        if ($AppConfig.ContainsKey('InstallerType') -and $AppConfig.InstallerType -eq 'EXE') {
            $process = Start-Process -FilePath $AppConfig.InstallerPath -ArgumentList $AppConfig.InstallArgs -Wait -PassThru -ErrorAction Stop
        }
        elseif ($AppConfig.ContainsKey('InstallerType') -and $AppConfig.InstallerType -eq 'MSU') {
            $msuArgs = @($AppConfig.InstallerPath) + $AppConfig.InstallArgs
            $process = Start-Process -FilePath wusa.exe -ArgumentList $msuArgs -Wait -PassThru -ErrorAction Stop
        }
        else {
            $process = Start-Process -FilePath msiexec.exe -ArgumentList $AppConfig.InstallArgs -Wait -PassThru -ErrorAction Stop
        }
        
        if ($process.ExitCode -ne 0) {
            Write-Log "$AppName installation failed with exit code $($process.ExitCode)" -Level Error
            return $false
        }
        
        # Verify installation
        if (Test-Path -Path $AppConfig.TestPath) {
            Write-Log "$AppName has been successfully installed"
            return $true
        }
        else {
            Write-Log "Error locating the $AppName executable at $($AppConfig.TestPath)" -Level Warning
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error installing ${AppName}: ${errorMessage}" -Level Error
        return $false
    }
}
#endregion

#region Main
try {
    # Initialize environment first before any logging
    Initialize-Environment
    
    # Now we can safely use Write-Log
    Write-Log "Beginning software installation process"
    
    # Install each application
    foreach ($app in $applications.Keys) {
        $result = Install-Application -AppName $app -AppConfig $applications[$app]
        if ($result) {
            Write-Log "$app installation completed successfully"
        }
        else {
            Write-Log "$app installation failed" -Level Warning
        }
    }
    
    Write-Log "Software installation process completed"
}
catch {
    # If we hit an error before log initialization, write to console instead
    if (-not (Test-Path -Path $logFile)) {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
    else {
        Write-Log "An unexpected error occurred during the installation process: $($_.Exception.Message)" -Level Error
    }
    exit 1
}
#endregion