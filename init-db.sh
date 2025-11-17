#!/bin/bash
# Script de inicialização do banco de dados PostgreSQL

set -e

echo "Inicializando banco de dados..."

# Configurar encoding e locale
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Configurar timezone
    ALTER DATABASE $POSTGRES_DB SET timezone TO 'America/Sao_Paulo';
    
    -- Garantir permissões
    GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;
    
    -- Criar extensões úteis
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";
EOSQL

echo "Banco de dados inicializado com sucesso!"
