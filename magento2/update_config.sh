#!/bin/bash
# ===========================================================
# Script: update_magento_config.sh
# Descrizione: aggiorna configurazioni Magento in MySQL
#              e modifica app/etc/env.php con nuovi parametri DB
# ===========================================================

# Parametri MySQL
DB_HOST="db"
DB_USER="magento"
DB_PASS="magento"
DB_NAME="magento"

# Percorso file di configurazione
ENV_FILE="app/etc/env.php"

# ===========================================================
# 1. Aggiornamento configurazioni in core_config_data
# ===========================================================
echo "Aggiornamento configurazioni in core_config_data..."

# Array di query
QUERIES=(
  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'web/unsecure/base_url', 'http://localhost:8085/', NOW())
   ON DUPLICATE KEY UPDATE value='http://localhost:8085/', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'web/secure/base_url', 'http://localhost:8085/', NOW())
   ON DUPLICATE KEY UPDATE value='http://localhost:8085/', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/engine', 'opensearch', NOW())
   ON DUPLICATE KEY UPDATE value='opensearch', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/opensearch_server_hostname', 'opensearch', NOW())
   ON DUPLICATE KEY UPDATE value='opensearch', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/opensearch_server_port', '9200', NOW())
   ON DUPLICATE KEY UPDATE value='9200', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/opensearch_index_prefix', 'magento2', NOW())
   ON DUPLICATE KEY UPDATE value='magento2', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/opensearch_enable_auth', '0', NOW())
   ON DUPLICATE KEY UPDATE value='0', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/opensearch_server_timeout', '15', NOW())
   ON DUPLICATE KEY UPDATE value='15', updated_at=NOW();"

  "INSERT INTO core_config_data (scope, scope_id, path, value, updated_at)
   VALUES ('default', 0, 'catalog/search/opensearch_minimum_should_match', NULL, NOW())
   ON DUPLICATE KEY UPDATE value=NULL, updated_at=NOW();"
)

for QUERY in "${QUERIES[@]}"; do
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "$QUERY"
done

echo "Configurazioni aggiornate con successo."

# ===========================================================
# 2. Modifica file app/etc/env.php
# ===========================================================
echo "Aggiornamento file env.php..."

if [ ! -f "$ENV_FILE" ]; then
  echo "Errore: il file $ENV_FILE non esiste."
  exit 1
fi

# Sostituzione parametri DB
sed -i "s/'host' => '.*'/'host' => '${DB_HOST}'/g" "$ENV_FILE"
sed -i "s/'dbname' => '.*'/'dbname' => '${DB_NAME}'/g" "$ENV_FILE"
sed -i "s/'username' => '.*'/'username' => '${DB_USER}'/g" "$ENV_FILE"
sed -i "s/'password' => '.*'/'password' => '${DB_PASS}'/g" "$ENV_FILE"

echo "env.php aggiornato con i nuovi parametri database."

# ===========================================================
# Fine script
# ===========================================================
echo "Tutte le operazioni completate con successo."
