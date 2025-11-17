"""
Script para traduzir templates do sistema para português
"""
import os
import re

# Dicionário de traduções
translations = {
    # Títulos e cabeçalhos
    'Hardware Assets': 'Ativos de Hardware',
    'Software Assets': 'Ativos de Software',
    'Add Hardware': 'Adicionar Hardware',
    'Add Software': 'Adicionar Software',
    'Edit Hardware': 'Editar Hardware',
    'Edit Software': 'Editar Software',
    'Hardware Details': 'Detalhes do Hardware',
    'Software Details': 'Detalhes do Software',
    'Import Hardware': 'Importar Hardware',
    'Import Software': 'Importar Software',
    'Generate Report': 'Gerar Relatório',
    'Scheduled Reports': 'Relatórios Agendados',
    'Create Scheduled Report': 'Criar Relatório Agendado',
    
    # Campos de formulário
    'Name': 'Nome',
    'Type': 'Tipo',
    'Manufacturer': 'Fabricante',
    'Model': 'Modelo',
    'Serial Number': 'Número de Série',
    'Purchase Date': 'Data de Compra',
    'Warranty Expiry': 'Vencimento da Garantia',
    'Status': 'Status',
    'Location': 'Localização',
    'Assigned To': 'Atribuído a',
    'Description': 'Descrição',
    'Notes': 'Observações',
    'Version': 'Versão',
    'Vendor': 'Fornecedor',
    'License Type': 'Tipo de Licença',
    'License Key': 'Chave de Licença',
    'Expiration Date': 'Data de Vencimento',
    'Total Licenses': 'Total de Licenças',
    'Licenses in Use': 'Licenças em Uso',
    
    # Botões e ações
    'Save': 'Salvar',
    'Cancel': 'Cancelar',
    'Delete': 'Excluir',
    'Edit': 'Editar',
    'View': 'Visualizar',
    'Back': 'Voltar',
    'Submit': 'Enviar',
    'Import': 'Importar',
    'Export': 'Exportar',
    'Download': 'Baixar',
    'Upload': 'Enviar',
    'Search': 'Pesquisar',
    'Filter': 'Filtrar',
    'Clear': 'Limpar',
    'Apply': 'Aplicar',
    'Close': 'Fechar',
    'Confirm': 'Confirmar',
    
    # Status
    'Active': 'Ativo',
    'Inactive': 'Inativo',
    'Maintenance': 'Manutenção',
    'Disposal': 'Descarte',
    'Retired': 'Aposentado',
    
    # Tipos
    'Desktop': 'Desktop',
    'Laptop': 'Notebook',
    'Server': 'Servidor',
    'Printer': 'Impressora',
    'Scanner': 'Scanner',
    'Network Device': 'Dispositivo de Rede',
    'Mobile Device': 'Dispositivo Móvel',
    'Other': 'Outro',
    
    # Licenças
    'Perpetual': 'Perpétua',
    'Subscription': 'Assinatura',
    'Trial': 'Teste',
    'Open Source': 'Código Aberto',
    
    # Mensagens
    'Are you sure?': 'Tem certeza?',
    'This action cannot be undone': 'Esta ação não pode ser desfeita',
    'No results found': 'Nenhum resultado encontrado',
    'Loading...': 'Carregando...',
    'Success': 'Sucesso',
    'Error': 'Erro',
    'Warning': 'Aviso',
    'Info': 'Informação',
    
    # Paginação
    'Previous': 'Anterior',
    'Next': 'Próximo',
    'Page': 'Página',
    'of': 'de',
    'Showing': 'Mostrando',
    
    # Relatórios
    'Report Type': 'Tipo de Relatório',
    'Date Range': 'Período',
    'Start Date': 'Data Inicial',
    'End Date': 'Data Final',
    'Format': 'Formato',
    'Generate': 'Gerar',
    
    # Outros
    'Required': 'Obrigatório',
    'Optional': 'Opcional',
    'Select': 'Selecionar',
    'Choose': 'Escolher',
    'Browse': 'Procurar',
    'All': 'Todos',
    'None': 'Nenhum',
}

print("✓ Dicionário de traduções carregado")
print(f"  Total de traduções: {len(translations)}")
