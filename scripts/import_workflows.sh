#!/bin/sh

git clone https://github.com/tu-usuario/n8n-workflows.git /app/workflows

echo "Esperando a que n8n esté listo..."
while ! curl -s http://localhost:5678/ > /dev/null; do
  sleep 1
done

N8N_URL="http://localhost:5678"
GIT_REPO="/app/workflows"

API_KEY="$N8N_API_KEY"

for workflow_file in "$GIT_REPO"/*.json; do
  workflow_name=$(basename "$workflow_file" .json)
  workflow_data=$(cat "$workflow_file")

  echo "Importando flujo: $workflow_name"
  response=$(curl -s -X POST "$N8N_URL/rest/workflows" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "$workflow_data")

  if [ -n "$response" ]; then
    echo "Flujo '$workflow_name' importado correctamente."
  else
    echo "Error al importar el flujo '$workflow_name'."
  fi
done
