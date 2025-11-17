"""
Script para listar todos os usuários do sistema
"""
from app import create_app, db
from app.models import User

app = create_app('development')

with app.app_context():
    users = User.query.all()
    
    print("\n" + "="*60)
    print("USUÁRIOS DO SISTEMA")
    print("="*60)
    
    if not users:
        print("Nenhum usuário encontrado.")
    else:
        for user in users:
            print(f"\nID: {user.id}")
            print(f"Nome: {user.name}")
            print(f"Email: {user.email}")
            print(f"Função: {user.role}")
            print(f"Criado em: {user.created_at.strftime('%d/%m/%Y %H:%M')}")
            print("-" * 60)
    
    print(f"\nTotal: {len(users)} usuário(s)")
    print("="*60 + "\n")
