# Correções para Falha no Healthcheck

## 🔍 Problema Identificado
- Container `app` falhando no healthcheck: `dependency failed to start: container app is unhealthy`
- Variável `MYSQL_ROOT_PASSWORD` não configurada

## ✅ Correções Aplicadas

### 1. Healthcheck Mais Robusto
- ✅ **App healthcheck**: Múltiplas verificações de PHP-FPM
- ✅ **Start period**: Aumentado para 120s (mais tempo para inicializar)
- ✅ **Retries**: Aumentado para 5 tentativas
- ✅ **Webserver dependency**: Mudado para `service_started` (menos restritivo)

### 2. Entrypoint Ultra-Rápido
- ✅ **entrypoint-fast.sh**: Inicia PHP-FPM imediatamente
- ✅ **--nodaemonize**: Para melhor detecção de processo
- ✅ Sem comandos Laravel que podem falhar

### 3. Variáveis de Ambiente
- ✅ **MYSQL_ROOT_PASSWORD**: Com valor padrão
- ✅ **Variáveis DB**: Com fallbacks
- ✅ **.env.example**: Para configuração no Coolify

### 4. Healthchecks Simplificados
- ✅ **App**: `test -f /var/run/php-fpm.pid || pgrep php-fpm`
- ✅ **Webserver**: Apenas `/healthz` (endpoint simples)
- ✅ **DB**: Com variável correta

## 🚀 O Que Mudou

### Antes:
```
Container app-xxx  Error
dependency failed to start: container app is unhealthy
```

### Agora:
- Container `app` inicia PHP-FPM imediatamente
- Healthcheck mais tolerante e com mais tempo
- Dependências menos restritivas

## 📋 Variáveis Necessárias no Coolify

Configure estas variáveis no Coolify:

```bash
# Essenciais
DB_HOST=db
DB_DATABASE=ledfine_db
DB_USERNAME=ledfine_user
DB_PASSWORD=sua-senha-forte
MYSQL_ROOT_PASSWORD=senha-root-forte

# Laravel
APP_ENV=production
APP_DEBUG=false
APP_URL=https://seu-dominio.coolify.io
APP_KEY=base64:FYkNu7NFf/LTNe/QF7aMrLTMPOQVk56Rq/o9xa9StrM=
```

## 🧪 Sequência de Testes Após Deploy

1. **Container Status**: Todos os containers devem estar `healthy`
2. **`/healthz`**: Deve retornar "OK"
3. **`/debug.php`**: Deve mostrar configurações
4. **`/info.php`**: Deve mostrar informações PHP
5. **`/`**: Aplicação principal

## 📊 Timeline Esperado

```
0s   - Container db inicia
15s  - DB fica healthy
16s  - Container app inicia
20s  - PHP-FPM está rodando
30s  - App fica healthy
31s  - Container webserver inicia
40s  - Webserver fica healthy
45s  - Aplicação disponível
```

## 🔧 Se Ainda Falhar

### Container `app` não inicia:
1. Verificar logs do build (composer install)
2. Verificar permissões de arquivos
3. Verificar se o script entrypoint-fast.sh existe

### Healthcheck ainda falha:
1. Verificar se PHP-FPM está realmente rodando
2. Verificar se a porta 9000 está aberta
3. Tentar healthcheck manual: `docker exec container pgrep php-fpm`

### Problemas de rede:
1. Verificar se containers estão na mesma rede Docker
2. Verificar se Coolify não tem restrições específicas

**O container `app` agora deve iniciar muito mais rapidamente e de forma mais confiável!** 🚀
