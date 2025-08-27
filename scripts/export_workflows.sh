const axios = require('axios');
const fs = require('fs');
const { execSync } = require('child_process');

// Configuración
const N8N_URL = process.env.N8N_URL || 'http://localhost:5678';
const API_KEY = process.env.N8N_API_KEY;
const GITHUB_REPO = 'tu-usuario/n8n-workflows';
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const WORKFLOWS_DIR = './workflows';

// Función para exportar flujos
async function exportWorkflows() {
  try {
    // Obtener lista de flujos
    const response = await axios.get(`${N8N_URL}/rest/workflows`, {
      headers: {
        'Authorization': `Bearer ${API_KEY}`,
        'Content-Type': 'application/json'
      }
    });

    const workflows = response.data.data;

    // Crear directorio de flujos si no existe
    if (!fs.existsSync(WORKFLOWS_DIR)) {
      fs.mkdirSync(WORKFLOWS_DIR);
    }

    // Exportar cada flujo
    for (const workflow of workflows) {
      const workflowResponse = await axios.get(`${N8N_URL}/rest/workflows/${workflow.id}`, {
        headers: {
          'Authorization': `Bearer ${API_KEY}`,
          'Content-Type': 'application/json'
        }
      });

      const workflowData = workflowResponse.data;
      const workflowName = workflow.name.replace(/\s+/g, '_');
      const filePath = `${WORKFLOWS_DIR}/${workflowName}.json`;

      fs.writeFileSync(filePath, JSON.stringify(workflowData, null, 2));
      console.log(`Flujo ${workflowName} exportado.`);
    }

    // Configurar Git
    execSync('git config --global user.email "github-actions@github.com"');
    execSync('git config --global user.name "GitHub Actions"');

    // Hacer commit y push a GitHub
    execSync('git add .');
    execSync(`git commit -m "Exportación automática de flujos - ${new Date().toISOString()}"`);
    execSync(`git push https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git`);

    console.log('Flujos exportados y repositorio actualizado.');
  } catch (error) {
    console.error('Error al exportar flujos:', error.message);
    process.exit(1);
  }
}

// Ejecutar la función
exportWorkflows();
