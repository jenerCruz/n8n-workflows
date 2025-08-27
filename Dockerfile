FROM node:18-alpine

ARG N8N_VERSION=1.39.1

# Instala dependencias
RUN apk add --update graphicsmagick tzdata curl jq git

# Crea un usuario no-root
RUN adduser -D myuser && \
    mkdir -p /app && \
    chown -R myuser /app

# Instala n8n
USER root
RUN apk --update add --virtual build-dependencies python3 build-base && \
    npm_config_user=root npm install --location=global n8n@${N8N_VERSION} && \
    apk del build-dependencies

# Copia los scripts de importación y exportación
COPY scripts/import_workflows.sh /import_workflows.sh
COPY scripts/export_workflows.sh /export_workflows.sh
RUN chmod +x /import_workflows.sh /export_workflows.sh

# Cambia al usuario no-root
USER myuser
WORKDIR /app

# Comando de entrada personalizado
ENTRYPOINT ["sh", "-c", "trap '/export_workflows.sh; exit 0' TERM; /import_workflows.sh & n8n"]
