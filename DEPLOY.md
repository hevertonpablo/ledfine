# Deploy Ledfine no Coolify

## Configurações do Coolify

### Variáveis de Ambiente Necessárias

Configure estas variáveis de ambiente no Coolify:

```bash
# Laravel Configuration
APP_NAME=Bagisto
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:FYkNu7NFf/LTNe/QF7aMrLTMPOQVk56Rq/o9xa9StrM=

# URL da aplicação (substitua pelo seu domínio do Coolify)
APP_URL=https://seu-dominio.coolify.io
APP_ADMIN_URL=admin

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=ledfine_db
DB_USERNAME=ledfine_user
DB_PASSWORD=sua-senha-segura

# Session Configuration
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

# Cache Configuration
CACHE_STORE=file
QUEUE_CONNECTION=sync

# Mail Configuration (opcional)
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=seu-email@gmail.com
MAIL_PASSWORD=sua-senha-app
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=seu-email@gmail.com
MAIL_FROM_NAME="${APP_NAME}"
```

### Configuração do Docker

O projeto está configurado para funcionar com Docker Compose. O Coolify deve:

1. **Build**: Usar o `docker-compose.yml` na raiz do projeto
2. **Port**: Expor a porta `80` do serviço `webserver`
3. **Health Check**: A aplicação tem um endpoint `/health.php` para monitoramento

### Estrutura dos Serviços

- **app**: Container PHP-FPM com Laravel/Bagisto
- **webserver**: Container Nginx como proxy reverso
- **db**: Container MySQL para banco de dados

### Comandos de Deploy

Após cada deploy, o container executará automaticamente:

1. Aguarda conexão com banco de dados
2. Limpa caches do Laravel
3. Executa migrations
4. Gera chave da aplicação (se necessário)
5. Cria symlink para storage
6. Cacheia configurações (em produção)

### Endpoints de Monitoramento

- `/health.php` - Health check detalhado (JSON)
- `/healthz` - Health check simples (texto)

### Troubleshooting

Se encontrar problemas:

1. Verifique os logs dos containers no Coolify
2. Certifique-se que as variáveis de ambiente estão configuradas
3. Verifique se o banco de dados está acessível
4. Teste o endpoint `/health.php` para diagnóstico

### Primeiros Passos Após Deploy

1. Acesse a aplicação pelo domínio configurado
2. Se for o primeiro deploy, o Bagisto pode precisar de configuração inicial
3. Acesse `/admin` para área administrativa

## Estrutura de Arquivos Importantes

- `Dockerfile` - Configuração do container PHP
- `Dockerfile.nginx` - Configuração do container Nginx  
- `docker-compose.yml` - Orquestração dos containers
- `nginx/default.conf` - Configuração do Nginx
- `scripts/entrypoint.sh` - Script de inicialização
- `app/app/Http/Middleware/TrustProxies.php` - Middleware para proxies
