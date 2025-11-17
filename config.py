import os
from datetime import timedelta


class Config:
    """Base configuration class with common settings"""
    
    # Secret key for session management and CSRF protection
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'dev-secret-key-change-in-production'
    
    # Database configuration
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ECHO = False
    
    # Mail configuration
    MAIL_SERVER = os.environ.get('MAIL_SERVER') or 'localhost'
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 587)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS', 'true').lower() in ['true', 'on', '1']
    MAIL_USE_SSL = os.environ.get('MAIL_USE_SSL', 'false').lower() in ['true', 'on', '1']
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER') or 'noreply@inventory.local'
    MAIL_MAX_EMAILS = int(os.environ.get('MAIL_MAX_EMAILS') or 100)
    
    # File upload configuration
    UPLOAD_FOLDER = os.environ.get('UPLOAD_FOLDER') or 'uploads'
    MAX_CONTENT_LENGTH = int(os.environ.get('MAX_CONTENT_LENGTH') or 16 * 1024 * 1024)  # 16MB default
    ALLOWED_EXTENSIONS = {'csv', 'xlsx', 'xls'}
    
    # Session configuration
    PERMANENT_SESSION_LIFETIME = timedelta(hours=int(os.environ.get('SESSION_LIFETIME_HOURS') or 24))
    SESSION_COOKIE_SECURE = False  # Set to True in production with HTTPS
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    SESSION_COOKIE_NAME = 'inventory_session'
    
    # Pagination
    ITEMS_PER_PAGE = int(os.environ.get('ITEMS_PER_PAGE') or 20)
    
    # License alert configuration
    LICENSE_ALERT_THRESHOLD_DAYS = int(os.environ.get('LICENSE_ALERT_THRESHOLD_DAYS') or 30)
    
    # Scheduler configuration
    SCHEDULER_API_ENABLED = False
    SCHEDULER_TIMEZONE = os.environ.get('SCHEDULER_TIMEZONE') or 'UTC'
    
    # Application settings
    APP_NAME = os.environ.get('APP_NAME') or 'IT Inventory System'
    APP_ADMIN_EMAIL = os.environ.get('APP_ADMIN_EMAIL') or 'admin@inventory.local'
    
    # Footer customization
    FOOTER_COMPANY_NAME = os.environ.get('FOOTER_COMPANY_NAME') or 'IT Inventory Management System'
    FOOTER_YEAR = os.environ.get('FOOTER_YEAR') or '2024'
    FOOTER_VERSION = os.environ.get('FOOTER_VERSION') or '1.0.0'
    FOOTER_DOCS_URL = os.environ.get('FOOTER_DOCS_URL') or 'https://github.com/yourusername/it-inventory'
    FOOTER_SUPPORT_EMAIL = os.environ.get('FOOTER_SUPPORT_EMAIL') or 'support@itinventory.com'


class DevelopmentConfig(Config):
    """Development environment configuration"""
    
    DEBUG = True
    TESTING = False
    
    # SQLite for development
    SQLALCHEMY_DATABASE_URI = os.environ.get('DEV_DATABASE_URL') or \
        'sqlite:///dev_inventory.db'
    
    SQLALCHEMY_ECHO = True  # Log SQL queries in development
    
    # CSRF Protection
    WTF_CSRF_ENABLED = True
    WTF_CSRF_TIME_LIMIT = None


class ProductionConfig(Config):
    """Production environment configuration"""
    
    DEBUG = False
    TESTING = False
    
    # PostgreSQL for production
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    
    # Enforce secure settings
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Strict'  # Stricter in production
    
    # CSRF Protection
    WTF_CSRF_ENABLED = True
    WTF_CSRF_TIME_LIMIT = None  # CSRF tokens don't expire
    
    # Security Headers
    SECURITY_HEADERS = {
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'SAMEORIGIN',
        'X-XSS-Protection': '1; mode=block',
        'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' https://unpkg.com; style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; img-src 'self' data: https:; font-src 'self' https://cdn.jsdelivr.net;"
    }
    
    # Force HTTPS redirect
    PREFERRED_URL_SCHEME = 'https'
    
    # Database connection pooling for production
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': int(os.environ.get('DB_POOL_SIZE', 10)),
        'max_overflow': int(os.environ.get('DB_MAX_OVERFLOW', 20)),
        'pool_recycle': int(os.environ.get('DB_POOL_RECYCLE', 3600)),
        'pool_pre_ping': True,  # Verify connections before using
        'pool_timeout': int(os.environ.get('DB_POOL_TIMEOUT', 30)),
    }
    
    # Logging configuration
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
    LOG_FILE = os.environ.get('LOG_FILE', 'logs/production.log')
    
    # Rate limiting (if implemented)
    RATELIMIT_ENABLED = os.environ.get('RATELIMIT_ENABLED', 'true').lower() in ['true', 'on', '1']
    
    def __init__(self):
        super().__init__()
        # Validate required environment variables in production
        required_vars = ['SECRET_KEY', 'DATABASE_URL', 'MAIL_SERVER', 'MAIL_USERNAME', 'MAIL_PASSWORD']
        missing_vars = [var for var in required_vars if not os.environ.get(var)]
        
        if missing_vars:
            raise ValueError(f"Required environment variables not set: {', '.join(missing_vars)}")


class StagingConfig(Config):
    """Staging environment configuration (pre-production testing)"""
    
    DEBUG = False
    TESTING = False
    
    # PostgreSQL for staging
    SQLALCHEMY_DATABASE_URI = os.environ.get('STAGING_DATABASE_URL') or os.environ.get('DATABASE_URL')
    
    # Similar to production but with some relaxed settings for testing
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_SAMESITE = 'Lax'
    
    # Database connection pooling (smaller pool than production)
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 5,
        'max_overflow': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
    }
    
    # Enable SQL logging in staging for debugging
    SQLALCHEMY_ECHO = os.environ.get('SQLALCHEMY_ECHO', 'false').lower() in ['true', 'on', '1']
    
    # Logging
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'DEBUG')
    LOG_FILE = os.environ.get('LOG_FILE', 'logs/staging.log')


class TestingConfig(Config):
    """Testing environment configuration"""
    
    TESTING = True
    DEBUG = True
    
    # In-memory SQLite for testing
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    
    # Disable CSRF for testing
    WTF_CSRF_ENABLED = False
    
    # Disable mail sending in tests
    MAIL_SUPPRESS_SEND = True


# Configuration dictionary
config = {
    'development': DevelopmentConfig,
    'staging': StagingConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
