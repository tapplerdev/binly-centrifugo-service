# Railway Centrifugo Deployment - Dockerfile
# Deploys Centrifugo real-time messaging server for driver location streaming

FROM centrifugo/centrifugo:v6

# Copy configuration file
COPY config.json /centrifugo/config.json

# Railway injects PORT environment variable at runtime
ARG PORT=8000
ENV PORT=$PORT

# EXPOSE is just documentation, Railway will map whatever port the app listens on
EXPOSE $PORT

# Start Centrifugo with config file
# Railway requires listening on 0.0.0.0 (not localhost)
# In v6, use --http_server.port instead of --port
CMD centrifugo --config=/centrifugo/config.json --http_server.port=${PORT:-8000}

# Image size: ~50MB (much smaller than OSRM!)
# RAM usage: ~100-200MB at runtime
# CPU: Low (< 5% for typical usage)
