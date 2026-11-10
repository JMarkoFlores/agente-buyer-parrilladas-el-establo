"""
Punto de entrada principal para ejecutar el servidor Flask localmente.
"""
import sys
import os
from pathlib import Path

# Asegurar que el directorio backend está en el sys.path
current_dir = Path(__file__).resolve().parent
if str(current_dir) not in sys.path:
    sys.path.insert(0, str(current_dir))

from app import create_app

app = create_app()

if __name__ == "__main__":
    port = int(os.getenv("FLASK_PORT", 5000))
    debug = os.getenv("FLASK_ENV", "development").lower() == "development"
    print("=" * 60)
    print("  AGENTE INTELIGENTE BUYER — PARRILLADAS EL ESTABLO")
    print(f"  Servidor Flask iniciado en: http://localhost:{port}")
    print(f"  Diagnóstico de BD:          http://localhost:{port}/api/db/status")
    print(f"  Health check:               http://localhost:{port}/api/health")
    print(f"  Resumen analítico:          http://localhost:{port}/api/estadisticas/resumen")
    print("=" * 60)
    app.run(host="127.0.0.1", port=port, debug=debug)
