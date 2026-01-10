<h1 align="center">
   PowerBash - Cross-Platform System Utility Scripts
</h1>

A unified system administration scripts providing essential utilities for both Windows (PowerShell) and Linux (Bash). PowerBash offers process management, system health monitoring, disk space checking, file operations, IP geolocation lookup, network statistics, and backup functionality, all from a single, easy-to-use menu interface.

**Current Version:** 1.0.0
**Supported Platforms:** Windows 10+, Linux (Ubuntu, Debian, etc.)

---

## Overview

PowerBash is a system administration script designed to streamline common management task while maintaining consistent functionality across Windows and Linux environments.

### Key Highlights

- **Cross-Platform**: Unified interface for Windows and Linux
- **Logging**: All operations logged with timestamps
- **Error Handling**: Comprehensive error messages and recovery
- **Color-Coded Output**: Easy-to-read console output with color coding
- **User-Friendly**: Interactive menu-driven interface

---

## Requirements

### Windows (PowerShell Version)

| Requirement | Details |
|------------|---------|
| Operating System | Windows 10/11 or later |
| PowerShell | Version 5.1 or later (5.1 included in Windows 10+) |
| Administrative Privileges | Required (admin account or RunAsAdministrator) |
| qpdf | Optional - only needed for PDF password protection |
| Internet Connection | Required for IP geolocation lookup |

**Optional Dependency:**
- **qpdf**: For PDF password protection
  - Install via Chocolatey: `choco install qpdf`
  - Download from: https://github.com/qpdf/qpdf/releases

### Linux (Bash Version)

| Requirement | Details |
|------------|---------|
| Operating System | Ubuntu 18.04+, Debian 10+, or equivalent |
| Bash | Version 4.0 or later (usually pre-installed) |
| Root/Sudo Access | Required for most operations |
| Standard Utilities | curl, zip, coreutils (usually pre-installed) |
| Internet Connection | Required for IP geolocation lookup |

**Required Commands (Usually Pre-installed):**
```bash
# Check if utilities are available
which bash curl zip sha256sum df top pgrep kill
```

---

## Installation

### Windows Installation

#### Step 1: Clone Repository
```powershell
# Using Git
git clone https://github.com/CyberForgeEx/PowerBash.git
cd PowerBash
```

#### Step 2: Set Execution Policy
```powershell
# Run PowerShell as Administrator, then:
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

#### Step 3: (Optional) Install qpdf for PDF Protection
```powershell
# Using Chocolatey (if installed)
choco install qpdf

# Or manually download and add to PATH
# https://github.com/qpdf/qpdf/releases
```

#### Step 4: Run the Script
```bash
# Open PowerShell as Administrator
# Navigate to script directory
cd C:\path\to\PowerBash

# Execute the script
.\script.ps1
```

### Linux Installation

#### Step 1: Clone Repository
```bash
git clone https://github.com/CyberForgeEx/PowerBash.git
cd PowerBash
```

#### Step 2: Make Script Executable
```bash
chmod +x script.sh
```

#### Step 3: Verify Dependencies
```bash
# These should already be installed on most systems
sudo apt-get update
sudo apt-get install -y curl zip coreutils
```

#### Step 4: Run the Script
```bash
sudo ./script.sh
```

---

## Usage

### Starting the Script

**Windows:**
```powershell
# Open PowerShell as Administrator
cd C:\path\to\PowerBash
.\script.ps1
```

**Linux:**
```bash
cd /path/to/PowerBash
sudo ./script.sh
```

### Interactive Menu

Both versions display an identical menu:

```
=== System Utility Script ===
1. Kill Process
2. System Health Check
3. Free Space Monitoring
4. Retrieve File Hash
5. IP Location Lookup
6. Get Network Stats
7. Backup Files
8. Exit (Windows: 9 with PDF option)
=======

Enter your choice (1-9):
```

---

## Features

### 1. Kill Process
**Description:** Terminate a running process by name  
**Usage:**
- Windows: Enter process name (e.g., `notepad`, `chrome`)
- Linux: Enter process name or partial match (e.g., `firefox`, `python`)

**Example:**
```
Enter process name to kill: notepad
[2025-01-17 14:30:00] [SUCCESS] Terminated process: notepad (PID: 1234)
```

### 2. System Health Check
**Description:** Monitor CPU and memory usage in real-time  
**Usage:** Select option 2, no additional input required

**Example Output:**
```
[2025-01-17 14:30:15] [SUCCESS] CPU Usage: 28%
[2025-01-17 14:30:15] [SUCCESS] Memory Usage: 42.50% (8.50 GB used of 20 GB)
```

### 3. Free Space Monitoring
**Description:** Check available disk space and receive warnings  
**Usage:**
- Windows: Enter drive letter (C:, D:, etc.)
- Linux: Enter mount point (/, /home, /var, etc.)

**Example:**
```
Enter mount point to check (default: /): /home
[2025-01-17 14:30:30] [SUCCESS] Mount Point: /home - Free Space: 256G / Total: 512G
```

**Warning Threshold:** Alerts if free space < 30 GB

### 4. Retrieve File Hash
**Description:** Calculate SHA256 hash of any file for integrity verification  
**Usage:** Enter complete file path

**Example:**
```
Enter file path for hash calculation: /home/user/documents/file.pdf
[2025-01-17 14:30:45] [SUCCESS] File: /home/user/documents/file.pdf
[2025-01-17 14:30:45] [SUCCESS] SHA256 Hash: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

### 5. IP Location Lookup
**Description:** Retrieve geolocation data using ip-api.com (free API)  
**Usage:** Enter any valid IP address

**Example:**
```
Enter IP address for location lookup: 8.8.8.8
[2025-01-17 14:30:60] [SUCCESS] IP: 8.8.8.8
[2025-01-17 14:30:60] [SUCCESS] Location: Ashburn, Virginia, United States
[2025-01-17 14:30:60] [SUCCESS] ISP: Google LLC
[2025-01-17 14:30:60] [SUCCESS] Longitude and Latitude: -77.50, 39.03
```

**Data Provided:**
- Country, City, State/Region
- ISP and Organization
- GPS Coordinates (Latitude/Longitude)

### 6. Get Network Stats
**Description:** View active network interfaces and statistics  
**Usage:** Select option 6, no additional input required

**Windows Output:**
```
Network Adapter: Ethernet
Status: Up
Bytes Sent: 123.45 MB
Bytes Received: 567.89 MB
```

**Linux Output:**
```
Network Interfaces: eth0, lo, wlan0
Interface: eth0
  Stats: RX packets:1234 RX bytes:567890 TX packets:5678 TX bytes:123456
```

### 7. Backup Files
**Description:** Create ZIP compressed backups with automatic timestamps  
**Usage:** Enter source path and optional destination path

**Example:**
```
Enter source path to backup: /home/user/documents
Enter backup destination (default: ~/Backups/backup_<timestamp>.zip): /mnt/backup
[2025-01-17 14:31:15] [SUCCESS] Backup created: /mnt/backup/backup_20250117_143115.zip
```

**Features:**
- Automatic timestamp generation
- Creates destination directories automatically
- Compresses to ZIP format
- Cross-platform compatible

### 8. PDF Password Protection (Windows Only)
**Description:** Encrypt PDF files with AES-256 encryption  
**Usage:** Enter PDF file path and desired password

**Example:**
```
Enter full path to PDF file: C:\Documents\report.pdf
Enter password for PDF: ****
[2025-01-17 14:31:30] [SUCCESS] PDF protected: C:\Documents\report_protected.pdf
```

**Notes:**
- Creates new file with "_protected" suffix
- Original file remains unchanged
- Requires qpdf to be installed
- Not available on Linux version

---

## Functions Reference

### Windows (PowerShell)

| Function | Purpose | Type |
|----------|---------|------|
| `Test-Admin` | Verify administrative privileges | Helper |
| `Write-Log` | Log messages with timestamps | Helper |
| `Kill-Process` | Terminate process by name | Core |
| `Get-SystemHealth` | Monitor CPU/Memory | Monitoring |
| `Get-FreeSpace` | Check disk space | Monitoring |
| `Get-FileHashValue` | Calculate SHA256 hash | File Ops |
| `Get-IPInfo` | IP geolocation lookup | Network |
| `Get-NetworkStats` | Network interface stats | Network |
| `Backup-Files` | Create ZIP backups | Backup |
| `Protect-PDF` | Encrypt PDF with password | File Ops |
| `Show-Menu` | Display menu interface | UI |

### Linux (Bash)

| Function | Purpose | Type |
|----------|---------|------|
| `check_root` | Verify root/sudo privileges | Helper |
| `write_log` | Log messages with timestamps | Helper |
| `command_exists` | Check if command is available | Helper |
| `kill_process` | Terminate process by name | Core |
| `get_system_health` | Monitor CPU/Memory | Monitoring |
| `get_free_space` | Check disk space | Monitoring |
| `get_file_hash` | Calculate SHA256 hash | File Ops |
| `get_ip_info` | IP geolocation lookup | Network |
| `get_network_stats` | Network interface stats | Network |
| `backup_files` | Create ZIP backups | Backup |
| `show_menu` | Display menu interface | UI |

---

## Logging

All operations are logged to timestamped log files for auditing and troubleshooting.

### Log Location

**Windows:**
```
..\Logs\POWERBASH_YYYYMMDD.log
```

**Linux:**
```
../Logs/POWERBASH_YYYYMMDD.log
```

### Log Format

```
[YYYY-MM-DD HH:MM:SS] [LEVEL] Message
[2025-01-17 14:30:00] [INFO] PowerBash Utility Script started on Windows
[2025-01-17 14:30:15] [SUCCESS] Terminated process: notepad (PID: 1234)
[2025-01-17 14:30:30] [WARNING] Free space is below 30GB!
[2025-01-17 14:30:45] [ERROR] File not found: C:\nonexistent\file.txt
```

### Log Levels

- **[INFO]**: Informational messages (Cyan)
- **[SUCCESS]**: Successful operations (Green)
- **[WARNING]**: Warning messages (Yellow)
- **[ERROR]**: Error messages (Red)

---

## Performance Benchmarks

| Operation | Duration | Impact |
|-----------|----------|--------|
| System Health Check | < 1 second | Minimal |
| Free Space Check | < 1 second | Minimal |
| File Hash (small file) | 1-2 seconds | Minimal |
| File Hash (large file) | Variable | IO intensive |
| IP Geolocation | 2-3 seconds | Network dependent |
| Network Stats | < 1 second | Minimal |
| Backup (small files) | 1-5 seconds | CPU/IO intensive |
| Backup (large files) | Variable | CPU/IO intensive |

---

## Security Considerations

- **Admin/Root Required**: Scripts require elevated privileges for system operations
- **PDF Encryption**: Uses AES-256 (Windows only), industry-standard encryption
- **API Security**: IP geolocation uses HTTPS (SSL/TLS) by default
- **Local Processing**: Most operations process data locally without external services
- **Log Files**: Contain operation history; store securely
- **Password Handling**: Always use secure input for sensitive data

---

## Limitations

| Limitation | Impact | Workaround |
|-----------|--------|-----------|
| Process termination fails if OS-protected | Cannot kill system processes | Use Task Manager or approved methods |
| IP geolocation requires internet | No lookup without connection | Ensure internet connectivity |
| Large file operations are slow | Backup of 10GB+ takes time | Use background execution |
| Network stats vary by OS | Different format on Windows/Linux | Reference OS-specific output |
| PDF protection requires qpdf | Feature unavailable without tool | Install qpdf for Windows |

---

## Platform Comparison

| Feature | Windows | Linux |
|---------|---------|-------|
| Kill Process | ✅ | ✅ |
| System Health | ✅ | ✅ |
| Disk Space Check | ✅ | ✅ |
| File Hash |  ✅ | ✅ |
| IP Geolocation | ✅ | ✅ |
| Network Stats | ✅ | ✅ |
| Backup Files | ✅ | ✅  |
| PDF Protection | ✅ Yes* | ❌ No |

*Requires qpdf installation

---

## File Structure

```
PowerBash/
├── script.ps1              # Windows PowerShell version
├── script.sh               # Linux Bash version
├── README.md               # This file
├── LICENSE                 # MIT License
└── Logs/                   # Log directory (created automatically)
    └── POWERBASH*.log   # Daily log files
```

---

## License

This script is provided under the MIT License. See [LICENSE](LICENSE) for details.

---

## Support

### Reporting Bugs

When reporting issues, please include:
- Operating System and version
- PowerShell/Bash version
- Error message or log excerpt
- Steps to reproduce
- Expected vs. actual behavior

---

## Examples & Use Cases

### Use Case 1: System Maintenance Routine
```bash
# Linux example
sudo ./script.sh

# Select Option 2: System Health Check
# Select Option 3: Free Space Monitoring on /
# Select Option 6: Get Network Stats
```

### Use Case 2: File Verification
```powershell
# Windows example
.\script.ps1

# Select Option 5: Retrieve File Hash
# Enter file path to verify integrity
# Compare hash with expected value
```

### Use Case 3: Automated Daily Backup
```bash
# Add to crontab for daily execution
0 22 * * * /home/user/PowerBash/script.sh << EOF
7
/home/user/documents
/mnt/backup
EOF
```

### Use Case 4: Network Diagnostics
```powershell
# Windows troubleshooting
.\script.ps1

# Select Option 6: Get Network Stats
# Select Option 5: IP Location Lookup with 8.8.8.8
# Check ISP and location information
```

### Use Case 5: Process Management
```bash
# Linux process termination
sudo ./script.sh

# Select Option 1: Kill Process
# Enter process name: firefox
# Automatic process termination
```

---

## Performance Optimization Tips

### For Windows Users
1. **Exclude from antivirus**: Add script directory to antivirus exceptions
2. **Run during off-hours**: Schedule backups during low-activity periods
3. **Use SSD for backups**: Faster compression and file operations

### For Linux Users
1. **Use local storage**: Network backups are slower
2. **Monitor disk usage**: Use `df` to prevent backup failures
3. **Compress before backup**: Consider using tar with gzip for efficiency

---

## Configurations

### Modifying Log Location

**Windows:**
Edit `script.ps1` and change:
```powershell
$logFile = "C:\custom\path\POWERBASH_$(Get-Date -Format 'yyyyMMdd').log"
```

**Linux:**
Edit `script.sh` and change:
```bash
LOG_DIR="/custom/log/path"
```

### Changing Backup Directory

**Windows:**
```powershell
# Modify default backup path
$BackupPath = "D:\MyBackups\Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
```

**Linux:**
```bash
# Modify default backup directory
BACKUP_DIR="/mnt/custom/backup/path"
```

### Custom Logging Format

**Windows:**
Modify the `Write-Log` function to customize output format

**Linux:**
Modify the `write_log` function to customize output format

---

### Tested Configurations

**Windows:**
- Windows 10 Pro (Build 22H2)
- Windows 11 Home
- PowerShell 5.1 and 7.x

**Linux:**
- Ubuntu 20.04 LTS
- Debian 10 and 11
- Bash 4.0+

---

## Acknowledgments

- **Inspiration**: System administration best practices
- **ip-api.com**: Free geolocation API service

---

## Related Resources

### Documentation
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [qpdf Documentation](https://qpdf.readthedocs.io/)

### Tutorials
- [PowerShell Scripting Guide](https://docs.microsoft.com/en-us/powershell/scripting/overview)
- [Bash Scripting Tutorial](https://www.gnu.org/software/bash/manual/bash.html)
- [Linux System Administration](https://linux.die.net/)

### Tools
- [Visual Studio Code](https://code.visualstudio.com/) - Script editor
- [GitHub](https://github.com/) - Version control

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-17 | Initial release with 8 core features |

---

## Final Notes

Thank you for using PowerBash! I hope this tool makes your system administration tasks easier. Whether you're managing a single workstation or multiple servers, PowerBash provides user-friendly interface to accomplish basic essential tasks.

---
<p align="right">
   <i>Last Updated: October 2025</i>
</br>
   <i>Maintained by: Vasan Dilaksan<i>
</p>
