"""
Script para criar usuário administrador
"""
from app import create_app, db
from app.models import User

app = create_app('development')

with app.app_context():
    # Verificar se já existe
    existing = User.query.filter_by(email='admin@teste.com').first()
    if existing:
        print('❌ Usuário admin@teste.com já existe!')
    else:
        # Criar novo usuário admin
        user = User(
            name='Administrador',
            email='admin@teste.com',
            role='admin'
        )
        user.set_password('admin123')
        
        db.session.add(user)
        db.session.commit()
        
        print('✓ Usuário administrador criado com sucesso!')
        print('  Email: admin@teste.com')
        print('  Senha: admin123')
