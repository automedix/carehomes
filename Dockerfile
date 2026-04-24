FROM python:3.13-slim

# System-Abhaengigkeiten fuer SQLCipher
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlcipher-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ALLE Dateien (inkl. requirements.txt) kopieren
COPY . .

# Python-Abhaengigkeiten installieren
RUN pip install --no-cache-dir -r requirements.txt

# Persistente Daten (Datenbank, Backups)
VOLUME ["/app/data", "/app/backups"]

# Port exposen (wird ueber .env gesteuert)
EXPOSE 5002

# WSGI-Entrypoint fuer Produktion
CMD ["python", "wsgi.py"]
