# VisiCore Server-Deployment

Diese Dateien ermöglichen das Deployment von VisiCore auf einem Linux-Server (z.B. IONOS).

## Quick Start

### 1. Umgebungsvariablen setzen

```bash
export SECRET_KEY=$(openssl rand -hex 32)
export DB_KEY=$(openssl rand -hex 32)
export PRAXIS_STADT="Wuerzburg"
```

### 2. Docker-Stack starten

```bash
docker compose up -d --build
```

### 3. Erstzugriff

- URL: `http://SERVER-IP`
- Login: `admin` / `admin`
- **Passwort sofort ändern!**

## Manuell (ohne Docker)

### 1. Virtuelles Environment erstellen

```bash
python3 -m venv /opt/visicore/venv
/opt/visicore/venv/bin/pip install -r requirements.txt
```

### 2. Umgebungsvariablen in `.env`

```
SECRET_KEY=<32-byte-hex>
DB_KEY=<32-byte-hex>
PORT=5001
HTTPS=false
PRAXIS_STADT=Wuerzburg
```

### 3. Starten

```bash
/opt/visicore/venv/bin/python wsgi.py
```

### 4. HTTPS mit Caddy (optional)

```bash
caddy run --config Caddyfile
```

## Dateien in diesem Deployment

| Datei | Zweck |
|-------|-------|
| `wsgi.py` | WSGI-Entrypoint mit Waitress |
| `Dockerfile` | Container-Image für VisiCore |
| `docker-compose.yml` | Orchestriert App + Caddy |
| `Caddyfile` | Reverse-Proxy-Konfiguration |
| `.env` | Lokale Konfiguration (nicht ins Git!) |

## Hinweise

- **sqlcipher3** erfordert `libsqlcipher-dev` auf dem Host (Debian/Ubuntu).
- Datenbank und Backups sind in Docker-Volumes persistent.
- `HTTPS=false` in der App – Caddy übernimmt TLS/HTTPS.

## Reverse-Proxy mit Caddy (empfohlen)

Caddy bietet automatisches HTTPS mit Let's Encrypt. Für eine eigene Domain:

```
deine-domain.de {
    reverse_proxy localhost:5001
}
```

## Troubleshooting

### Port bereits belegt

```bash
# Prüfen
python3 -c "import socket; s=socket.socket(); s.bind(('0.0.0.0', 5001)); print('Port frei')"
# Alternativen Port in .env setzen: PORT=5002
```

### sqlcipher3 Fehlermeldung

```bash
# Debian/Ubuntu
sudo apt-get install libsqlcipher-dev libssl-dev pkg-config
```
