# CareHomes (VisiCore) Deployment

> Webbasierte Plattform zur Verwaltung von Hausbesuchen und Impfungen in Arztpraxen.
> Ursprünglich VisiCore von [lollylan](https://github.com/lollylan/VisiCore).

## Quick-Deploy auf bestehendem Server (IONOS)

Voraussetzung: Docker + Docker Compose + Nginx sind bereits installiert (z.B. fuer MedOrder).

### 1. Auf dem Server einloggen

```bash
ssh root@87.106.23.237
```

### 2. Das carehomes-Repo klonen

```bash
cd /opt
git clone https://github.com/automedix/carehomes.git
```

### 3. Setup-Skript ausfuehren

```bash
sudo bash /opt/carehomes/setup.sh
```

Das Skript erledigt automatisch:
- VisiCore-Quellcode klonen
- Docker-Image bauen
- Container starten (Port 5002)
- Nginx-Reverse-Proxy konfigurieren
- SSL-Zertifikat erstellen (falls certbot vorhanden)

### 4. Erstzugriff

- **URL:** https://carehomes.hausaerzte-im-grillepark.online
- **Login:** `admin` / `admin`
- **Aktion:** Passwort sofort aendern!

---

## Manuelle Schritte (ohne setup.sh)

Falls das automatische Setup nicht funktioniert:

```bash
# 1. Verzeichnis
mkdir -p /opt/carehomes && cd /opt/carehomes

# 2. Quellcodes holen
git clone https://github.com/lollylan/VisiCore.git visicore-src
git clone https://github.com/automedix/carehomes.git
cp carehomes/* visicore-src/

# 3. Environment
cd visicore-src
cp carehomes/.env.example .env
# .env anpassen: SECRET_KEY, DB_KEY generieren (openssl rand -hex 32)

# 4. Docker
docker compose up -d --build

# 5. Nginx manuell
cat > /etc/nginx/sites-available/carehomes \ls
server {
    listen 80;
    server_name carehomes.hausaerzte-im-grillepark.online;
    location / {
        proxy_pass http://localhost:5002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF
ln -s /etc/nginx/sites-available/carehomes /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 6. SSL
certbot --nginx -d carehomes.hausaerzte-im-grillepark.online
```

---

## Architektur

```
[Internet]
    |
[Nginx :80/:443]
    |-- carehomes.hausaerzte... (proxy_pass :5002)
    |-- medorder.hausaerzte... (proxy_pass :3000)
    |
[Docker Host]
    |-- carehomes-app (VisiCore :5002)
    |-- medorder-app (MedOrder :3000)
```

---

## Dateien

| Datei | Zweck |
|-------|-------|
| `Dockerfile` | Python 3.13 + sqlcipher3 Build |
| `docker-compose.yml` | Container-Definition (Port 5002) |
| `wsgi.py` | Waitress WSGI-Server |
| `setup.sh` | Automatisches Server-Setup |
| `Caddyfile` | Alternative: Caddy statt Nginx |
| `DEPLOYMENT.md` | Details & Troubleshooting |
| `.env.example` | Umgebungsvariablen-Vorlage |

---

## Wartung

```bash
# Logs ansehen
cd /opt/carehomes/visicore-src && docker compose logs -f

# Updates einspielen
cd /opt/carehomes/visicore-src
git pull origin main
docker compose down
docker compose up -d --build

# Backup
docker compose cp visicore:/app/data/visicore.db ./backups/
```

## Lizenz

Deployment-Configs: MIT.
VisiCore-Core: Lizenz des Original-Repos (lollylan/VisiCore).
