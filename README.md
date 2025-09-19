# Bagisto E-commerce - LEDFine

Uma aplicação e-commerce completa baseada no Bagisto, configurada para funcionar tanto em desenvolvimento local quanto em produção.

## 🚀 Ambientes

### Desenvolvimento Local

Para rodar o projeto localmente usando Docker:

```bash
# 1. Clone o repositório
git clone <repository-url>
cd ledfine-bagisto

# 2. Copie o arquivo de ambiente
cp .env.example .env

# 3. Configure as variáveis necessárias no .env
# As principais já estão configuradas para desenvolvimento

# 4. Suba os containers
docker-compose up -d

# 5. Instale as dependências e configure o Bagisto
docker-compose exec laravel.test composer install
docker-compose exec laravel.test php artisan key:generate
docker-compose exec laravel.test php artisan bagisto:install
```

**URLs de Desenvolvimento:**
- **Loja**: http://localhost
- **Admin**: http://localhost/admin
- **Mailpit**: http://localhost:8025
- **Kibana**: http://localhost:5601

### Produção (Coolify)

O projeto está configurado para deploy automático via Coolify:

1. **Docker Compose**: `docker-compose.prod.yml` otimizado para produção
2. **Dockerfile**: `Dockerfile.prod` com build multi-stage
3. **Deploy Script**: `deploy.sh` para automatizar a instalação

**Variáveis de Ambiente Necessárias:**
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.com
DB_HOST=mysql
DB_DATABASE=bagisto
DB_USERNAME=bagisto
DB_PASSWORD=senha-segura
REDIS_HOST=redis
```

## 📋 Funcionalidades

- ✅ **Multi-idioma** (PT-BR configurado)
- ✅ **Multi-moeda** (BRL configurado)
- ✅ **Elasticsearch** para busca avançada
- ✅ **Redis** para cache
- ✅ **MySQL** para banco de dados
- ✅ **Mailpit** para desenvolvimento
- ✅ **Kibana** para monitoramento

## 🛠️ Comandos Úteis

### Desenvolvimento
```bash
# Parar containers
docker-compose down

# Ver logs
docker-compose logs -f laravel.test

# Acessar container
docker-compose exec laravel.test bash

# Rodar comandos Artisan
docker-compose exec laravel.test php artisan <comando>
```

### Manutenção
```bash
# Limpar caches
docker-compose exec laravel.test php artisan cache:clear

# Recriar índices do Elasticsearch
docker-compose exec laravel.test php artisan scout:import

# Backup do banco
docker-compose exec mysql mysqldump -u bagisto -p bagisto > backup.sql
```

## 📁 Estrutura do Projeto

```
├── docker/                 # Configurações Docker para produção
│   ├── nginx/              # Configuração Nginx
│   ├── php/                # Configuração PHP-FPM
│   └── supervisor/         # Configuração Supervisor
├── docker-compose.yml      # Docker Compose para desenvolvimento
├── docker-compose.prod.yml # Docker Compose para produção
├── Dockerfile.prod         # Dockerfile otimizado para produção
├── deploy.sh              # Script de deploy para Coolify
└── .env.example           # Template de variáveis de ambiente
```

## 🔧 Configurações de Produção

O projeto está otimizado para produção com:

- **Nginx** como servidor web
- **PHP-FPM** para processar PHP
- **OpCache** habilitado
- **Supervisor** para gerenciar processos
- **Multi-stage build** para imagens menores
- **Health checks** para todos os serviços

## 📝 Credenciais Padrão

**Admin:**
- Email: admin@example.com
- Senha: admin123

> ⚠️ **Importante**: Altere as credenciais padrão em produção!

## 🆘 Troubleshooting

### Problemas Comuns

1. **Erro de permissão**:
   ```bash
   sudo chown -R $USER:$USER storage bootstrap/cache
   chmod -R 775 storage bootstrap/cache
   ```

2. **Banco não conecta**:
   - Verifique se o MySQL está rodando
   - Confirme as credenciais no .env

3. **Elasticsearch não funciona**:
   ```bash
   docker-compose restart elasticsearch
   docker-compose exec laravel.test php artisan scout:import
   ```

## 📞 Suporte

Para suporte e dúvidas, entre em contato com a equipe de desenvolvimento.
