# System Utility Script

## Overview
This PowerShell script provides a collection of system administration utilities for Windows, including process management, system health monitoring, disk space checking, PDF password protection, file hash calculation, and IP geolocation lookup. The script requires administrative privileges to run.

## Requirements
- **Operating System**: Windows
- **PowerShell**: Version 5.1 or later
- **Administrative Privileges**: Required for process termination and system health checks
- **qpdf**: Required for PDF password protection (install via `choco install qpdf` or similar package manager)
- **Internet Access**: Required for IP geolocation lookup through API.

## Features
1. **Kill Process**: Terminate a specified process by name.
2. **System Health Check**: Monitor CPU and memory usage.
3. **Free Space Monitoring**: Check free disk space for a specified drive and warn if below 30 GB.
4. **PDF Password Protection**: Encrypt a PDF file with a user-provided password using qpdf.
5. **Retrieve File Hash**: Calculate the SHA256 hash of a specified file.
6. **IP Location Lookup**: Retrieve geolocation information for a given IP address using the ip-api.com API.

## Installation
1. Save the script as `SystemUtility.ps1`.
2. Install qpdf for PDF password protection:
   - Using Chocolatey: `choco install qpdf`
   - Or download from [qpdf releases](https://github.com/qpdf/qpdf/releases).
3. Ensure PowerShell execution policy allows running scripts:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   ```

## Usage
1. Clone the repository
   ```bash
    git clone https://github.com/CyberForgeEx/PSMultiTool.git
   ```
1. Run PowerShell as Administrator.
2. Navigate to the script's directory:
   ```powershell
   cd PSMultiTool
   ```
3. Execute the script:
   ```powershell
   .\SystemUtility.ps1
   ```
4. Follow the interactive menu to select an option (1-7):
   - **1**: Enter a process name (e.g., `notepad`) to terminate.
   - **2**: View CPU and memory usage.
   - **3**: Specify a drive letter with semicolon (e.g., `C:`) to check free space.
   - **4**: Provide a PDF file path and password to protect the file.
   - **5**: Enter a file path to calculate its SHA256 hash.
   - **6**: Input an IP address for geolocation info lookup.
   - **7**: Exit the script.

## Functions
- `Test-Admin`: Checks if the script is running with administrative privileges.
- `Kill-Process`: Terminates processes by name.
- `Get-SystemHealth`: Retrieves CPU and memory usage statistics.
- `Get-FreeSpace`: Monitors disk space for a specified drive.
- `Protect-PDF`: Encrypts a PDF file with a password using qpdf.
- `Get-FileHashValue`: Calculates the SHA256 hash of a file.
- `Get-IPInfo`: Queries ip-api.com for IP geolocation data.

## Notes
- The script uses `Get-CimInstance` for system health and disk space checks, which is more reliable than older PS cmdlets.
- PDF protection requires qpdf to be installed and accessible in the system PATH.
- The IP location lookup uses a free API (ip-api.com) and requires internet connectivity.
- Error handling is implemented for all functions to provide meaningful feedback.

## Example
```powershell

== System Utility Script ==
1. Kill Process
2. System Health Check
3. Free Space Monitoring
4. PDF Password Protection
5. Retrieve File Hash
6. IP Location Lookup
7. Exit

Enter your choice (1-7): 2
CPU Usage: 11%
Memory Usage: 50.41% (15.69 GB free of 31.64 GB)

Press Enter to continue...

== System Utility Script ==
1. Kill Process
2. System Health Check
3. Free Space Monitoring
4. PDF Password Protection
5. Retrieve File Hash
6. IP Location Lookup
7. Exit

Enter your choice (1-7): 7
Exiting script...
```

## About
This script was created as a fun project to explore PowerShell's capabilities while exploring tools for system administration. I enjoy experimenting with code to make routine tasks more engaging, and this script is a result of that. Whether you're a sysadmin or just curious, I hope you find this tool as fun to use as it was to create!

## License
This script is provided under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing
Contributions are welcome! Please submit a pull request or open an issue on the repository.