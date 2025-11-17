# Security Configuration Guide

This document outlines the security features and configurations implemented in the IT Inventory Management System.

## Table of Contents

1. [Security Features](#security-features)
2. [CSRF Protection](#csrf-protection)
3. [Session Security](#session-security)
4. [Password Security](#password-security)
5. [HTTPS Configuration](#https-configuration)
6. [Security Headers](#security-headers)
7. [API Security](#api-security)
8. [Database Security](#database-security)
9. [File Upload Security](#file-upload-security)
10. [Security Best Practices](#security-best-practices)
11. [Security Checklist](#security-checklist)

## Security Features

The IT Inventory System implements multiple layers of security:

- **CSRF Protection**: Cross-Site Request Forgery protection on all forms
- **Password Hashing**: Bcrypt password hashing with salt
- **Session Security**: Secure session cookies with HTTPOnly and SameSite flags
- **HTTPS Enforcement**: Automatic redirect from HTTP to HTTPS in production
- **Security Headers**: Comprehensive security headers on all responses
- **Role-Based Access Control**: Fine-grained permissions based on user roles
- **API Token Authentication**: Secure token-based authentication for agents
- **SQL Injection Prevention**: Parameterized queries via SQLAlchemy ORM
- **XSS Protection**: Template auto-escaping and Content Security Policy

## CSRF Protection

### Implementation

CSRF protection is implemented using Flask-WTF and is enabled by default in production.

**Configuration** (`config.py`):
```python
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None  # Tokens don't expire
```

### Usage in Templates

All forms automatically include CSRF tokens:

```html
<form method="POST">
    {{ csrf_token() }}
    <!-- form fields -->
</form>
```

Or using the meta tag for AJAX requests:

```html
<meta name="csrf-token" content="{{ csrf_token() }}">
```

### AJAX Requests

CSRF tokens are automatically included in AJAX requests via JavaScript (`main.js`):

```javascript
// Token is automatically added to fetch() and XMLHttpRequest
fetch('/api/endpoint', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': token  // Automatically added
    },
    body: JSON.stringify(data)
});
```

### API Exemption

API endpoints for agent integration are exempt from CSRF protection as they use token-based authentication:

```python
csrf.exempt(api.bp)
```

## Session Security

### Configuration

Sessions are configured with security best practices:

**Development** (`config.py`):
```python
SESSION_COOKIE_SECURE = False  # HTTP allowed in development
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'
SESSION_COOKIE_NAME = 'inventory_session'
PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
```

**Production** (`config.py`):
```python
SESSION_COOKIE_SECURE = True  # HTTPS only
SESSION_COOKIE_HTTPONLY = True  # No JavaScript access
SESSION_COOKIE_SAMESITE = 'Strict'  # Strict same-site policy
SESSION_COOKIE_NAME = 'inventory_session'
PERMANENT_SESSION_LIFETIME = timedelta(hours=24)
```

### Session Attributes

- **Secure**: Cookies only sent over HTTPS in production
- **HTTPOnly**: Cookies not accessible via JavaScript (XSS protection)
- **SameSite**: Prevents CSRF attacks by restricting cross-site cookie sending
- **Lifetime**: Sessions expire after 24 hours of inactivity

## Password Security

### Hashing Algorithm

Passwords are hashed using **bcrypt** with automatic salt generation:

```python
from bcrypt import hashpw, gensalt, checkpw

def set_password(self, password):
    """Hash and set user password."""
    self.password_hash = hashpw(password.encode('utf-8'), gensalt()).decode('utf-8')

def check_password(self, password):
    """Verify password against hash."""
    return checkpw(password.encode('utf-8'), self.password_hash.encode('utf-8'))
```

### Password Requirements

Implement password complexity requirements in your registration/password reset forms:

- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

### Password Reset Security

Password reset tokens are:
- Cryptographically random (using `secrets` module)
- Time-limited (expire after 1 hour)
- Single-use (marked as used after consumption)
- Stored hashed in the database

## HTTPS Configuration

### Automatic Redirect

In production, HTTP requests are automatically redirected to HTTPS:

**Configuration** (`config.py`):
```python
PREFERRED_URL_SCHEME = 'https'
```

**Middleware** (`app/__init__.py`):
```python
@app.before_request
def enforce_https():
    """Redirect HTTP to HTTPS in production."""
    if app.config.get('PREFERRED_URL_SCHEME') == 'https':
        if not request.is_secure and not request.headers.get('X-Forwarded-Proto') == 'https':
            url = request.url.replace('http://', 'https://', 1)
            return redirect(url, code=301)
```

### SSL/TLS Configuration

See [DEPLOYMENT.md](DEPLOYMENT.md) for SSL certificate setup using Let's Encrypt or custom certificates.

## Security Headers

### Implemented Headers

The following security headers are automatically added to all responses in production:

**Configuration** (`config.py`):
```python
SECURITY_HEADERS = {
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'SAMEORIGIN',
    'X-XSS-Protection': '1; mode=block',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' https://unpkg.com; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; img-src 'self' data: https:; font-src 'self' https://cdn.jsdelivr.net;"
}
```

### Header Descriptions

| Header | Purpose | Value |
|--------|---------|-------|
| **Strict-Transport-Security** | Forces HTTPS for 1 year | `max-age=31536000; includeSubDomains` |
| **X-Content-Type-Options** | Prevents MIME sniffing | `nosniff` |
| **X-Frame-Options** | Prevents clickjacking | `SAMEORIGIN` |
| **X-XSS-Protection** | Enables browser XSS filter | `1; mode=block` |
| **Content-Security-Policy** | Controls resource loading | See CSP section below |

### Content Security Policy (CSP)

The CSP header restricts where resources can be loaded from:

- **default-src 'self'**: Only load resources from same origin by default
- **script-src**: Allow scripts from self, inline scripts (for Bootstrap), and unpkg.com (Leaflet)
- **style-src**: Allow styles from self, inline styles, and CDN
- **img-src**: Allow images from self, data URIs, and HTTPS sources
- **font-src**: Allow fonts from self and CDN

**Note**: Adjust CSP based on your specific CDN and third-party service requirements.

## API Security

### Token-Based Authentication

API endpoints use Bearer token authentication:

**Request Format**:
```http
POST /api/v1/hardware/submit HTTP/1.1
Host: yourdomain.com
Authorization: Bearer your-api-token-here
Content-Type: application/json

{
    "serial_number": "ABC123",
    "name": "LAPTOP-001",
    ...
}
```

### Token Management

- Tokens are cryptographically random (32 bytes, hex-encoded)
- Tokens are stored hashed in the database
- Tokens can be revoked by administrators
- Each token has a name/identifier for tracking
- Last used timestamp is tracked

### API Rate Limiting

Consider implementing rate limiting for API endpoints:

```python
# Example using Flask-Limiter (add to requirements.txt)
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@bp.route('/api/v1/hardware/submit', methods=['POST'])
@limiter.limit("10 per minute")
def submit_hardware():
    # ...
```

## Database Security

### SQL Injection Prevention

All database queries use SQLAlchemy ORM with parameterized queries:

```python
# Safe - parameterized query
user = User.query.filter_by(email=email).first()

# Safe - using parameters
hardware = Hardware.query.filter(Hardware.serial_number == serial).first()
```

**Never** use string concatenation for queries:
```python
# UNSAFE - DO NOT USE
query = f"SELECT * FROM users WHERE email = '{email}'"
```

### Database Credentials

- Store database credentials in environment variables
- Never commit credentials to version control
- Use strong, unique passwords
- Limit database user permissions to only what's needed
- Use SSL/TLS for database connections in production

### Connection Pooling

Production configuration includes connection pooling for security and performance:

```python
SQLALCHEMY_ENGINE_OPTIONS = {
    'pool_size': 10,
    'max_overflow': 20,
    'pool_recycle': 3600,  # Recycle connections after 1 hour
    'pool_pre_ping': True,  # Verify connections before use
    'pool_timeout': 30,
}
```

## File Upload Security

### File Type Validation

Only specific file types are allowed:

```python
ALLOWED_EXTENSIONS = {'csv', 'xlsx', 'xls'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
```

### File Size Limits

Maximum upload size is enforced:

```python
MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
```

### File Storage

- Uploaded files are stored outside the web root
- Files are not directly accessible via URL
- Use `send_from_directory()` with validation for serving files
- Consider virus scanning for uploaded files in high-security environments

### Secure File Handling

```python
from werkzeug.utils import secure_filename

filename = secure_filename(file.filename)  # Sanitize filename
file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
```

## Security Best Practices

### 1. Environment Variables

- Use `.env` file for configuration (never commit to git)
- Use strong, random values for `SECRET_KEY`
- Rotate secrets regularly
- Use different secrets for each environment

### 2. Dependency Management

- Keep dependencies up to date
- Regularly run `pip list --outdated`
- Use `pip-audit` to check for known vulnerabilities
- Pin dependency versions in `requirements.txt`

### 3. Logging and Monitoring

- Log all authentication attempts
- Log all authorization failures
- Monitor for suspicious activity
- Set up alerts for critical errors
- Regularly review logs

### 4. Error Handling

- Never expose stack traces in production
- Use generic error messages for users
- Log detailed errors server-side
- Implement custom error pages

### 5. Input Validation

- Validate all user input
- Use whitelist validation when possible
- Sanitize input before processing
- Validate on both client and server side

### 6. Access Control

- Implement principle of least privilege
- Regularly review user permissions
- Disable inactive accounts
- Implement account lockout after failed login attempts

### 7. Backup and Recovery

- Regular automated backups
- Test backup restoration
- Encrypt backups
- Store backups securely off-site

## Security Checklist

### Pre-Deployment

- [ ] Strong `SECRET_KEY` generated and set
- [ ] Database credentials secured in environment variables
- [ ] Debug mode disabled (`FLASK_ENV=production`)
- [ ] CSRF protection enabled
- [ ] HTTPS configured with valid SSL certificate
- [ ] Security headers configured
- [ ] File upload restrictions in place
- [ ] Error pages don't expose sensitive information
- [ ] Logging configured and tested
- [ ] Dependencies updated to latest secure versions

### Post-Deployment

- [ ] HTTPS redirect working
- [ ] Security headers present in responses
- [ ] CSRF tokens present in forms
- [ ] Session cookies have Secure flag
- [ ] API authentication working
- [ ] File uploads restricted to allowed types
- [ ] Error pages display correctly
- [ ] Logs being written correctly
- [ ] Backup system operational
- [ ] Monitoring and alerting configured

### Regular Maintenance

- [ ] Review access logs weekly
- [ ] Update dependencies monthly
- [ ] Rotate API tokens quarterly
- [ ] Review user accounts quarterly
- [ ] Test backup restoration quarterly
- [ ] Security audit annually
- [ ] Penetration testing annually

## Reporting Security Issues

If you discover a security vulnerability, please email: security@yourdomain.com

**Do not** create public GitHub issues for security vulnerabilities.

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Flask Security Best Practices](https://flask.palletsprojects.com/en/latest/security/)
- [Python Security Best Practices](https://python.readthedocs.io/en/stable/library/security_warnings.html)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

**Last Updated**: 2025-11-12
**Version**: 1.0
