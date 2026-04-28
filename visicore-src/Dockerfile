FROM python:3.13-slim

# System-Abhängigkeiten für SQLCipher
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libsqlcipher-dev \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python-Abhängigkeiten
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Anwendungscode
COPY . .

# Persistente Daten (Datenbank, Backups)
VOLUME ["/app/data", "/app/backups"]

# WSGI-Entrypoint für Produktion
CMD ["python", "wsgi.py"]
