# IT Inventory System - Deployment Guide

This guide provides comprehensive instructions for deploying the IT Inventory Management System to production environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Variables](#environment-variables)
3. [Database Setup](#database-setup)
4. [Application Deployment](#application-deployment)
5. [Web Server Configuration](#web-server-configuration)
6. [SSL/TLS Configuration](#ssltls-configuration)
7. [Post-Deployment Tasks](#post-deployment-tasks)
8. [Monitoring and Maintenance](#monitoring-and-maintenance)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

- **Operating System**: Linux (Ubuntu 20.04+ or CentOS 8+ recommended)
- **Python**: 3.9 or higher
- **Database**: PostgreSQL 12+ (or SQLite for small deployments)
- **Web Server**: Nginx or Apache
- **Memory**: Minimum 512MB RAM, 1GB+ recommended
- **Storage**: 10GB minimum (scalable based on file uploads)
- **SSL Certificate**: Required for production (Let's Encrypt recommended)

### Software Dependencies

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Python and pip
sudo apt install python3.9 python3.9-venv python3-pip -y

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Install Nginx
sudo apt install nginx -y

# Install supervisor (for process management)
sudo apt install supervisor -y
```

## Environment Variables

Create a `.env` file in the application root directory with the following variables:

### Required Variables

```bash
# Application Configuration
FLASK_APP=run.py
FLASK_ENV=production
SECRET_KEY=your-secret-key-here-use-strong-random-string

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/inventory_db

# Mail Server Configuration
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=true
MAIL_USERNAME=your-email@example.com
MAIL_PASSWORD=your-email-password
MAIL_DEFAULT_SENDER=noreply@yourdomain.com

# Application Settings
APP_NAME=IT Inventory System
APP_ADMIN_EMAIL=admin@yourdomain.com
```

### Optional Variables

```bash
# Database Connection Pooling
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=20
DB_POOL_RECYCLE=3600
DB_POOL_TIMEOUT=30

# Session Configuration
SESSION_LIFETIME_HOURS=24

# File Upload Configuration
UPLOAD_FOLDER=/var/www/inventory/uploads
MAX_CONTENT_LENGTH=16777216  # 16MB in bytes

# Pagination
ITEMS_PER_PAGE=20

# License Alerts
LICENSE_ALERT_THRESHOLD_DAYS=30

# Scheduler
SCHEDULER_TIMEZONE=America/New_York

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/inventory/production.log

# Rate Limiting
RATELIMIT_ENABLED=true
```

### Generating a Secret Key

```python
# Run this Python command to generate a secure secret key
python3 -c "import secrets; print(secrets.token_hex(32))"
```

## Database Setup

### PostgreSQL Installation and Configuration

1. **Install PostgreSQL** (if not already installed):

```bash
sudo apt install postgresql postgresql-contrib -y
```

2. **Create Database and User**:

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL prompt:
CREATE DATABASE inventory_db;
CREATE USER inventory_user WITH PASSWORD 'your-secure-password';
GRANT ALL PRIVILEGES ON DATABASE inventory_db TO inventory_user;
\q
```

3. **Configure PostgreSQL for Remote Access** (if needed):

Edit `/etc/postgresql/12/main/postgresql.conf`:
```
listen_addresses = 'localhost'  # or '*' for all interfaces
```

Edit `/etc/postgresql/12/main/pg_hba.conf`:
```
# Add this line for local connections
local   inventory_db    inventory_user                          md5
host    inventory_db    inventory_user    127.0.0.1/32          md5
```

4. **Restart PostgreSQL**:

```bash
sudo systemctl restart postgresql
```

### Database Initialization

1. **Set up Python virtual environment**:

```bash
cd /var/www/inventory
python3 -m venv venv
source venv/bin/activate
```

2. **Install dependencies**:

```bash
pip install -r requirements.txt
```

3. **Initialize database with migrations**:

```bash
# Set environment variables
export FLASK_APP=run.py
export FLASK_ENV=production
source .env  # Load environment variables

# Initialize migrations (if not already done)
flask db init

# Create initial migration
flask db migrate -m "Initial migration"

# Apply migrations to database
flask db upgrade
```

4. **Create initial admin user**:

```bash
# Run Python shell
flask shell

# In Flask shell:
from app.models import User
from app import db

admin = User(
    name='Admin User',
    email='admin@yourdomain.com',
    role='admin'
)
admin.set_password('your-secure-admin-password')
db.session.add(admin)
db.session.commit()
exit()
```

## Application Deployment

### Using Gunicorn (Recommended)

1. **Install Gunicorn**:

```bash
pip install gunicorn
```

2. **Create Gunicorn configuration file** (`gunicorn_config.py`):

```python
# gunicorn_config.py
import multiprocessing

# Server socket
bind = "127.0.0.1:8000"
backlog = 2048

# Worker processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2

# Logging
accesslog = "/var/log/inventory/gunicorn-access.log"
errorlog = "/var/log/inventory/gunicorn-error.log"
loglevel = "info"

# Process naming
proc_name = "inventory_system"

# Server mechanics
daemon = False
pidfile = "/var/run/inventory/gunicorn.pid"
user = "www-data"
group = "www-data"
tmp_upload_dir = None

# SSL (if terminating SSL at Gunicorn level)
# keyfile = "/path/to/keyfile"
# certfile = "/path/to/certfile"
```

3. **Create systemd service file** (`/etc/systemd/system/inventory.service`):

```ini
[Unit]
Description=IT Inventory System Gunicorn Service
After=network.target postgresql.service

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=/var/www/inventory
Environment="PATH=/var/www/inventory/venv/bin"
EnvironmentFile=/var/www/inventory/.env
ExecStart=/var/www/inventory/venv/bin/gunicorn \
    --config /var/www/inventory/gunicorn_config.py \
    run:app
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

4. **Create log directory**:

```bash
sudo mkdir -p /var/log/inventory
sudo chown www-data:www-data /var/log/inventory
```

5. **Start and enable the service**:

```bash
sudo systemctl daemon-reload
sudo systemctl start inventory
sudo systemctl enable inventory
sudo systemctl status inventory
```

### Using Supervisor (Alternative)

1. **Install Supervisor**:

```bash
sudo apt install supervisor -y
```

2. **Create Supervisor configuration** (`/etc/supervisor/conf.d/inventory.conf`):

```ini
[program:inventory]
command=/var/www/inventory/venv/bin/gunicorn -c /var/www/inventory/gunicorn_config.py run:app
directory=/var/www/inventory
user=www-data
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/inventory/supervisor-error.log
stdout_logfile=/var/log/inventory/supervisor-access.log
environment=PATH="/var/www/inventory/venv/bin"
```

3. **Update and start Supervisor**:

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start inventory
sudo supervisorctl status inventory
```

## Web Server Configuration

### Nginx Configuration (Recommended)

1. **Create Nginx site configuration** (`/etc/nginx/sites-available/inventory`):

```nginx
# Upstream application server
upstream inventory_app {
    server 127.0.0.1:8000 fail_timeout=0;
}

# HTTP server - redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Redirect all HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Logging
    access_log /var/log/nginx/inventory-access.log;
    error_log /var/log/nginx/inventory-error.log;
    
    # Max upload size
    client_max_body_size 16M;
    
    # Static files
    location /static {
        alias /var/www/inventory/app/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # Uploaded files
    location /uploads {
        alias /var/www/inventory/uploads;
        internal;  # Only accessible through X-Accel-Redirect
    }
    
    # Application
    location / {
        proxy_pass http://inventory_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://inventory_app;
    }
}
```

2. **Enable the site**:

```bash
sudo ln -s /etc/nginx/sites-available/inventory /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl restart nginx
```

### Apache Configuration (Alternative)

1. **Install mod_wsgi**:

```bash
sudo apt install libapache2-mod-wsgi-py3 -y
```

2. **Create Apache site configuration** (`/etc/apache2/sites-available/inventory.conf`):

```apache
<VirtualHost *:80>
    ServerName yourdomain.com
    ServerAlias www.yourdomain.com
    
    # Redirect to HTTPS
    Redirect permanent / https://yourdomain.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName yourdomain.com
    ServerAlias www.yourdomain.com
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/yourdomain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/yourdomain.com/privkey.pem
    
    # WSGI Configuration
    WSGIDaemonProcess inventory python-home=/var/www/inventory/venv python-path=/var/www/inventory
    WSGIProcessGroup inventory
    WSGIScriptAlias / /var/www/inventory/wsgi.py
    
    <Directory /var/www/inventory>
        Require all granted
    </Directory>
    
    # Static files
    Alias /static /var/www/inventory/app/static
    <Directory /var/www/inventory/app/static>
        Require all granted
    </Directory>
    
    # Logging
    ErrorLog ${APACHE_LOG_DIR}/inventory-error.log
    CustomLog ${APACHE_LOG_DIR}/inventory-access.log combined
</VirtualHost>
```

3. **Create WSGI file** (`wsgi.py`):

```python
#!/usr/bin/env python3
import sys
import os

# Add application directory to path
sys.path.insert(0, '/var/www/inventory')

# Load environment variables
from dotenv import load_dotenv
load_dotenv('/var/www/inventory/.env')

# Create application
from run import app as application
```

4. **Enable modules and site**:

```bash
sudo a2enmod ssl
sudo a2enmod wsgi
sudo a2ensite inventory
sudo systemctl restart apache2
```

## SSL/TLS Configuration

### Using Let's Encrypt (Recommended)

1. **Install Certbot**:

```bash
sudo apt install certbot python3-certbot-nginx -y
```

2. **Obtain SSL certificate**:

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

3. **Auto-renewal**:

```bash
# Test renewal
sudo certbot renew --dry-run

# Certbot automatically sets up a cron job for renewal
```

### Using Custom SSL Certificate

1. **Copy certificate files**:

```bash
sudo mkdir -p /etc/ssl/inventory
sudo cp your-certificate.crt /etc/ssl/inventory/
sudo cp your-private-key.key /etc/ssl/inventory/
sudo chmod 600 /etc/ssl/inventory/your-private-key.key
```

2. **Update Nginx configuration** to point to your certificate files.

## Post-Deployment Tasks

### 1. Create Initial Admin User

If not already created during database setup:

```bash
flask shell

# In Flask shell:
from app.models import User
from app import db

admin = User(name='Admin', email='admin@yourdomain.com', role='admin')
admin.set_password('secure-password')
db.session.add(admin)
db.session.commit()
```

### 2. Configure Firewall

```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
sudo ufw status
```

### 3. Set Up Log Rotation

Create `/etc/logrotate.d/inventory`:

```
/var/log/inventory/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload inventory > /dev/null 2>&1 || true
    endscript
}
```

### 4. Configure Backup

Create backup script (`/usr/local/bin/backup-inventory.sh`):

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/inventory"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
pg_dump -U inventory_user inventory_db | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /var/www/inventory/uploads

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

Add to crontab:

```bash
sudo crontab -e

# Add this line for daily backups at 2 AM
0 2 * * * /usr/local/bin/backup-inventory.sh >> /var/log/inventory/backup.log 2>&1
```

## Monitoring and Maintenance

### Health Checks

Monitor application health:

```bash
# Check application status
sudo systemctl status inventory

# Check Nginx status
sudo systemctl status nginx

# Check PostgreSQL status
sudo systemctl status postgresql

# Test application endpoint
curl -I https://yourdomain.com/health
```

### Log Monitoring

```bash
# Application logs
tail -f /var/log/inventory/production.log

# Gunicorn logs
tail -f /var/log/inventory/gunicorn-error.log

# Nginx logs
tail -f /var/log/nginx/inventory-error.log
```

### Performance Monitoring

Consider installing monitoring tools:

- **Prometheus + Grafana**: For metrics and dashboards
- **Sentry**: For error tracking
- **New Relic / DataDog**: For APM

## Troubleshooting

### Application Won't Start

1. Check logs:
```bash
sudo journalctl -u inventory -n 50
```

2. Verify environment variables:
```bash
sudo -u www-data bash
cd /var/www/inventory
source venv/bin/activate
python -c "from config import config; print(config['production']().SQLALCHEMY_DATABASE_URI)"
```

3. Test database connection:
```bash
psql -U inventory_user -d inventory_db -h localhost
```

### 502 Bad Gateway

1. Check if Gunicorn is running:
```bash
sudo systemctl status inventory
```

2. Check Gunicorn logs:
```bash
tail -f /var/log/inventory/gunicorn-error.log
```

3. Verify socket/port binding:
```bash
sudo netstat -tlnp | grep 8000
```

### Database Connection Errors

1. Verify PostgreSQL is running:
```bash
sudo systemctl status postgresql
```

2. Check database credentials in `.env` file

3. Test connection:
```bash
psql -U inventory_user -d inventory_db -h localhost
```

### Email Not Sending

1. Verify SMTP settings in `.env`

2. Test email configuration:
```bash
flask shell

from app.services.email_service import EmailService
EmailService.send_test_email('test@example.com')
```

3. Check firewall rules for SMTP port (587 or 465)

### High Memory Usage

1. Reduce Gunicorn workers in `gunicorn_config.py`

2. Optimize database connection pool in `.env`:
```bash
DB_POOL_SIZE=5
DB_MAX_OVERFLOW=10
```

3. Enable database query optimization

## Security Checklist

- [ ] Strong SECRET_KEY set
- [ ] Database credentials secured
- [ ] SSL/TLS certificate installed and valid
- [ ] Firewall configured
- [ ] File permissions set correctly (www-data:www-data)
- [ ] Debug mode disabled in production
- [ ] CSRF protection enabled
- [ ] Security headers configured
- [ ] Regular backups scheduled
- [ ] Log rotation configured
- [ ] Monitoring and alerting set up
- [ ] Dependencies updated regularly

## Support

For issues and questions:
- Check application logs: `/var/log/inventory/`
- Review this documentation
- Contact system administrator

---

**Last Updated**: 2025-11-12
**Version**: 1.0
