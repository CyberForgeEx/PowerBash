#Requires -RunAsAdministrator

# Import required modules
Import-Module -Name Microsoft.PowerShell.Management -ErrorAction SilentlyContinue
Import-Module -Name Microsoft.PowerShell.Utility -ErrorAction SilentlyContinue

# checking if running as admin 
function Test-Admin {
    # getting the current powershell session privilege using windows builtin administrator module. 
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# write log function to process output and write to log file.
function Write-Log {
    param (
        [string]$Message,
        [string]$LogLevel = "INFO"
    )
        $logFile = "..\Logs\PSMULTITOOL_$(Get-Date -Format 'yyyyMMdd').log"
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$LogLevel] $Message"
        if (-not (Test-Path (Split-Path $logFile))) {
            New-Item -ItemType Directory -Path (Split-Path $logFile) -Force | Out-Null
        }
        Add-Content -Path $logFile -Value $logMessage
        switch ($LogLevel) {
            "ERROR" { Write-Host $logMessage -ForegroundColor Red }
            "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
            default { Write-Host $logMessage -ForegroundColor Green }
        }

}

# Function to kill a process by name process name
function Kill-Process {
    param (
        [string]$ProcessName
    )
    try {
        $processes = Get-Process -Name $ProcessName -ErrorAction Stop
        if ($processes) {
            foreach ($process in $processes) {
                Stop-Process -Id $process.Id -Force -ErrorAction Stop
                Write-Log "Terminated process: $($process.Name) (PID: $($process.Id))" 
            }
        } else {
            Write-Log "No process found with name: $ProcessName" -LogLevel "ERROR"
        }
    } catch {
        Write-Log "Error terminating process: $_" -LogLevel "ERROR"
    }
}

# Function for system health checks for CPU and Memory
function Get-SystemHealth {
    try {
        # query disk information across different Windows versions.
        $cpu = Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage
        $memory = Get-CimInstance Win32_OperatingSystem
        # Rounding off two decimal places using .NET System.Math Class.
        $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
        $freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
        $usedMemoryPercent = [math]::Round((($totalMemory - $freeMemory) / $totalMemory) * 100, 2)

        Write-Log "CPU Usage: $cpu%"
        Write-Log "Memory Usage: $usedMemoryPercent% ($freeMemory GB free of $totalMemory GB)"
    } catch {
        Write-Log "Error retrieving system health: $_" -LogLevel "ERROR"
    }
}

#function get free disk space the accroding to the specific partion
function Get-FreeSpace {
    param (
        [string]$DriveLetter = "C:"
    )
    try {
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$DriveLetter'" -ErrorAction Stop 
        $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
        $totalSpaceGB = [math]::Round($disk.Size / 1GB, 2)
        $thresholdGB = 30

        Write-Log "Drive $DriveLetter - Free Space: $freeSpaceGB GB / Total: $totalSpaceGB GB"
        if ($freeSpaceGB -lt $thresholdGB) {
            Write-Log "Warning: Free space is below $thresholdGB GB!" -LogLevel "WARNING"
        }
    } catch {
        Write-Log "Error checking disk space: $_" -LogLevel "ERROR"
    }
}

# Function for PDF password protection using QPDF 
function Protect-PDF {
    param (
        [string]$FilePath,
        [string]$Password
    )
    try {
        if (-not (Test-Path $FilePath)) {
            Write-Log "PDF file not found: $FilePath" -LogLevel "ERROR"
            return
        }
        # the below code creates a copy of the password protected and encrypted pdf file based on AES-256.
        $outputFile = $FilePath -replace '\.pdf$', '_protected.pdf'
        & qpdf --encrypt $Password $Password 256 -- $FilePath $outputFile
        if ($LASTEXITCODE -eq 0) {
            Write-Log "PDF protected successfully: $outputFile" 
        } else {
            Write-Log "Failed to protect PDF" 
        }
    } catch {
        Write-Log "Error protecting PDF: $_" -LogLevel "ERROR"
    }
}

# Function to retrieve file hash using default cmdlet.
function Get-FileHashValue {
    param (
        [string]$FilePath
    )
    try {
        if (-not (Test-Path $FilePath)) {
            Write-Log "File not found: $FilePath"
            return
        }
        $hash = Get-FileHash -Path $FilePath -Algorithm SHA256 -ErrorAction Stop
        Write-Log "File: $FilePath"
        Write-Log "SHA256 Hash: $($hash.Hash)"
    } catch {
        Write-Log "Error calculating file hash: $_" -LogLevel "ERROR"
    }
}

# Function for get IP Info lookup using a free API (ip-api)
function Get-IPInfo {
    param (
        [string]$IPAddress
    )
    try {
        $response = Invoke-RestMethod -Uri "http://ip-api.com/json/$IPAddress" -ErrorAction Stop
        if ($response.status -eq "success") {
            Write-Log "IP: $IPAddress"
            Write-Log "Status: $($response.status)"
            Write-Log "Location: $($response.city), $($response.regionName), $($response.country)"
            Write-Log "ISP: $($response.isp)"
            Write-Log "Organisation: $($response.org)"
            Write-Log "Longitude and Latitude Based on IP: $($response.lon), $($response.lat)"
        } else {
            Write-Log "Failed to retrieve location for IP: $IPAddress" -LogLevel "ERROR"
        }
    } catch {
        Write-Log "Error fetching IP location: $_" -LogLevel "ERROR"
    }
}

# Function to get live network stats
function Get-NetworkStats {
    try {
        $adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            $stats = Get-NetAdapterStatistics -Name $adapter.Name
            Write-Log "Network Adapter: $($adapter.Name)" -LogLevel "INFO"
            Write-Log "Status: $($adapter.Status)" -LogLevel "INFO"
            Write-Log "Bytes Sent: $([math]::Round($stats.SentBytes / 1MB, 2)) MB" -LogLevel "INFO"
            Write-Log "Bytes Received: $([math]::Round($stats.ReceivedBytes / 1MB, 2)) MB" -LogLevel "INFO"
        }
    } catch {
        Write-Log "Error retrieving network stats: $_" -LogLevel "ERROR"
    }
}

# Function to backup files
function Backup-Files {
    param (
        [string]$SourcePath,
        [string]$BackupPath = "C:\Backups\Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    )
    try {
        if (-not (Test-Path $SourcePath)) {
            Write-Log "Source path not found: $SourcePath" -LogLevel "ERROR"
            return
        }
        if (-not (Test-Path (Split-Path $BackupPath))) {
            New-Item -ItemType Directory -Path (Split-Path $BackupPath) -Force | Out-Null
        }
        Compress-Archive -Path $SourcePath -DestinationPath $BackupPath -Force
        Write-Log "Backup created: $BackupPath" -LogLevel "INFO"
    } catch {
        Write-Log "Error creating backup: $_" -LogLevel "ERROR"
    }
}

# Menu
function Show-Menu {
    Write-Host "`n== System Utility Script ==" -ForegroundColor Cyan
    Write-Host "1. Kill Process"
    Write-Host "2. System Health Check"
    Write-Host "3. Free Space Monitoring"
    Write-Host "4. PDF Password Protection"
    Write-Host "5. Retrieve File Hash"
    Write-Host "6. IP Location Lookup"
    Write-Host "7. Get Network Stats"
    Write-Host "8. Backup Files"
    Write-Host "9. Exit"
    Write-Host "`nEnter your choice (1-9): " -NoNewline
}

#logic to check privilege.
if (-not (Test-Admin)) {
    Write-Log "`nThis script requires administrative privileges. Please run as Administrator." -LogLevel "ERROR"
    exit
}

while ($true) {
    Show-Menu
    $choice = Read-Host

    switch ($choice) {
        "1" {
            $processName = Read-Host "Enter process name to kill (e.g., notepad)"
            Kill-Process -ProcessName $processName
        }
        "2" {
            Get-SystemHealth
        }
        "3" {
            $drive = Read-Host "Enter drive letter to check (default C:)"
            if (-not $drive) { $drive = "C:" }
            Get-FreeSpace -DriveLetter $drive
        }
        "4" {
            $filePath = Read-Host "Enter full path to PDF file"
            $password = Read-Host "Enter password for PDF"
            Protect-PDF -FilePath $filePath -Password $password
        }
        "5" {
            $filePath = Read-Host "Enter full path to file for hash"
            Get-FileHashValue -FilePath $filePath
        }
        "6" {
            $ipAddress = Read-Host "Enter IP address for location lookup"
            Get-IPInfo -IPAddress $ipAddress
        }
        "7" {
            Get-NetworkStats
        }
        "8"{
            $sourcePath = Read-Host "Enter source path to backup"
            $backupPath = Read-Host "Enter backup destination (default: C:\Backups\Backup_<timestamp>.zip)"
            if (-not $backupPath) { $backupPath = "C:\Backups\Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip" }
            Backup-Files -SourcePath $sourcePath -BackupPath $backupPath
        }
        "9"{
            Write-Host "Exiting script..." -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "Invalid choice. Please select 1-9." -ForegroundColor Red
        }
    }
    Write-Host "`nPress Enter to continue..."
    Read-Host
}
