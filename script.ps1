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
                Write-Host "Terminated process: $($process.Name) (PID: $($process.Id))" 
            }
        } else {
            Write-Host "No process found with name: $ProcessName"
        }
    } catch {
        Write-Host "Error terminating process: $_" -ForegroundColor Red
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

        Write-Host "CPU Usage: $cpu%" -ForegroundColor Green
        Write-Host "Memory Usage: $usedMemoryPercent% ($freeMemory GB free of $totalMemory GB)" -ForegroundColor Green
    } catch {
        Write-Host "Error retrieving system health: $_" -ForegroundColor Red
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

        Write-Host "Drive $DriveLetter - Free Space: $freeSpaceGB GB / Total: $totalSpaceGB GB"
        if ($freeSpaceGB -lt $thresholdGB) {
            Write-Host "Warning: Free space is below $thresholdGB GB!" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error checking disk space: $_" -ForegroundColor Red
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
            Write-Host "PDF file not found: $FilePath" -ForegroundColor Red
            return
        }
        # the below code creates a copy of the password protected and encrypted pdf file based on AES-256.
        $outputFile = $FilePath -replace '\.pdf$', '_protected.pdf'
        & qpdf --encrypt $Password $Password 256 -- $FilePath $outputFile
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PDF protected successfully: $outputFile" -ForegroundColor Green
        } else {
            Write-Host "Failed to protect PDF" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error protecting PDF: $_" -ForegroundColor Red
    }
}

# Function to retrieve file hash using default cmdlet.
function Get-FileHashValue {
    param (
        [string]$FilePath
    )
    try {
        if (-not (Test-Path $FilePath)) {
            Write-Host "File not found: $FilePath" -ForegroundColor Red
            return
        }
        $hash = Get-FileHash -Path $FilePath -Algorithm SHA256 -ErrorAction Stop
        Write-Host "File: $FilePath"
        Write-Host "SHA256 Hash: $($hash.Hash)"
    } catch {
        Write-Host "Error calculating file hash: $_" -ForegroundColor Red
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
            Write-Host "IP: $IPAddress"
            Write-Host "Status: $($response.status)"
            Write-Host "Location: $($response.city), $($response.regionName), $($response.country)"
            Write-Host "ISP: $($response.isp)"
            Write-Host "Organisation: $($response.org)"
            Write-Host "Longitude and Latitude Based on IP: $($response.lon), $($response.lat)"
        } else {
            Write-Host "Failed to retrieve location for IP: $IPAddress" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error fetching IP location: $_" -ForegroundColor Red
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
    Write-Host "7. Exit"
    Write-Host "`nEnter your choice (1-7): " -NoNewline
}

#logic to check privilege.
if (-not (Test-Admin)) {
    Write-Host "`nThis script requires administrative privileges. Please run as Administrator." -ForegroundColor Red
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
            Write-Host "Exiting script..." -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "Invalid choice. Please select 1-8." -ForegroundColor Red
        }
    }
    Write-Host "`nPress Enter to continue..."
    Read-Host
}