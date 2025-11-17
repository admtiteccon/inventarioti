# Agent Integration Guide

## Overview

This guide explains how to integrate automated data collection agents with the IT Inventory System using the REST API.

## Quick Start

### 1. Create an API Token

1. Log in as an administrator
2. Navigate to **Admin > API Tokens** in the navigation menu
3. Click **Create New Token**
4. Enter a descriptive name (e.g., "Windows Agent", "Linux Collector")
5. Copy the generated token immediately (it won't be shown again)

### 2. Test the API

```bash
# Test health endpoint (no authentication required)
curl http://your-server/api/v1/health

# Test hardware submission
curl -X POST http://your-server/api/v1/hardware/submit \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "serial_number": "TEST001",
    "name": "Test Device",
    "type": "notebook"
  }'
```

## Sample Agent Scripts

### Windows PowerShell Agent

```powershell
# IT Inventory Agent - Windows
# Save as: inventory-agent.ps1

$apiUrl = "http://your-server/api/v1/hardware/submit"
$apiToken = "YOUR_TOKEN_HERE"

# Gather system information
$computerSystem = Get-WmiObject Win32_ComputerSystem
$os = Get-WmiObject Win32_OperatingSystem
$processor = Get-WmiObject Win32_Processor | Select-Object -First 1
$serialNumber = (Get-WmiObject Win32_BIOS).SerialNumber
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | Select-Object -First 1).IPAddress

# Prepare data
$hardwareData = @{
    serial_number = $serialNumber
    name = $env:COMPUTERNAME
    type = if ($computerSystem.PCSystemType -eq 2) { "notebook" } else { "desktop" }
    manufacturer = $computerSystem.Manufacturer
    model = $computerSystem.Model
    cpu = $processor.Name
    ram = "$([math]::Round($computerSystem.TotalPhysicalMemory / 1GB))GB"
    ip_address = $ipAddress
    os = $os.Caption
    location = "Auto-detected"
} | ConvertTo-Json

# Submit to API
try {
    $headers = @{
        "Authorization" = "Bearer $apiToken"
        "Content-Type" = "application/json"
    }
    
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $hardwareData
    Write-Host "✓ Success: $($response.message)" -ForegroundColor Green
    Write-Host "  Action: $($response.action)" -ForegroundColor Cyan
    Write-Host "  Hardware ID: $($response.hardware.id)" -ForegroundColor Cyan
}
catch {
    Write-Host "✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "  Details: $($errorDetails.error.message)" -ForegroundColor Yellow
    }
}
```

### Linux Bash Agent

```bash
#!/bin/bash
# IT Inventory Agent - Linux
# Save as: inventory-agent.sh

API_URL="http://your-server/api/v1/hardware/submit"
API_TOKEN="YOUR_TOKEN_HERE"

# Gather system information
SERIAL_NUMBER=$(sudo dmidecode -s system-serial-number | tr -d '[:space:]')
HOSTNAME=$(hostname)
MANUFACTURER=$(sudo dmidecode -s system-manufacturer)
MODEL=$(sudo dmidecode -s system-product-name)
CPU=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
RAM=$(free -h | awk '/^Mem:/ {print $2}')
IP_ADDRESS=$(hostname -I | awk '{print $1}')
OS=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

# Determine type
if sudo dmidecode -s chassis-type | grep -q "Notebook\|Laptop"; then
    TYPE="notebook"
else
    TYPE="desktop"
fi

# Prepare JSON data
JSON_DATA=$(cat <<EOF
{
  "serial_number": "$SERIAL_NUMBER",
  "name": "$HOSTNAME",
  "type": "$TYPE",
  "manufacturer": "$MANUFACTURER",
  "model": "$MODEL",
  "cpu": "$CPU",
  "ram": "$RAM",
  "ip_address": "$IP_ADDRESS",
  "os": "$OS",
  "location": "Auto-detected"
}
EOF
)

# Submit to API
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$JSON_DATA")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
    echo "✓ Success: Hardware submitted"
    echo "$BODY" | python3 -m json.tool
else
    echo "✗ Error: HTTP $HTTP_CODE"
    echo "$BODY" | python3 -m json.tool
fi
```

### Python Agent

```python
#!/usr/bin/env python3
"""IT Inventory Agent - Cross-platform Python"""

import platform
import socket
import json
import subprocess
import requests

API_URL = "http://your-server/api/v1/hardware/submit"
API_TOKEN = "YOUR_TOKEN_HERE"

def get_serial_number():
    """Get system serial number"""
    system = platform.system()
    try:
        if system == "Windows":
            output = subprocess.check_output(
                "wmic bios get serialnumber", 
                shell=True
            ).decode()
            return output.split('\n')[1].strip()
        elif system == "Linux":
            output = subprocess.check_output(
                "sudo dmidecode -s system-serial-number",
                shell=True
            ).decode()
            return output.strip()
        elif system == "Darwin":  # macOS
            output = subprocess.check_output(
                "system_profiler SPHardwareDataType | grep 'Serial Number'",
                shell=True
            ).decode()
            return output.split(':')[1].strip()
    except:
        return "UNKNOWN"

def get_system_info():
    """Gather system information"""
    return {
        "serial_number": get_serial_number(),
        "name": socket.gethostname(),
        "type": "notebook" if "laptop" in platform.machine().lower() else "desktop",
        "manufacturer": "Unknown",
        "model": platform.machine(),
        "cpu": platform.processor(),
        "ram": "Unknown",
        "ip_address": socket.gethostbyname(socket.gethostname()),
        "os": f"{platform.system()} {platform.release()}",
        "location": "Auto-detected"
    }

def submit_to_api(data):
    """Submit hardware data to API"""
    headers = {
        "Authorization": f"Bearer {API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.post(API_URL, headers=headers, json=data)
        response.raise_for_status()
        
        result = response.json()
        print(f"✓ Success: {result['message']}")
        print(f"  Action: {result['action']}")
        print(f"  Hardware ID: {result['hardware']['id']}")
        
    except requests.exceptions.HTTPError as e:
        print(f"✗ HTTP Error: {e}")
        if e.response.text:
            error = json.loads(e.response.text)
            print(f"  Details: {error['error']['message']}")
    except Exception as e:
        print(f"✗ Error: {e}")

if __name__ == "__main__":
    print("Gathering system information...")
    system_info = get_system_info()
    
    print(f"Submitting data for: {system_info['name']}")
    submit_to_api(system_info)
```

## Scheduling Agents

### Windows Task Scheduler

```powershell
# Create scheduled task to run daily at 9 AM
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\inventory-agent.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 9am
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "IT Inventory Agent" -Action $action -Trigger $trigger -Principal $principal
```

### Linux Cron

```bash
# Add to crontab (run daily at 9 AM)
0 9 * * * /usr/local/bin/inventory-agent.sh >> /var/log/inventory-agent.log 2>&1
```

## Token Management

### Viewing Tokens

- Navigate to **Admin > API Tokens**
- View all tokens with their status and last used timestamp
- Tokens show a truncated version for security

### Deactivating Tokens

- Click the pause icon next to a token to deactivate it
- Deactivated tokens cannot be used for API authentication
- Reactivate by clicking the play icon

### Deleting Tokens

- Click the trash icon to permanently delete a token
- This action cannot be undone
- Agents using deleted tokens will receive authentication errors

## Troubleshooting

### Authentication Errors

**Problem:** `Invalid or inactive API token`

**Solutions:**
- Verify the token is correct (no extra spaces)
- Check if the token is active in the admin panel
- Ensure the token hasn't been deleted

### Validation Errors

**Problem:** `Missing required fields`

**Solutions:**
- Ensure `serial_number`, `name`, and `type` are provided
- Check that `type` is one of: notebook, desktop, server, printer, other
- Verify JSON format is correct

### Connection Errors

**Problem:** Cannot connect to API

**Solutions:**
- Verify the API URL is correct
- Check network connectivity
- Ensure the server is running
- Check firewall rules

## Security Best Practices

1. **Token Storage**: Store tokens in secure configuration files with restricted permissions
2. **HTTPS**: Use HTTPS in production to encrypt token transmission
3. **Token Rotation**: Periodically rotate API tokens
4. **Least Privilege**: Create separate tokens for different agent groups
5. **Monitoring**: Review token usage in the admin panel regularly
6. **Logging**: Enable logging in agents for troubleshooting

## API Reference

For complete API documentation, see [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## Support

For issues or questions:
1. Check the API health endpoint: `GET /api/v1/health`
2. Review agent logs for error details
3. Contact your system administrator
4. Refer to the main IT Inventory System documentation
