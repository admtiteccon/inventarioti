# IT Inventory System - API Documentation

## Overview

The IT Inventory System provides a REST API for automated data collection agents to submit hardware information. This allows organizations to automatically gather and update hardware inventory data from scripts or local agents running on endpoints.

## Authentication

All API endpoints (except `/health`) require authentication using Bearer tokens.

### Getting an API Token

1. Log in to the IT Inventory System as an administrator
2. Navigate to **Admin > API Tokens**
3. Click **Create New Token**
4. Enter a descriptive name for the token (e.g., "Office Agent", "Datacenter Collector")
5. Copy the generated token and store it securely (it will only be shown once)

### Using the Token

Include the token in the `Authorization` header of your requests:

```
Authorization: Bearer YOUR_TOKEN_HERE
```

## API Endpoints

### Base URL

```
http://your-server/api/v1
```

### 1. Health Check

Check if the API is available.

**Endpoint:** `GET /health`

**Authentication:** Not required

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0",
  "api": "IT Inventory System API"
}
```

### 2. Submit Hardware Data

Create or update hardware information.

**Endpoint:** `POST /hardware/submit`

**Authentication:** Required

**Content-Type:** `application/json`

**Request Body:**
```json
{
  "serial_number": "ABC123",
  "name": "LAPTOP-001",
  "type": "notebook",
  "manufacturer": "Dell",
  "model": "Latitude 5420",
  "cpu": "Intel Core i7-1185G7",
  "ram": "16GB",
  "ip_address": "192.168.1.100",
  "os": "Windows 11 Pro",
  "location": "Office Building A"
}
```

**Required Fields:**
- `serial_number` (string): Unique identifier for the hardware
- `name` (string): Display name for the hardware
- `type` (string): One of: `notebook`, `desktop`, `server`, `printer`, `other`

**Optional Fields:**
- `manufacturer` (string): Hardware manufacturer
- `model` (string): Hardware model
- `cpu` (string): CPU information
- `ram` (string): RAM information
- `ip_address` (string): IP address
- `os` (string): Operating system
- `location` (string): Physical location

**Success Response (Created):**
```json
{
  "success": true,
  "action": "created",
  "hardware": {
    "id": 123,
    "serial_number": "ABC123",
    "name": "LAPTOP-001",
    "type": "notebook",
    "status": "active"
  },
  "message": "Hardware ABC123 created successfully"
}
```
**Status Code:** `201 Created`

**Success Response (Updated):**
```json
{
  "success": true,
  "action": "updated",
  "hardware": {
    "id": 123,
    "serial_number": "ABC123",
    "name": "LAPTOP-001",
    "type": "notebook",
    "status": "active"
  },
  "message": "Hardware ABC123 updated successfully"
}
```
**Status Code:** `200 OK`

### 3. Get Hardware by Serial Number

Retrieve hardware information.

**Endpoint:** `GET /hardware/<serial_number>`

**Authentication:** Required

**Success Response:**
```json
{
  "success": true,
  "hardware": {
    "id": 123,
    "serial_number": "ABC123",
    "name": "LAPTOP-001",
    "type": "notebook",
    "manufacturer": "Dell",
    "model": "Latitude 5420",
    "location": "Office Building A",
    "status": "active",
    "cpu": "Intel Core i7-1185G7",
    "ram": "16GB",
    "ip_address": "192.168.1.100",
    "os": "Windows 11 Pro",
    "created_at": "2025-11-12T10:30:00",
    "updated_at": "2025-11-12T15:45:00"
  }
}
```
**Status Code:** `200 OK`

## Error Responses

### Authentication Errors

**Missing Token:**
```json
{
  "error": {
    "code": "MISSING_TOKEN",
    "message": "Authorization header is required"
  }
}
```
**Status Code:** `401 Unauthorized`

**Invalid Token Format:**
```json
{
  "error": {
    "code": "INVALID_TOKEN_FORMAT",
    "message": "Authorization header must be in format: Bearer <token>"
  }
}
```
**Status Code:** `401 Unauthorized`

**Invalid Token:**
```json
{
  "error": {
    "code": "INVALID_TOKEN",
    "message": "Invalid or inactive API token"
  }
}
```
**Status Code:** `401 Unauthorized`

### Validation Errors

**Missing Required Fields:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid hardware data",
    "details": [
      "serial_number is required",
      "name is required"
    ]
  }
}
```
**Status Code:** `400 Bad Request`

**Invalid Content Type:**
```json
{
  "error": {
    "code": "INVALID_CONTENT_TYPE",
    "message": "Content-Type must be application/json"
  }
}
```
**Status Code:** `400 Bad Request`

### Not Found

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Hardware with serial number XYZ789 not found"
  }
}
```
**Status Code:** `404 Not Found`

### Server Errors

```json
{
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An internal server error occurred"
  }
}
```
**Status Code:** `500 Internal Server Error`

## Example Usage

### cURL

```bash
# Submit hardware data
curl -X POST http://your-server/api/v1/hardware/submit \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "serial_number": "ABC123",
    "name": "LAPTOP-001",
    "type": "notebook",
    "cpu": "Intel Core i7",
    "ram": "16GB",
    "ip_address": "192.168.1.100",
    "os": "Windows 11"
  }'

# Get hardware by serial number
curl -X GET http://your-server/api/v1/hardware/ABC123 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Python

```python
import requests
import json

API_URL = "http://your-server/api/v1"
API_TOKEN = "YOUR_TOKEN_HERE"

headers = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}

# Submit hardware data
hardware_data = {
    "serial_number": "ABC123",
    "name": "LAPTOP-001",
    "type": "notebook",
    "cpu": "Intel Core i7",
    "ram": "16GB",
    "ip_address": "192.168.1.100",
    "os": "Windows 11"
}

response = requests.post(
    f"{API_URL}/hardware/submit",
    headers=headers,
    json=hardware_data
)

if response.status_code in [200, 201]:
    print("Success:", response.json())
else:
    print("Error:", response.json())
```

### PowerShell

```powershell
$apiUrl = "http://your-server/api/v1"
$apiToken = "YOUR_TOKEN_HERE"

$headers = @{
    "Authorization" = "Bearer $apiToken"
    "Content-Type" = "application/json"
}

$hardwareData = @{
    serial_number = "ABC123"
    name = "LAPTOP-001"
    type = "notebook"
    cpu = "Intel Core i7"
    ram = "16GB"
    ip_address = "192.168.1.100"
    os = "Windows 11"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "$apiUrl/hardware/submit" `
    -Method Post `
    -Headers $headers `
    -Body $hardwareData

Write-Output $response
```

## Best Practices

1. **Secure Token Storage**: Store API tokens securely and never commit them to version control
2. **Error Handling**: Always check response status codes and handle errors appropriately
3. **Rate Limiting**: Implement reasonable delays between requests to avoid overwhelming the server
4. **Unique Serial Numbers**: Ensure serial numbers are truly unique to prevent data conflicts
5. **Regular Updates**: Schedule agents to run periodically to keep inventory data current
6. **Logging**: Log all API interactions for troubleshooting and audit purposes

## Support

For issues or questions about the API, contact your system administrator or refer to the main IT Inventory System documentation.
