
#!/bin/bash
set -e

# ==============================
# Vaultwarden Setup Script
# ==============================

# Versionsauswahl: entweder Argument oder "latest"
VAULTWARDEN_VERSION="${1:-latest}"

# Zielverzeichnis im aktuellen Pfad
BASE_DIR="$(pwd)/vaultwarden"

# Ordnerstruktur anlegen
mkdir -p "$BASE_DIR/data"

# .env-Datei erzeugen, falls nicht vorhanden
if [ ! -f "$BASE_DIR/.env" ]; then
    cat <<EOF > "$BASE_DIR/.env"
# Vaultwarden Environment File

# Admin Token (zufällig generiert)
ADMIN_TOKEN=$(openssl rand -hex 32)

# Websocket aktivieren
WEBSOCKET_ENABLED=true

# Domain/IP wird später im Script ausgegeben
EOF
fi

# docker-compose.yml erstellen
cat <<EOF > "$BASE_DIR/docker-compose.yml"
services:
  vaultwarden:
    image: vaultwarden/server:$VAULTWARDEN_VERSION
    container_name: vaultwarden
    restart: unless-stopped
    env_file: .env
    volumes:
      - ./data:/data
    ports:
      - "8088:80"   # Web-UI
      - "3012:3012" # WebSocket
EOF

# Container starten
cd "$BASE_DIR"
docker compose pull
docker compose up -d

# Lokale IP ermitteln
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo ""
echo "✅ Vaultwarden Setup abgeschlossen!"
echo "Rufe die Weboberfläche auf unter: http://$LOCAL_IP:8080"
echo "Admin-Interface aktivieren mit Token aus .env:"
echo ""
grep ADMIN_TOKEN .env
