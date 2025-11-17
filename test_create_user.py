"""
Script de teste para verificar criação de usuários
"""
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

from app import create_app, db
from app.services.auth_service import AuthService

# Create application
app = create_app('development')

with app.app_context():
    try:
        print("=" * 60)
        print("TESTE DE CRIAÇÃO DE USUÁRIO")
        print("=" * 60)
        
        # Dados de teste
        test_user = {
            'name': 'Usuário Teste',
            'email': 'teste@exemplo.com',
            'password': 'senha12345',
            'role': 'user'
        }
        
        print(f"\n1. Tentando criar usuário:")
        print(f"   Nome: {test_user['name']}")
        print(f"   Email: {test_user['email']}")
        print(f"   Função: {test_user['role']}")
        
        # Verificar se usuário já existe
        from app.models.user import User
        existing = User.query.filter_by(email=test_user['email']).first()
        
        if existing:
            print(f"\n⚠️  Usuário já existe! Removendo para teste...")
            db.session.delete(existing)
            db.session.commit()
            print("   ✓ Usuário removido")
        
        # Tentar criar usuário
        print(f"\n2. Criando usuário...")
        user = AuthService.register_user(
            name=test_user['name'],
            email=test_user['email'],
            password=test_user['password'],
            role=test_user['role']
        )
        
        print(f"   ✓ Usuário criado com sucesso!")
        print(f"   ID: {user.id}")
        print(f"   Nome: {user.name}")
        print(f"   Email: {user.email}")
        print(f"   Função: {user.role}")
        
        # Verificar se foi salvo no banco
        print(f"\n3. Verificando no banco de dados...")
        saved_user = User.query.filter_by(email=test_user['email']).first()
        
        if saved_user:
            print(f"   ✓ Usuário encontrado no banco!")
            print(f"   ID: {saved_user.id}")
            print(f"   Nome: {saved_user.name}")
        else:
            print(f"   ✗ ERRO: Usuário não encontrado no banco!")
        
        # Testar autenticação
        print(f"\n4. Testando autenticação...")
        auth_user = AuthService.authenticate(test_user['email'], test_user['password'])
        
        if auth_user:
            print(f"   ✓ Autenticação bem-sucedida!")
        else:
            print(f"   ✗ ERRO: Falha na autenticação!")
        
        print(f"\n" + "=" * 60)
        print("TESTE CONCLUÍDO COM SUCESSO!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n" + "=" * 60)
        print(f"ERRO DURANTE O TESTE:")
        print(f"=" * 60)
        print(f"Tipo: {type(e).__name__}")
        print(f"Mensagem: {str(e)}")
        print(f"\nDetalhes completos:")
        import traceback
        traceback.print_exc()
