# CareHomes Deployment

Deployment-Infrastruktur für **VisiCore** auf einem Linux-Server (IONOS).

## Struktur

```
carehomes/
├── Dockerfile              # Container-Build für VisiCore
├── docker-compose.yml    # App + Caddy Reverse Proxy
├── Caddyfile             # HTTP/S-Konfiguration
├── wsgi.py               # WSGI-Entrypoint (Waitress)
├── DEPLOYMENT.md         # Detaillierte Anleitung
└── .env                  # Lokale Konfig (nicht ins Git!)
```

## VisiCore einbinden

Das Deployment geht davon aus, dass der VisiCore-Quellcode parallel oder als Git-Submodule verfügbar ist:

```bash
# Variante 1: Git-Submodule
git submodule add https://github.com/lollylan/VisiCore.git visicore-src

# Variante 2: Manuell kopieren
git clone https://github.com/lollylan/VisiCore.git /tmp/visicore-src
cp -r /tmp/visicore-src/* ./visicore-src/
```

## Quick Start

### 1. Environment-Variablen

```bash
cp .env.example .env
# .env anpassen
```

### 2. Docker-Stack starten

```bash
docker compose up -d --build
```

### 3. Erstzugriff

- URL: `http://SERVER-IP`
- Login: `admin` / `admin`
- **Passwort sofort ändern!**

## Weitere Details

Siehe [DEPLOYMENT.md](DEPLOYMENT.md) für:
- Manuelle Installation ohne Docker
- HTTPS mit eigenem Domain
- Troubleshooting
- sqlcipher3-Abhängigkeiten

## Lizenz

Die Deployment-Configs stehen unter MIT.
VisiCore selbst unterliegt der Lizenz des Original-Repos (lollylan/VisiCore).
