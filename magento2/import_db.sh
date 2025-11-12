#!/bin/bash
# ===========================================================
# Script: import_db.sh
# Descrizione: importa un database MySQL da file nel container
# ===========================================================

echo "================================================"
echo "  Import Database MySQL"
echo "================================================"
echo ""

# Richiesta parametri
read -p "Inserisci l'ID o il nome del container MySQL: " MYSQL_CONTAINER

if [ -z "$MYSQL_CONTAINER" ]; then
  echo "Errore: ID container MySQL non fornito."
  exit 1
fi

# Verifica che il container MySQL esista ed è in esecuzione
if ! docker ps --format '{{.ID}} {{.Names}}' | grep -q "$MYSQL_CONTAINER"; then
  echo "Errore: container MySQL '$MYSQL_CONTAINER' non trovato o non in esecuzione."
  echo ""
  echo "Container disponibili:"
  docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'
  exit 1
fi

echo "Container MySQL trovato: $MYSQL_CONTAINER"
echo ""

read -p "Inserisci il percorso del file SQL da importare: " SQL_FILE

if [ -z "$SQL_FILE" ]; then
  echo "Errore: percorso file SQL non fornito."
  exit 1
fi

if [ ! -f "$SQL_FILE" ]; then
  echo "Errore: il file '$SQL_FILE' non esiste."
  exit 1
fi

echo "File SQL trovato: $SQL_FILE"
echo ""

# Parametri database (statici)
DB_NAME="magento"
DB_USER="magento"
DB_PASS="magento"

echo "================================================"
echo "Riepilogo operazione:"
echo "  Container: $MYSQL_CONTAINER"
echo "  File SQL: $SQL_FILE"
echo "  Database: $DB_NAME"
echo "================================================"
echo ""

read -p "Procedere con l'importazione? (s/n): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
  echo "Operazione annullata."
  exit 0
fi

echo ""
echo "Inizio importazione..."
echo ""

# Nome temporaneo del file nel container
TEMP_FILE="/tmp/import_$(date +%s).sql"

# Step 1: Copia il file nel container
echo "1. Copia file nel container..."
docker cp "$SQL_FILE" "$MYSQL_CONTAINER:$TEMP_FILE"

if [ $? -ne 0 ]; then
  echo "Errore: impossibile copiare il file nel container."
  exit 1
fi

echo "   File copiato con successo."
echo ""

# Step 2: Importa il database
echo "2. Importazione database..."
docker exec -i "$MYSQL_CONTAINER" mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"

# Alternativa: eseguire il comando mysql dal file copiato nel container
# docker exec -i "$MYSQL_CONTAINER" sh -c "mysql -u $DB_USER -p$DB_PASS $DB_NAME < $TEMP_FILE"

if [ $? -ne 0 ]; then
  echo "Errore: impossibile importare il database."
  # Pulizia file temporaneo
  docker exec "$MYSQL_CONTAINER" rm -f "$TEMP_FILE"
  exit 1
fi

echo "   Database importato con successo."
echo ""

# Step 3: Pulizia file temporaneo
echo "3. Pulizia file temporaneo..."
docker exec "$MYSQL_CONTAINER" rm -f "$TEMP_FILE"

if [ $? -eq 0 ]; then
  echo "   File temporaneo rimosso."
fi

echo ""
echo "================================================"
echo "Importazione completata con successo!"
echo "================================================"
