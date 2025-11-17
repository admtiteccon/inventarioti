"""
Script para criar pacote ZIP de deployment
Exclui arquivos desnecessários e prepara para produção
"""

import os
import zipfile
from datetime import datetime

# Arquivos e diretórios a INCLUIR
INCLUDE_PATTERNS = [
    'app/',
    'migrations/',
    'config.py',
    'run.py',
    'requirements.txt',
    'startup.sh',
    '.deployment',
    'runtime.txt',
    'create_company_settings_table.py',
    'gunicorn_config.py',
]

# Arquivos e diretórios a EXCLUIR
EXCLUDE_PATTERNS = [
    '__pycache__',
    '*.pyc',
    '*.pyo',
    '*.db',
    '*.sqlite',
    '*.sqlite3',
    '.env',
    '.env.local',
    '.env.example',
    'venv/',
    'env/',
    '.vscode/',
    '.idea/',
    '.git/',
    '.gitignore',
    'logs/',
    'uploads/',
    'backups/',
    '*.log',
    '.DS_Store',
    'Thumbs.db',
    'test_*.py',
    '*.md',  # Todos os arquivos markdown
    '*.txt',  # Todos os arquivos txt (exceto requirements.txt)
    'translate_system.py',
    'create_excel_templates.py',
    'install_linux.sh',
    'create_deployment_package.py',
    '.kiro/',
    'inventario.py',
    'dev_inventory.db',
]

# Exceções - arquivos que devem ser incluídos mesmo que correspondam aos padrões de exclusão
INCLUDE_EXCEPTIONS = [
    'requirements.txt',
    'runtime.txt',
]

def should_exclude(path):
    """Verifica se o arquivo/diretório deve ser excluído"""
    path_lower = path.lower()
    filename = os.path.basename(path)
    
    # Verificar exceções primeiro
    if filename in INCLUDE_EXCEPTIONS:
        return False
    
    for pattern in EXCLUDE_PATTERNS:
        if pattern.endswith('/'):
            # Diretório
            if pattern[:-1] in path_lower:
                return True
        elif pattern.startswith('*.'):
            # Extensão
            if path_lower.endswith(pattern[1:]):
                return True
        else:
            # Nome exato ou contém
            if pattern in path_lower:
                return True
    
    return False

def create_deployment_zip():
    """Cria arquivo ZIP para deployment"""
    
    # Nome do arquivo ZIP
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    zip_filename = f'it-inventory-deployment-{timestamp}.zip'
    
    print("=" * 60)
    print("CRIANDO PACOTE DE DEPLOYMENT")
    print("=" * 60)
    print(f"\nArquivo: {zip_filename}\n")
    
    # Contador de arquivos
    file_count = 0
    excluded_count = 0
    
    # Criar ZIP
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        
        # Percorrer diretório atual
        for root, dirs, files in os.walk('.'):
            
            # Remover diretórios excluídos da lista
            dirs[:] = [d for d in dirs if not should_exclude(os.path.join(root, d))]
            
            for file in files:
                file_path = os.path.join(root, file)
                
                # Verificar se deve excluir
                if should_exclude(file_path):
                    excluded_count += 1
                    continue
                
                # Adicionar ao ZIP
                arcname = file_path[2:] if file_path.startswith('.\\') or file_path.startswith('./') else file_path
                zipf.write(file_path, arcname)
                file_count += 1
                print(f"✓ Adicionado: {arcname}")
    
    # Estatísticas
    zip_size = os.path.getsize(zip_filename)
    zip_size_mb = zip_size / (1024 * 1024)
    
    print("\n" + "=" * 60)
    print("PACOTE CRIADO COM SUCESSO!")
    print("=" * 60)
    print(f"\nArquivo: {zip_filename}")
    print(f"Tamanho: {zip_size_mb:.2f} MB ({zip_size:,} bytes)")
    print(f"Arquivos incluídos: {file_count}")
    print(f"Arquivos excluídos: {excluded_count}")
    
    print("\n" + "=" * 60)
    print("PRÓXIMOS PASSOS")
    print("=" * 60)
    print("\n1. AZURE APP SERVICE:")
    print("   - Portal → App Service → Deployment Center")
    print("   - Escolher 'ZIP Deploy'")
    print(f"   - Upload: {zip_filename}")
    
    print("\n2. VPS LINUX:")
    print(f"   scp {zip_filename} user@servidor:/tmp/")
    print("   ssh user@servidor")
    print(f"   unzip /tmp/{zip_filename} -d /home/inventory/it-inventory")
    
    print("\n3. VPS WINDOWS:")
    print("   - Copiar via RDP")
    print(f"   - Extrair {zip_filename}")
    print("   - Copiar para C:\\inetpub\\inventory")
    
    print("\n" + "=" * 60)
    
    return zip_filename

if __name__ == '__main__':
    try:
        zip_file = create_deployment_zip()
        print(f"\n✓ Pacote pronto: {zip_file}\n")
    except Exception as e:
        print(f"\n✗ Erro ao criar pacote: {e}\n")
        import traceback
        traceback.print_exc()
