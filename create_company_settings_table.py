"""
Script to create company_settings table in the database.
Run this script to add the new table without losing existing data.
"""

import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

from app import create_app, db
from app.models.company import CompanySettings

# Create application
app = create_app('development')

with app.app_context():
    try:
        print("=" * 60)
        print("CRIANDO TABELA DE CONFIGURAÇÕES DA EMPRESA")
        print("=" * 60)
        
        # Create the table
        print("\n1. Criando tabela company_settings...")
        db.create_all()
        print("   ✓ Tabela criada com sucesso!")
        
        # Check if settings already exist
        print("\n2. Verificando configurações existentes...")
        settings = CompanySettings.query.first()
        
        if settings:
            print(f"   ✓ Configurações já existem:")
            print(f"     - Empresa: {settings.company_name}")
            print(f"     - Sistema: {settings.system_name}")
        else:
            print("   ℹ Nenhuma configuração encontrada")
            print("\n3. Criando configurações padrão...")
            
            # Create default settings
            settings = CompanySettings(
                company_name='IT Inventory System',
                system_name='Sistema de Inventário de TI',
                primary_color='#0d6efd'
            )
            db.session.add(settings)
            db.session.commit()
            
            print("   ✓ Configurações padrão criadas!")
            print(f"     - Empresa: {settings.company_name}")
            print(f"     - Sistema: {settings.system_name}")
        
        print(f"\n" + "=" * 60)
        print("TABELA CRIADA COM SUCESSO!")
        print("=" * 60)
        print("\nPróximos passos:")
        print("1. Acesse: http://127.0.0.1:5000/settings/")
        print("2. Configure os dados da sua empresa")
        print("3. Faça upload do logo")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n" + "=" * 60)
        print(f"ERRO AO CRIAR TABELA:")
        print(f"=" * 60)
        print(f"Tipo: {type(e).__name__}")
        print(f"Mensagem: {str(e)}")
        print(f"\nDetalhes completos:")
        import traceback
        traceback.print_exc()
