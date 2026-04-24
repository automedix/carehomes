#!/bin/bash
set -e

CAREHOMES_DIR="/opt/carehomes"
VISICORE_SRC="$CAREHOMES_DIR/visicore-src"
NGINX_AVAILABLE="/etc/nginx/sites-available/carehomes"
NGINX_ENABLED="/etc/nginx/sites-enabled/carehomes"
DOMAIN="carehomes.hausaerzte-im-grillepark.online"

echo "================================================"
echo "  CareHomes (VisiCore) Server-Setup"
echo "================================================"

if ! command -v docker &> /dev/null; then echo "FEHLER: Docker fehlt"; exit 1; fi
if ! docker compose version &> /dev/null && ! docker-compose --version &> /dev/null; then echo "FEHLER: Docker Compose fehlt"; exit 1; fi
echo "[OK] Docker gefunden"

mkdir -p "$CAREHOMES_DIR"

# VisiCore-Quellcode holen
if [ ! -d "$VISICORE_SRC/.git" ]; then
    echo "[1/7] VisiCore-Code wird geklont..."
    git clone https://github.com/lollylan/VisiCore.git "$VISICORE_SRC"
else
    echo "[1/7] VisiCore-Code ist bereits vorhanden, aktualisiere..."
    cd "$VISICORE_SRC" && git pull origin main
fi

# Deploy-Dateien kopieren
CAREHOMES_REPO="$CAREHOMES_DIR/carehomes"
if [ -d "$CAREHOMES_REPO" ]; then
    cp "$CAREHOMES_REPO/Dockerfile" "$VISICORE_SRC/"
    cp "$CAREHOMES_REPO/docker-compose.yml" "$VISICORE_SRC/"
    cp "$CAREHOMES_REPO/wsgi.py" "$VISICORE_SRC/"
fi

# Environment-Variablen erstellen
echo "[3/7] Umgebungsvariablen werden erstellt..."
if [ ! -f "$VISICORE_SRC/.env" ]; then
    DB_KEY=$(openssl rand -hex 32)
    SECRET_KEY=$(openssl rand -hex 32)
    echo "DB_KEY=$DB_KEY" > "$VISICORE_SRC/.env"
    echo "SECRET_KEY=$SECRET_KEY" >> "$VISICORE_SRC/.env"
    echo "PORT=5002" >> "$VISICORE_SRC/.env"
    echo "HTTPS=false" >> "$VISICORE_SRC/.env"
    echo "PRAXIS_STADT=Wuerzburg" >> "$VISICORE_SRC/.env"
    echo "  .env erstellt"
else
    echo "  .env existiert bereits"
fi

# Docker-Image bauen
echo "[4/7] Docker-Image wird gebaut (das dauert ca. 3-5 Minuten)..."
cd "$VISICORE_SRC"
docker compose build --no-cache

# Container starten
echo "[5/7] Container wird gestartet..."
docker compose up -d

# Nginx-Config erstellen
echo "[6/7] Nginx-Reverse-Proxy wird konfiguriert..."
if [ -d "/etc/nginx/sites-available" ]; then
    echo "server {" > "$NGINX_AVAILABLE"
    echo "    listen 80;" >> "$NGINX_AVAILABLE"
    echo "    server_name $DOMAIN;" >> "$NGINX_AVAILABLE"
    echo "" >> "$NGINX_AVAILABLE"
    echo "    location / {" >> "$NGINX_AVAILABLE"
    echo "        proxy_pass http://localhost:5002;" >> "$NGINX_AVAILABLE"
    echo "        proxy_http_version 1.1;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header Upgrade \$http_upgrade;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header Connection 'upgrade';" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header Host \$host;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header X-Real-IP \$remote_addr;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header X-Forwarded-Proto \$scheme;" >> "$NGINX_AVAILABLE"
    echo "        proxy_cache_bypass \$http_upgrade;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header X-Forwarded-Host \$host;" >> "$NGINX_AVAILABLE"
    echo "        proxy_set_header X-Forwarded-Prefix /;" >> "$NGINX_AVAILABLE"
    echo "    }" >> "$NGINX_AVAILABLE"
    echo "}" >> "$NGINX_AVAILABLE"

    if [ ! -L "$NGINX_ENABLED" ]; then
        sudo ln -s "$NGINX_AVAILABLE" "$NGINX_ENABLED"
    fi

    sudo nginx -t && sudo systemctl reload nginx
    echo "  [OK] Nginx konfiguriert"
else
    echo "  WARNUNG: /etc/nginx/sites-available nicht gefunden"
fi

# SSL-Zertifikat (Certbot)
echo "[7/7] SSL-Zertifikat pruefen/erstellen..."
if command -v certbot &> /dev/null; then
    if sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@$DOMAIN" 2>/dev/null; then
        echo "  [OK] SSL-Zertifikat erstellt"
    else
        echo "  Hinweis: SSL-Zertifikat konnte nicht automatisch erstellt werden."
        echo "  Fuehre spaeter aus: sudo certbot --nginx -d $DOMAIN"
    fi
else
    echo "  Hinweis: certbot nicht gefunden."
fi

echo ""
echo "================================================"
echo "  Setup abgeschlossen!"
echo "================================================"
echo ""
echo "  URL:     https://$DOMAIN"
echo "  Intern:  http://localhost:5002"
echo ""
echo "  Erst-Login:"
echo "    Benutzer: admin"
echo "    Passwort: admin"
echo "    --> Passwort sofort aendern!"
echo ""
echo "================================================"
