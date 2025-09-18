# Troubleshooting Ledfine

## Status Atual
- ❌ Container `app` não está iniciando corretamente
- ❌ PHP-FPM não está rodando
- ❌ Nginx retorna 502 (não consegue conectar no PHP-FPM)

## Alterações Feitas

### 1. Dockerfile melhorado
- ✅ Entrypoint inline criado diretamente no Dockerfile
- ✅ Adicionado `procps` para comando `pgrep`
- ✅ Melhoradas permissões de arquivos

### 2. Docker Compose atualizado
- ✅ Adicionada exposição da porta 9000 no container `app`
- ✅ Healthcheck para o container `app`
- ✅ Dependência do webserver ajustada para aguardar `app` saudável

### 3. Arquivos de teste criados
- ✅ `/info.php` - Teste básico de PHP e conectividade
- ✅ `/health.php` - Health check completo do Laravel

## Próximos Passos

### 1. Rebuild no Coolify
Faça o rebuild completo da aplicação para aplicar as mudanças.

### 2. Verificar Logs
Após o rebuild, verificar os logs de cada container:

**Container app:**
```
🚀 Starting Laravel Application...
⏳ Waiting for database...
✅ Database ready!
🔧 Setting up Laravel...
🗃️ Running migrations...
🎉 Starting PHP-FPM...
```

**Container webserver:**
```
nginx/1.29.1
ready for start up
```

### 3. Testar Endpoints

Depois que os containers estiverem rodando, teste:

1. **`/info.php`** - Deve mostrar informações básicas do PHP
2. **`/healthz`** - Deve retornar "OK"
3. **`/health.php`** - Deve retornar JSON com status da aplicação
4. **`/`** - Página principal do Bagisto

### 4. Debug se Ainda Houver Problemas

Se o container `app` ainda não iniciar:

1. Verificar se o script inline está sendo executado
2. Verificar logs de erro específicos
3. Verificar conectividade com banco de dados

Se o Nginx ainda retornar 502:

1. Verificar se PHP-FPM está rodando na porta 9000
2. Verificar conectividade de rede entre containers
3. Verificar configuração do Nginx

## Comandos Úteis para Debug Local

Se quiser testar localmente:

```bash
# Build e start
docker-compose up --build -d

# Verificar status dos containers
docker-compose ps

# Ver logs do app
docker-compose logs app

# Ver logs do webserver
docker-compose logs webserver

# Entrar no container app
docker-compose exec app bash

# Verificar se PHP-FPM está rodando
docker-compose exec app pgrep -f php-fpm

# Testar conectividade
docker-compose exec webserver curl -v http://app:9000
```

## Variáveis de Ambiente Importantes

Certifique-se de que estas variáveis estão configuradas no Coolify:

```bash
DB_HOST=db
DB_DATABASE=ledfine_db
DB_USERNAME=ledfine_user
DB_PASSWORD=sua-senha
APP_ENV=production
APP_DEBUG=false
```
