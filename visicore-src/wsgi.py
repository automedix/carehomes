"""
CaraVax WSGI Entry Point
Startet die App mit Waitress fuer Produktivbetrieb.
"""

import os
import sys

# Sicherstellen, dass das App-Verzeichnis im Pfad ist
base_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(base_dir)

from app import create_app

application = create_app()

if __name__ == '__main__':
    from waitress import serve
    port = int(os.environ.get('PORT', 5001))
    print(f"Starting CaraVax on 0.0.0.0:{port} ...")
    serve(application, host='0.0.0.0', port=port, threads=8)
