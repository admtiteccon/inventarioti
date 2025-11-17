import os
from app import create_app, db
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get configuration from environment variable or use default
config_name = os.environ.get('FLASK_ENV', 'development')

# Create application instance
app = create_app(config_name)


@app.shell_context_processor
def make_shell_context():
    """
    Make database and models available in Flask shell.
    Run with: flask shell
    """
    from app.models.user import User
    from app.models.hardware import Hardware
    from app.models.software import Software, License, HardwareSoftware
    from app.models.token import PasswordResetToken, APIToken
    
    return {
        'db': db,
        'User': User,
        'Hardware': Hardware,
        'Software': Software,
        'License': License,
        'HardwareSoftware': HardwareSoftware,
        'PasswordResetToken': PasswordResetToken,
        'APIToken': APIToken,
    }


@app.cli.command()
def init_db():
    """Initialize the database with tables."""
    db.create_all()
    print('Database initialized successfully.')


@app.cli.command()
def create_admin():
    """Create an initial admin user."""
    from getpass import getpass
    from app.services.auth_service import AuthService
    
    print('Create Admin User')
    print('-' * 40)
    
    name = input('Full Name: ').strip()
    email = input('Email: ').strip().lower()
    password = getpass('Password: ')
    password_confirm = getpass('Confirm Password: ')
    
    if not name or not email or not password:
        print('Error: All fields are required.')
        return
    
    if password != password_confirm:
        print('Error: Passwords do not match.')
        return
    
    if len(password) < 8:
        print('Error: Password must be at least 8 characters long.')
        return
    
    try:
        user = AuthService.register_user(name, email, password, role='admin')
        print(f'\nSuccess! Admin user created:')
        print(f'  Name: {user.name}')
        print(f'  Email: {user.email}')
        print(f'  Role: {user.role}')
    except ValueError as e:
        print(f'Error: {e}')
    except Exception as e:
        print(f'Error: An unexpected error occurred: {e}')


if __name__ == '__main__':
    # Run the development server
    app.run(
        host=os.environ.get('FLASK_HOST', '0.0.0.0'),
        port=int(os.environ.get('FLASK_PORT', 5000)),
        debug=app.config['DEBUG']
    )
