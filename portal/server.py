#!/usr/bin/env python3
# ==============================================================================
# ArcadiaOS: Boot Selector Server & Command Bridge
# Lightweight standard-library Python server for the TV/Console Dual Portal
# ==============================================================================

import os
import sys
import subprocess
import threading
import time
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = int(os.environ.get("ARCADIA_PORT", 8888))
PORTAL_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(PORTAL_DIR)

def launch_games():
    """Lança a sessão de Jogos (Steam Game Mode / Big Picture)."""
    time.sleep(0.5)
    print("[ArcadiaOS] Iniciando Modo Jogos...")
    
    # 1. Se estiver no Bazzite/Steam Deck Gamescope Session
    if os.path.exists("/usr/bin/gamescope-session"):
        subprocess.Popen(["/usr/bin/gamescope-session", "steam"])
    # 2. Ou execução direta do Steam com Gamepad UI
    elif os.path.exists("/usr/bin/steam"):
        subprocess.Popen(["/usr/bin/steam", "-gamepadui"])
    elif os.path.exists("/var/lib/flatpak/exports/bin/com.valvesoftware.Steam"):
        subprocess.Popen(["flatpak", "run", "com.valvesoftware.Steam", "-gamepadui"])
    else:
        print("[ArcadiaOS] Steam não encontrado no PATH padrão.")

def launch_tv():
    """Lança a sessão de Smart TV (Android TV / Waydroid Leanback)."""
    time.sleep(0.5)
    print("[ArcadiaOS] Iniciando Smart TV...")
    launcher_script = os.path.join(ROOT_DIR, "bin", "arcadia-launcher.sh")
    
    if os.path.exists(launcher_script):
        subprocess.Popen(["/usr/bin/env", "bash", launcher_script])
    else:
        # Fallback se executado fora da árvore
        subprocess.Popen(["/usr/bin/env", "bash", "-c", "waydroid session start && waydroid show-full-ui"])

class ArcadiaHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=PORTAL_DIR, **kwargs)

    def do_POST(self):
        if self.path == "/api/launch/games":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status": "ok", "mode": "games"}')
            threading.Thread(target=launch_games, daemon=True).start()
            return
            
        elif self.path == "/api/launch/tv":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status": "ok", "mode": "tv"}')
            threading.Thread(target=launch_tv, daemon=True).start()
            return

        self.send_response(404)
        self.end_headers()

    def log_message(self, format, *args):
        # Silencia logs excessivos no terminal
        pass

def run():
    server_address = ("127.0.0.1", PORT)
    httpd = HTTPServer(server_address, ArcadiaHandler)
    print(f"[ArcadiaOS] Boot Selector Portal rodando em http://127.0.0.1:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[ArcadiaOS] Encerrando servidor do portal.")
        httpd.server_close()

if __name__ == "__main__":
    run()
