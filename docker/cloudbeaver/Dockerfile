FROM dbeaver/cloudbeaver:latest

USER root

# Copiar plantilla de data-sources y script de entrada
COPY data-sources.json /opt/cloudbeaver-template/data-sources.json
COPY entrypoint.sh /opt/cloudbeaver-entrypoint.sh

RUN chmod +x /opt/cloudbeaver-entrypoint.sh

ENTRYPOINT ["/opt/cloudbeaver-entrypoint.sh"]
