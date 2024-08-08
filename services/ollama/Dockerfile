FROM ollama/ollama:latest
ARG PROJECT_TAG
LABEL project=$PROJECT_TAG

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

