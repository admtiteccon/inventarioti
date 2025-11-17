#!/usr/bin/env python3
"""
WSGI entry point for production deployment.

This file is used by WSGI servers (Gunicorn, uWSGI, mod_wsgi) to run the application.
"""
import os
import sys

# Add application directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

# Load environment variables from .env file
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# Import the Flask application
from run import app as application

if __name__ == '__main__':
    application.run()
