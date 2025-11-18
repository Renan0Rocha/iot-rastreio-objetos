#!/usr/bin/env python3
"""
RFID Bridge - Serial to HTTP (Dois Leitores)
Lê dados RFID de DOIS leitores RC522 via Serial e envia para API REST via HTTP POST

Autor: Sistema IoT de Rastreamento de Objetos
Data: Novembro 2025
Versão: 2.0
"""

import serial
import requests
import json
from datetime import datetime
import time
import sys
import os

# ==================== CONFIGURAÇÕES ====================

# Tenta carregar configurações do arquivo config.json
CONFIG_FILE = 'config.json'

def load_config():
    """Carrega configurações do arquivo JSON ou usa valores padrão"""
    default_config = {
        "serial": {
            "port": "/dev/ttyACM0",
            "baud_rate": 115200,
            "timeout": 1
        },
        "api": {
            # You can use either a full `url` or split into `base_url` + `path`.
            # Example full url: "http://localhost:3000/api/rfid"
            # Or split: base_url: "http://localhost:3000", path: "/api/rfid"
            "url": "http://localhost:3000/api/rfid",
            "base_url": "",
            "path": "/api/rfid",
            # mode: 'full' -> send full payload; 'hex' -> send only uid_hex + reader
            "mode": "hex",
            "timeout": 5,
            "headers": {
                "Content-Type": "application/json",
                "User-Agent": "RFID-Bridge/2.0"
            }
        },
        "debug": {
            "enabled": True,
            "show_payload": True
        }
    }
    
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
                print(f"✅ Configurações carregadas de: {CONFIG_FILE}")
                return config
        except Exception as e:
            print(f"⚠️  Erro ao ler {CONFIG_FILE}: {e}")
            print(f"   Usando configurações padrão")
    else:
        print(f"ℹ️  Arquivo {CONFIG_FILE} não encontrado")
        print(f"   Usando configurações padrão")
        print(f"   Dica: Edite config.json para personalizar")
    
    return default_config

# Carrega configurações
config = load_config()

SERIAL_PORT = config['serial']['port']
BAUD_RATE = config['serial']['baud_rate']

# Resolve API URL: prefer base_url+route if provided, otherwise use url
api_conf = config.get('api', {})
base = api_conf.get('base_url', '')
route = api_conf.get('route', api_conf.get('path', ''))  # aceita 'route' ou 'path'

if base and base.strip():
    API_URL = base.rstrip('/') + ('/' + route.lstrip('/') if route else '')
else:
    API_URL = api_conf.get('url', 'http://localhost:3000/api/rfid')

REQUEST_TIMEOUT = api_conf.get('timeout', 5)
API_HEADERS = api_conf.get('headers', {})
SEND_MODE = api_conf.get('mode', 'full')  # 'hex' or 'full'

# Cor para terminal
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    END = '\033[0m'
    BOLD = '\033[1m'

# ==================== FUNÇÕES ====================

def print_colored(message, color=Colors.END):
    """Imprime mensagem colorida no terminal"""
    print(f"{color}{message}{Colors.END}")

def create_payload(rfid_data):
    """
    Cria o payload JSON para enviar à API.
    
    A lista de campos a enviar pode ser personalizada via
    config['api']['payload_fields'] (array de strings). Se não
    existir, usa um conjunto padrão completo.
    
    Args:
        rfid_data (dict): Dados do RFID lidos do Arduino
    
    Returns:
        dict: Payload formatado com timestamp
    """
    now = datetime.now()

    # Campos disponíveis e suas funções geradoras
    available = {
        "reader": lambda: rfid_data.get("reader", "unknown"),
        "uid_decimal": lambda: rfid_data.get("uid_decimal"),
        "uid_hex": lambda: rfid_data.get("uid_hex"),
        "card_type": lambda: rfid_data.get("card_type"),
        "date": lambda: now.strftime("%Y-%m-%d"),
        "time": lambda: now.strftime("%H:%M:%S"),
        "datetime": lambda: now.isoformat(),
        "timestamp_ms": lambda: int(time.time() * 1000),
        "arduino_timestamp": lambda: rfid_data.get("timestamp")
    }

    # Ordem padrão caso o usuário não forneça payload_fields
    default_fields = [
        "reader",
        "uid_decimal",
        "uid_hex",
        "card_type",
        "date",
        "time",
        "datetime",
        "timestamp_ms",
        "arduino_timestamp"
    ]

    fields = default_fields
    try:
        api_cfg = config.get('api', {})
        if isinstance(api_cfg.get('payload_fields'), list) and api_cfg.get('payload_fields'):
            fields = api_cfg.get('payload_fields')
    except Exception:
        fields = default_fields

    payload = {}
    for f in fields:
        if f in available:
            try:
                payload[f] = available[f]()
            except Exception:
                payload[f] = None
        else:
            # Se o campo pedido não existe entre os disponíveis,
            # tentamos extrair direto do rfid_data (flexibilidade)
            payload[f] = rfid_data.get(f)

    return payload

def send_to_api(payload):
    """
    Envia dados para a API via HTTP POST
    
    Args:
        payload (dict): Dados a serem enviados
    
    Returns:
        bool: True se enviado com sucesso, False caso contrário
    """
    try:
        print_colored(f"📤 Enviando para API: {API_URL}", Colors.CYAN)
        
        response = requests.post(
            API_URL,
            json=payload,
            headers=API_HEADERS,
            timeout=REQUEST_TIMEOUT
        )
        
        if response.status_code in [200, 201]:
            print_colored(f"✅ Enviado com sucesso! Status: {response.status_code}", Colors.GREEN)
            if config['debug']['enabled']:
                print_colored(f"   Resposta: {response.text[:100]}", Colors.GREEN)
            return True
        else:
            print_colored(f"⚠️  Resposta inesperada: {response.status_code}", Colors.YELLOW)
            print_colored(f"   {response.text[:200]}", Colors.YELLOW)
            return False
            
    except requests.exceptions.ConnectionError:
        print_colored("❌ Erro: Não foi possível conectar à API", Colors.RED)
        print_colored(f"   Verifique se a API está rodando em: {API_URL}", Colors.RED)
        return False
        
    except requests.exceptions.Timeout:
        print_colored(f"❌ Erro: Timeout ao conectar à API (>{REQUEST_TIMEOUT}s)", Colors.RED)
        return False
        
    except Exception as e:
        print_colored(f"❌ Erro ao enviar dados: {str(e)}", Colors.RED)
        return False

def process_serial_line(line):
    """
    Processa uma linha recebida da serial
    
    Args:
        line (str): Linha de texto da serial
    """
    # Verifica se é um JSON (começa com {)
    if line.startswith('{') and '"event":"rfid_read"' in line:
        try:
            # Parse do JSON
            rfid_data = json.loads(line)
            
            print_colored("\n" + "="*60, Colors.BOLD)
            print_colored("🎫 RFID DETECTADO", Colors.BOLD + Colors.BLUE)
            print_colored("="*60, Colors.BOLD)
            print_colored(f"Leitor:        {rfid_data.get('reader', 'N/A')}", Colors.CYAN)
            print_colored(f"UID (Decimal): {rfid_data.get('uid_decimal')}", Colors.CYAN)
            print_colored(f"UID (Hex):     {rfid_data.get('uid_hex')}", Colors.CYAN)
            print_colored(f"Tipo:          {rfid_data.get('card_type')}", Colors.CYAN)
            
            # Cria payload com data/hora
            payload = create_payload(rfid_data)
            
            if config['debug']['show_payload']:
                print_colored(f"\n📋 Payload JSON:", Colors.YELLOW)
                print(json.dumps(payload, indent=2))
            
            # Envia para API
            send_to_api(payload)
            
            print_colored("="*60 + "\n", Colors.BOLD)
            
        except json.JSONDecodeError as e:
            print_colored(f"⚠️  Erro ao decodificar JSON: {e}", Colors.RED)
            print_colored(f"   Linha recebida: {line}", Colors.RED)
    else:
        # Imprime outras mensagens normalmente (debug, info, etc)
        if line.strip():  # Ignora linhas vazias
            print(line)

def main():
    """Função principal"""
    print_colored("\n" + "="*60, Colors.BOLD)
    print_colored("🔌 RFID Bridge - Serial to HTTP (2 Leitores)", Colors.BOLD + Colors.GREEN)
    print_colored("="*60 + "\n", Colors.BOLD)
    
    print_colored(f"📡 Porta Serial: {SERIAL_PORT}", Colors.CYAN)
    print_colored(f"⚡ Baud Rate:    {BAUD_RATE}", Colors.CYAN)
    print_colored(f"🌐 API URL:      {API_URL}", Colors.CYAN)
    print_colored(f"🔁 Modo envio:   {SEND_MODE}", Colors.CYAN)
    print_colored(f"🎯 Leitores:     Leitor_1 (D10/D9) + Leitor_2 (D8/D7)", Colors.CYAN)
    print_colored(f"\n{'='*60}\n", Colors.BOLD)
    
    try:
        # Conecta à porta serial
        print_colored("🔄 Conectando à porta serial...", Colors.YELLOW)
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        time.sleep(2)  # Aguarda inicialização do Arduino
        
        print_colored("✅ Conectado! Aguardando leituras RFID...\n", Colors.GREEN)
        
        # Loop principal
        while True:
            if ser.in_waiting > 0:
                try:
                    line = ser.readline().decode('utf-8', errors='ignore').strip()
                    if line:
                        process_serial_line(line)
                except UnicodeDecodeError:
                    pass  # Ignora erros de decodificação
                    
    except serial.SerialException as e:
        print_colored(f"\n❌ Erro ao abrir porta serial: {e}", Colors.RED)
        print_colored(f"\n💡 Dicas:", Colors.YELLOW)
        print_colored(f"   - Verifique se o Arduino está conectado", Colors.YELLOW)
        print_colored(f"   - Confirme a porta correta: {SERIAL_PORT}", Colors.YELLOW)
        print_colored(f"   - Verifique permissões: sudo usermod -a -G dialout $USER", Colors.YELLOW)
        print_colored(f"   - Feche outras aplicações usando a porta (Arduino IDE, etc.)", Colors.YELLOW)
        sys.exit(1)
        
    except KeyboardInterrupt:
        print_colored("\n\n⏹️  Encerrando RFID Bridge...", Colors.YELLOW)
        if 'ser' in locals():
            ser.close()
        print_colored("✅ Encerrado com sucesso!\n", Colors.GREEN)
        sys.exit(0)
        
    except Exception as e:
        print_colored(f"\n❌ Erro inesperado: {e}", Colors.RED)
        if 'ser' in locals():
            ser.close()
        sys.exit(1)

if __name__ == "__main__":
    main()
