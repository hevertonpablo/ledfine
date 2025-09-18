# Correções Aplicadas - Bad Gateway 502

## 🔍 Problemas Identificados

### Container `app` em loop infinito:
1. **Não encontrava arquivo `artisan`** - Tentando comandos em diretório errado
2. **Falha na conexão com banco** - Credenciais ou configuração incorreta
3. **Nunca iniciava PHP-FPM** - Ficava preso no loop de inicialização

### Nginx retornando 502:
- PHP-FPM não estava rodando (devido aos problemas acima)
- `connect() failed (111: Connection refused)`

## ✅ Soluções Implementadas

### 1. Entrypoint Robusto
- ✅ **entrypoint-minimal.sh**: Inicia PHP-FPM mesmo com falhas
- ✅ **entrypoint-simple.sh**: Configuração Laravel com fallbacks
- ✅ Verificação de diretórios e arquivos
- ✅ Logs detalhados para debug

### 2. Arquivos de Debug
- ✅ **debug.php**: Mostra variáveis de ambiente e testa conexão DB
- ✅ **info.php**: Informações básicas do PHP
- ✅ Logs detalhados no entrypoint

### 3. Healthchecks Melhorados
- ✅ Container `app` com verificação de processo PHP-FPM
- ✅ Container `webserver` com múltiplos endpoints de fallback

## 🚀 Próximos Passos

### 1. Rebuild no Coolify
Execute o rebuild completo da aplicação.

### 2. Verificar Logs Após Rebuild

**Container app deve mostrar:**
```
🚀 Starting PHP-FPM Container...
📍 Working directory: /var/www/app
📍 Current directory: /var/www/app
📁 Directory contents: [lista de arquivos]
🎉 Starting PHP-FPM...
```

**Container webserver deve parar de mostrar:**
```
connect() failed (111: Connection refused)
```

### 3. Testar Endpoints

1. **`/debug.php`** - Verificar variáveis de ambiente e conexão DB
2. **`/info.php`** - Teste básico do PHP
3. **`/healthz`** - Health check simples
4. **`/`** - Aplicação principal

### 4. Configurar Variáveis de Ambiente no Coolify

Se o `/debug.php` mostrar que as variáveis não estão configuradas:

```bash
DB_HOST=db
DB_PORT=3306
DB_DATABASE=ledfine_db
DB_USERNAME=ledfine_user
DB_PASSWORD=sua-senha-do-coolify
APP_ENV=production
APP_DEBUG=false
```

### 5. Se Ainda Houver Problemas

#### Se PHP-FPM não iniciar:
- Verificar logs do container `app`
- Verificar se o composer install funcionou
- Verificar permissões de arquivos

#### Se conexão DB falhar:
- Verificar credenciais no Coolify
- Verificar se o container `db` está rodando
- Usar o endpoint `/debug.php` para diagnosticar

#### Se Nginx ainda der 502:
- Verificar se containers estão na mesma rede
- Verificar se porta 9000 está exposta no container `app`

## 🔧 Comandos de Debug Local

```bash
# Build local
docker-compose up --build -d

# Verificar status
docker-compose ps

# Logs do app
docker-compose logs app

# Entrar no container
docker-compose exec app bash

# Verificar PHP-FPM
docker-compose exec app pgrep php-fpm
```

O entrypoint agora é muito mais robusto e deve iniciar o PHP-FPM mesmo se houver problemas com o Laravel ou banco de dados.
