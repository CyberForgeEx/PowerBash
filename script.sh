#!/bin/bash

################################################################################
# PowerBash - System Utility Script for Linux (Bash)
# Author - Vasan Dilaksan.
# Version: 1.0
# Description: Comprehensive system administration utilities for Linux
# Requirements: Bash 4.0+, curl, zip, coreutils
################################################################################

set -o pipefail # handling execution pipeline

# Configurations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/../Logs"
LOG_FILE="${LOG_DIR}/POWERBASH_$(date +%Y%m%d).log"
BACKUP_DIR="${HOME}/Backups"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Utility Functions

# Create log directory if it doesn't exist
create_log_dir() {
    if [[ ! -d "$LOG_DIR" ]]; then
        mkdir -p "$LOG_DIR" 2>/dev/null || {
            echo "Warning: Could not create log directory. Logs will not be saved."
            LOG_FILE="/dev/null"
        }
    fi
}

# Write log with timestamp and level
write_log() {
    local message="$1"
    local level="${2:-INFO}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_message="[$timestamp] [$level] $message"
    
    # Determine color based on log level
    local color="$GREEN"
    case "$level" in
        ERROR)   color="$RED" ;;
        WARNING) color="$YELLOW" ;;
        INFO)    color="$CYAN" ;;
        SUCCESS) color="$GREEN" ;;
    esac
    
    # Output to console
    echo -e "${color}${log_message}${NC}"
    
    # Append to log file
    echo "$log_message" >> "$LOG_FILE" 2>/dev/null
}

# Check if running with sudo/root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        write_log "This script requires root privileges. Please run with sudo." ERROR
        exit 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Process Management

kill_process() {
    local process_name="$1"
    
    if [[ -z "$process_name" ]]; then
        write_log "Process name cannot be empty" ERROR
        return
    fi
    
    local pids=$(pgrep -f "$process_name")
    
    if [[ -z "$pids" ]]; then
        write_log "No process found with name: $process_name" ERROR
        return
    fi
    
    echo "$pids" | while read -r pid; do
        if kill -9 "$pid" 2>/dev/null; then
            local process_info=$(ps -p "$pid" -o comm= 2>/dev/null || echo "$process_name")
            write_log "Terminated process: $process_info (PID: $pid)" SUCCESS
        else
            write_log "Could not terminate process with PID: $pid" WARNING
        fi
    done
}

# System Monitoring

get_system_health() {
    write_log "Fetching system health information..." INFO
    
    # Get CPU usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)
    
    # Get memory usage
    local mem_info=$(free -b | grep Mem)
    local total_mem=$(echo "$mem_info" | awk '{printf "%.2f", $2 / (1024^3)}')
    local used_mem=$(echo "$mem_info" | awk '{printf "%.2f", $3 / (1024^3)}')
    local mem_percent=$(echo "$mem_info" | awk '{printf "%.2f", ($3 / $2) * 100}')
    
    write_log "CPU Usage: ${cpu_usage}%" SUCCESS
    write_log "Memory Usage: ${mem_percent}% (${used_mem} GB used of ${total_mem} GB)" SUCCESS
}

get_free_space() {
    local mount_point="${1:-.}"
    
    if [[ -z "$mount_point" ]]; then
        write_log "Mount point cannot be empty" ERROR
        return
    fi
    
    if [[ ! -d "$mount_point" ]]; then
        write_log "Mount point does not exist: $mount_point" ERROR
        return
    fi
    
    local disk_info=$(df -BG "$mount_point" | tail -1)
    local free_space=$(echo "$disk_info" | awk '{print $4}' | sed 's/G//')
    local total_space=$(echo "$disk_info" | awk '{print $2}' | sed 's/G//')
    local threshold=30
    
    write_log "Mount Point: $mount_point - Free Space: ${free_space}G / Total: ${total_space}G" SUCCESS
    
    if [[ $free_space -lt $threshold ]]; then
        write_log "Warning: Free space is below ${threshold}GB!" WARNING
    fi
}

# File Operations

get_file_hash() {
    local file_path="$1"
    
    if [[ -z "$file_path" ]]; then
        write_log "File path cannot be empty" ERROR
        return
    fi
    
    if [[ ! -f "$file_path" ]]; then
        write_log "File not found: $file_path" ERROR
        return
    fi
    
    if ! command_exists sha256sum; then
        write_log "sha256sum command not found" ERROR
        return
    fi
    
    local hash=$(sha256sum "$file_path" | awk '{print $1}')
    write_log "File: $file_path" SUCCESS
    write_log "SHA256 Hash: $hash" SUCCESS
}

backup_files() {
    local source_path="$1"
    local backup_path="${2:-}"
    
    if [[ -z "$source_path" ]]; then
        write_log "Source path cannot be empty" ERROR
        return
    fi
    
    if [[ ! -e "$source_path" ]]; then
        write_log "Source path does not exist: $source_path" ERROR
        return
    fi
    
    # Create backup directory if it doesn't exist
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR" || {
            write_log "Could not create backup directory: $BACKUP_DIR" ERROR
            return
        }
    fi
    
    # Generate backup filename with timestamp
    if [[ -z "$backup_path" ]]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        backup_path="${BACKUP_DIR}/backup_${timestamp}.zip"
    fi
    
    # Create backup directory if needed
    local backup_dir=$(dirname "$backup_path")
    if [[ ! -d "$backup_dir" ]]; then
        mkdir -p "$backup_dir" || {
            write_log "Could not create backup directory: $backup_dir" ERROR
            return
        }
    fi
    
    if ! command_exists zip; then
        write_log "zip command not found. Please install: sudo apt-get install zip" ERROR
        return
    fi
    
    if zip -r "$backup_path" "$source_path" &>/dev/null; then
        write_log "Backup created successfully: $backup_path" SUCCESS
    else
        write_log "Failed to create backup" ERROR
    fi
}

# Network Operations

get_network_stats() {
    write_log "Fetching network statistics..." INFO
    
    if command_exists ip; then
        write_log "Network Interfaces:" SUCCESS
        ip link show | grep -E "^[0-9]+:" | awk -F': ' '{print $2}'
        write_log "" SUCCESS
        
        for iface in $(ip link show | grep -E "^[0-9]+:" | awk -F': ' '{print $2}' | head -5); do
            local stats=$(ip -s link show "$iface" | tail -2)
            write_log "Interface: $iface" SUCCESS
            write_log "  Stats: $(echo "$stats" | tr '\n' ' ')" SUCCESS
        done
    elif command_exists ifconfig; then
        write_log "Network Configuration:" SUCCESS
        ifconfig | grep -E "^[a-z]|inet " | head -20
    else
        write_log "No network tools found" ERROR
    fi
}

get_ip_info() {
    local ip_address="$1"
    
    if [[ -z "$ip_address" ]]; then
        write_log "IP address cannot be empty" ERROR
        return
    fi
    
    if ! command_exists curl; then
        write_log "curl command not found. Please install: sudo apt-get install curl" ERROR
        return
    fi
    
    write_log "Looking up IP information for $ip_address..." INFO
    
    local response=$(curl -s "http://ip-api.com/json/$ip_address")
    local status=$(echo "$response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    if [[ "$status" == "success" ]]; then
        local ip=$(echo "$response" | grep -o '"query":"[^"]*"' | cut -d'"' -f4)
        local country=$(echo "$response" | grep -o '"country":"[^"]*"' | cut -d'"' -f4)
        local city=$(echo "$response" | grep -o '"city":"[^"]*"' | cut -d'"' -f4)
        local region=$(echo "$response" | grep -o '"regionName":"[^"]*"' | cut -d'"' -f4)
        local isp=$(echo "$response" | grep -o '"isp":"[^"]*"' | cut -d'"' -f4)
        local org=$(echo "$response" | grep -o '"org":"[^"]*"' | cut -d'"' -f4)
        local lat=$(echo "$response" | grep -o '"lat":[0-9.]*' | cut -d':' -f2)
        local lon=$(echo "$response" | grep -o '"lon":[0-9.]*' | cut -d':' -f2)
        
        write_log "IP: $ip" SUCCESS
        write_log "Status: $status" SUCCESS
        write_log "Location: $city, $region, $country" SUCCESS
        write_log "ISP: $isp" SUCCESS
        write_log "Organisation: $org" SUCCESS
        write_log "Longitude and Latitude: $lon, $lat" SUCCESS
    else
        write_log "Failed to retrieve location for IP: $ip_address" ERROR
    fi
}

# Display Menu 

show_menu() {
    clear
    echo -e "${CYAN}=== System Utility Script ===${NC}"
    echo "1. Kill Process"
    echo "2. System Health Check"
    echo "3. Free Space Monitoring"
    echo "4. Retrieve File Hash"
    echo "5. IP Location Lookup"
    echo "6. Get Network Stats"
    echo "7. Backup Files"
    echo "8. Exit"
    echo -e "${CYAN}=========${NC}"
    echo ""
}

# Main Menu Loop 
main() {
    create_log_dir
    check_root
    
    write_log "PowerBash Utility Script started on Linux" SUCCESS
    
    while true; do
        show_menu
        read -p "Enter your choice (1-8): " choice
        
        case "$choice" in
            1)
                read -p "Enter process name to kill: " process_name
                kill_process "$process_name"
                ;;
            2)
                get_system_health
                ;;
            3)
                read -p "Enter mount point to check (default: /): " mount_point
                mount_point="${mount_point:-.}"
                get_free_space "$mount_point"
                ;;
            4)
                read -p "Enter file path for hash calculation: " file_path
                get_file_hash "$file_path"
                ;;
            5)
                read -p "Enter IP address for location lookup: " ip_address
                get_ip_info "$ip_address"
                ;;
            6)
                get_network_stats
                ;;
            7)
                read -p "Enter source path to backup: " source_path
                read -p "Enter backup destination (default: ~/Backups/backup_<timestamp>.zip): " backup_path
                backup_files "$source_path" "$backup_path"
                ;;
            8)
                write_log "Exiting script..." INFO
                echo -e "${CYAN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                write_log "Invalid choice. Please select 1-8." ERROR
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
