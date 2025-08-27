#!/bin/sh
set -e # Salir inmediatamente si un comando falla
# Función para el apagado seguro
shutdown() {
  echo "🛑 Apagando contenedor, exportando workflows..."
  /export_workflows.sh
  echo "✅ Exportación completa."
  exit 0
}

# Atrapar la señal TERM y llamar a la función shutdown
trap shutdown TERM

# Iniciar la importación en primer plano
echo "🚀 Importando workflows..."
/import_workflows.sh
echo "✅ Importación completa."

# Iniciar n8n como el proceso principal
# El 'exec' reemplaza el shell con n8n, permitiendo que tini lo gestione directamente
echo "🚀 Iniciando n8n..."
exec n8n "$@"