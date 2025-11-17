# 📋 Guia de Importação - Templates Excel

## 📦 Arquivos Criados

1. **template_hardware.xlsx** - Template para importação de Hardware
2. **template_software.xlsx** - Template para importação de Software

---

## 💻 Template de Hardware

### Campos Obrigatórios (*)
- **name*** - Nome do hardware (Ex: "Notebook Dell Latitude 5420")
- **type*** - Tipo do hardware
- **serial_number*** - Número de série único

### Tipos de Hardware Válidos
- `desktop` - Desktop
- `laptop` - Notebook
- `server` - Servidor
- `printer` - Impressora
- `scanner` - Scanner
- `network_device` - Dispositivo de Rede
- `mobile` - Dispositivo Móvel
- `other` - Outro

### Status Válidos
- `active` - Ativo (padrão)
- `maintenance` - Em manutenção
- `disposal` - Para descarte
- `retired` - Aposentado

### Campos Opcionais
- **manufacturer** - Fabricante (Ex: "Dell", "HP", "Lenovo")
- **model** - Modelo (Ex: "Latitude 5420")
- **status** - Status (padrão: "active")
- **acquisition_date** - Data de aquisição (formato: YYYY-MM-DD)
- **warranty_date** - Data de vencimento da garantia (formato: YYYY-MM-DD)
- **location** - Localização (Ex: "Prédio A, Sala 301")
- **latitude** - Latitude (Ex: -23.5505)
- **longitude** - Longitude (Ex: -46.6333)
- **cpu** - Processador (Ex: "Intel Core i7-1165G7")
- **ram** - Memória RAM (Ex: "16GB DDR4")
- **os** - Sistema Operacional (Ex: "Windows 11 Pro")
- **ip_address** - Endereço IP (Ex: "192.168.1.100")
- **responsible_user_email** - Email do usuário responsável

### Exemplo de Linha
```
name: Notebook Dell Latitude 5420
type: laptop
manufacturer: Dell
model: Latitude 5420
serial_number: SN123456789
status: active
acquisition_date: 2024-01-15
warranty_date: 2027-01-15
location: Prédio A, Sala 301
latitude: -23.5505
longitude: -46.6333
cpu: Intel Core i7-1165G7
ram: 16GB DDR4
os: Windows 11 Pro
ip_address: 192.168.1.100
responsible_user_email: usuario@empresa.com
```

---

## 📦 Template de Software

### Campos Obrigatórios (*)
- **name*** - Nome do software (Ex: "Microsoft Office 365")
- **license_type*** - Tipo de licença

### Tipos de Licença Válidos
- `perpetual` - Perpétua (compra única)
- `subscription` - Assinatura (renovação periódica)
- `trial` - Teste/Trial
- `open_source` - Código Aberto
- `oem` - OEM (vem com hardware)
- `volume` - Volume (múltiplas licenças)

### Status Válidos
- `active` - Ativo (padrão)
- `expired` - Expirado
- `trial` - Em teste
- `pending_renewal` - Pendente renovação

### Campos Opcionais
- **version** - Versão (Ex: "2024", "2024.1.0")
- **vendor** - Fornecedor (Ex: "Microsoft", "Adobe")
- **license_key** - Chave de licença
- **expiration_date** - Data de vencimento (formato: YYYY-MM-DD)
- **status** - Status (padrão: "active")
- **total_licenses** - Total de licenças disponíveis (para pool)
- **alert_threshold_days** - Dias antes do vencimento para alertar (padrão: 30)

### Exemplo de Linha
```
name: Microsoft Office 365
version: 2024
vendor: Microsoft
license_type: subscription
license_key: XXXXX-XXXXX-XXXXX-XXXXX
expiration_date: 2025-12-31
status: active
total_licenses: 50
alert_threshold_days: 30
```

---

## 📝 Como Usar os Templates

### Passo 1: Abrir o Template
1. Abra o arquivo Excel correspondente
2. Você verá 2 linhas de exemplo
3. Mantenha a primeira linha (cabeçalhos)

### Passo 2: Preencher os Dados
1. Delete as linhas de exemplo (linhas 2 e 3)
2. Adicione seus dados nas linhas seguintes
3. Preencha pelo menos os campos obrigatórios (*)
4. Use os valores válidos listados acima

### Passo 3: Salvar o Arquivo
1. Salve o arquivo Excel
2. Mantenha o formato .xlsx

### Passo 4: Importar no Sistema
1. Acesse o sistema: http://127.0.0.1:5000
2. Faça login como Admin ou Técnico
3. Para Hardware:
   - Menu Hardware → Importar
   - Selecione o arquivo
   - Clique em "Importar"
4. Para Software:
   - Menu Software → Importar
   - Selecione o arquivo
   - Clique em "Importar"

---

## ⚠️ Dicas Importantes

### Datas
- Use sempre o formato: YYYY-MM-DD
- Exemplo: 2024-01-15 (15 de janeiro de 2024)
- Deixe em branco se não tiver data

### Números de Série
- Devem ser únicos
- Não podem se repetir no sistema
- Use o número de série real do equipamento

### Emails de Usuários
- O usuário deve existir no sistema
- Use o email exato cadastrado
- Deixe em branco se não tiver responsável

### Coordenadas (Latitude/Longitude)
- Use ponto (.) como separador decimal
- Exemplo: -23.5505 (não -23,5505)
- Deixe em branco se não tiver localização

### Licenças de Software
- Se informar `total_licenses`, um pool será criado
- Deixe em branco para software sem pool
- `alert_threshold_days` define quando alertar sobre vencimento

---

## 🔍 Validação de Dados

O sistema valida automaticamente:
- ✅ Campos obrigatórios preenchidos
- ✅ Tipos e status válidos
- ✅ Formato de datas correto
- ✅ Números de série únicos
- ✅ Emails de usuários existentes

Se houver erros:
- O sistema mostrará quais linhas têm problemas
- Corrija os erros no Excel
- Tente importar novamente

---

## 📊 Exemplo Completo

### Hardware (5 equipamentos)
```
name,type,manufacturer,model,serial_number,status,location
Notebook Dell 001,laptop,Dell,Latitude 5420,SN001,active,Sala 301
Desktop HP 001,desktop,HP,EliteDesk 800,SN002,active,Sala 302
Servidor Principal,server,Dell,PowerEdge R740,SN003,active,Data Center
Impressora HP 001,printer,HP,LaserJet Pro,SN004,active,Sala 101
Scanner Canon 001,scanner,Canon,DR-C225,SN005,active,Sala 102
```

### Software (3 aplicações)
```
name,version,vendor,license_type,expiration_date,total_licenses
Microsoft Office 365,2024,Microsoft,subscription,2025-12-31,50
Adobe Acrobat Pro,2024,Adobe,perpetual,,10
Zoom Business,5.16,Zoom,subscription,2025-06-30,25
```

---

## 🆘 Suporte

Se tiver problemas:
1. Verifique se os campos obrigatórios estão preenchidos
2. Confirme que os valores estão nos formatos corretos
3. Verifique se não há números de série duplicados
4. Consulte os logs de erro na tela de importação

---

**Criado em**: 12/11/2025
**Versão**: 1.0
**Sistema**: Inventário de TI
