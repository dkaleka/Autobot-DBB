# T01_handshake_server.py (Versão Simplificada)
from flask import Flask, jsonify
from datetime import datetime
from pathlib import Path

app = Flask(__name__)

# O BASE_DIR agora é dinâmico, baseado na localização do script para portabilidade
BASE_DIR = Path(__file__).resolve().parent

def iso_now():
    """Retorna o timestamp atual em formato ISO 8601 UTC."""
    return datetime.utcnow().isoformat(timespec="seconds") + "Z"

@app.route("/health", methods=["POST"])
def health():
    """
    Endpoint de health check. Retorna um status 'ok' para indicar que o serviço está ativo.
    Acessível apenas via método POST para evitar detecção por scanners simples.
    """
    return jsonify({
        "ok": True,
        "service": "T01_handshake_server",
        "timestamp": iso_now()
    })

if __name__ == "__main__":
    # Escuta em 127.0.0.1 para garantir que o serviço seja apenas local.
    # A porta 5055 é usada para evitar conflitos com serviços comuns.
    # O modo debug é desativado para uso em "produção".
    app.run(host="127.0.0.1", port=5055, debug=False)
