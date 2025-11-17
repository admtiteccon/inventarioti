"""
Script para atualizar a função de um usuário
"""
from app import create_app, db
from app.models import User

app = create_app('development')

with app.app_context():
    # Buscar o usuário pelo email
    email = 'admti.teccon@hotmail.com'
    user = User.query.filter_by(email=email).first()
    
    if user:
        print(f"\n✓ Usuário encontrado: {user.name}")
        print(f"  Email: {user.email}")
        print(f"  Função atual: {user.role}")
        
        # Atualizar para admin
        user.role = 'admin'
        db.session.commit()
        
        print(f"  Nova função: {user.role}")
        print("\n✓ Usuário atualizado com sucesso!")
        print("\nAgora você tem acesso total ao sistema:")
        print("  - Criar/Editar Hardware")
        print("  - Criar/Editar Software")
        print("  - Gerar Relatórios")
        print("  - Gerenciar Usuários")
        print("  - Todas as funcionalidades administrativas")
    else:
        print(f"\n❌ Usuário com email '{email}' não encontrado.")
