FROM alpine

ARG N8N_VERSION=1.39.1

# Instalar dependencias, tini y limpiar caché en un solo paso
RUN apk add --no-cache graphicsmagick tzdata curl jq git tini

# ... (el resto de la creación de usuario no cambia) ...
RUN adduser -D myuser && \
    mkdir -p /app && \
    chown -R myuser /app

# Instalar n8n y limpiar todas las cachés
USER root
RUN apk add --no-cache --virtual build-deps python3 build-base && \
    npm_config_user=root npm install --location=global n8n@${N8N_VERSION} && \
    apk del build-deps && \
    npm cache clean --force && \
    rm -rf /tmp/*

# Copia los scripts y el nuevo entrypoint
COPY scripts/import_workflows.sh /import_workflows.sh
COPY scripts/export_workflows.sh /export_workflows.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /import_workflows.sh /export_workflows.sh /entrypoint.sh

# Cambia al usuario no-root
USER myuser
WORKDIR /app

# Usa tini para gestionar el proceso y ejecuta tu script
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]