#!/bin/bash

echo "========================================="
echo "Starting IT Inventory System on Azure"
echo "========================================="

# Instalar dependências
echo "Installing dependencies..."
pip install -r requirements.txt

# Criar diretórios necessários
echo "Creating directories..."
mkdir -p /home/site/wwwroot/logs
mkdir -p /home/site/wwwroot/app/static/uploads/logos

# Inicializar banco de dados
echo "Initializing database..."
python -c "from app import create_app, db; app = create_app('production'); app.app_context().push(); db.create_all(); print('✓ Database tables created')" || echo "⚠ Database already initialized"

# Criar tabela de configurações da empresa
echo "Creating company settings table..."
python create_company_settings_table.py || echo "⚠ Company settings already initialized"

echo "========================================="
echo "Starting Gunicorn server..."
echo "========================================="

# Iniciar Gunicorn
gunicorn --bind=0.0.0.0:8000 \
         --timeout 600 \
         --workers 4 \
         --threads 2 \
         --worker-class sync \
         --access-logfile /home/site/wwwroot/logs/access.log \
         --error-logfile /home/site/wwwroot/logs/error.log \
         --log-level info \
         run:app
