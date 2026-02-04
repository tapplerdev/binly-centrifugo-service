# Binly Centrifugo Service

Real-time WebSocket/pub-sub server for driver location streaming and shift updates.

## What is This?

Centrifugo is a scalable real-time messaging server that replaces custom WebSocket implementations. It handles:

- **Driver location streaming** to manager dashboards
- **Shift updates** (assignments, completions, cancellations)
- **Manager notifications** (new requests, alerts)
- **Automatic reconnection** and message recovery
- **Multi-device support** (same user on mobile + web)

## Architecture

```
Driver App → Backend → OSRM Snap → Centrifugo → Manager Dashboard/Mobile
              (validate)  (clean)     (broadcast)
```

**Channels:**
- `driver:location:{driverId}` - Real-time GPS updates (cache recovery, 1 message history)
- `shift:updates:{shiftId}` - Shift events (5 message history, 120s TTL)
- `manager:notifications:{managerId}` - Manager alerts (10 message history, 300s TTL)

## Deployment to Railway

### Prerequisites
- GitHub account
- Railway account (free tier is fine)
- Your backend deployed to Railway

### Steps

1. **Push this repo to GitHub:**
   ```bash
   gh repo create binly-centrifugo-service --public --source=. --push
   ```

2. **Create Railway project:**
   - Go to https://railway.com/new
   - Select "Deploy from GitHub repo"
   - Choose `binly-centrifugo-service`
   - Railway auto-detects Dockerfile

3. **Set environment variables:**
   ```bash
   CENTRIFUGO_TOKEN_HMAC_SECRET_KEY=<generate-random-64-char-string>
   CENTRIFUGO_API_KEY=<generate-random-64-char-string>
   CENTRIFUGO_ADMIN_PASSWORD=<strong-password>
   CENTRIFUGO_ADMIN_SECRET=<generate-random-32-char-string>
   PORT=8000
   ```

   Generate secrets:
   ```bash
   openssl rand -hex 32  # For TOKEN_HMAC_SECRET_KEY
   openssl rand -hex 32  # For API_KEY
   openssl rand -hex 16  # For ADMIN_SECRET
   ```

4. **Deploy:**
   Railway will automatically build and deploy.

5. **Get public URL:**
   Railway generates: `https://binly-centrifugo-service-production.up.railway.app`

6. **Generate public domain:**
   Settings → Networking → Generate Domain

## Testing

### Health Check
```bash
curl https://binly-centrifugo-service-production.up.railway.app/health
# Returns: {"health": "ok"}
```

### Admin Web UI
```
https://binly-centrifugo-service-production.up.railway.app/
Username: admin
Password: <CENTRIFUGO_ADMIN_PASSWORD>
```

### Publish Test Message (from backend)
```bash
curl -X POST https://binly-centrifugo-service-production.up.railway.app/api/publish \
  -H "Content-Type: application/json" \
  -H "X-API-Key: <CENTRIFUGO_API_KEY>" \
  -d '{
    "channel": "driver:location:driver-123",
    "data": {
      "lat": 37.335480,
      "lng": -121.886329,
      "heading": 45,
      "speed": 15.2,
      "accuracy": 10
    }
  }'
```

## Configuration

See `config.json` for namespace settings:

- **driver namespace**: Location streaming (cache recovery, 60s TTL)
- **shift namespace**: Shift events (5 msg history, 120s TTL)
- **manager namespace**: Notifications (10 msg history, 300s TTL)

All namespaces use **subscribe proxy** for authorization - backend validates subscriptions.

## Cost Estimate

**Railway Usage:**
- CPU: ~$2-3/month (very low usage)
- Memory: ~$2-3/month (100-200MB)
- Network: ~$1/month
- **Total: ~$5-7/month**

Much cheaper than managed alternatives:
- Pusher: $49/month
- Ably: $29/month
- PubNub: $49/month

## Documentation

- Centrifugo Docs: https://centrifugal.dev/docs/getting-started/introduction
- GitHub: https://github.com/centrifugal/centrifugo

## License

Centrifugo is MIT licensed (free, open source).
