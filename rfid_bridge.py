#!/usr/bin/env python3
"""
RFID Bridge - Serial to HTTP
Lê dados RFID do Arduino via Serial e envia para API REST via HTTP POST

Autor: Sistema IoT de Rastreamento de Objetos
Data: Outubro 2025
"""

import serial
import requests
import json
from datetime import datetime
import time
import sys

# ==================== CONFIGURAÇÕES ====================
# Porta serial onde o Arduino está conectado
SERIAL_PORT = '/dev/ttyACM0'  # Linux: /dev/ttyACM0 ou /dev/ttyUSB0
                               # Windows: COM3, COM4, etc.
                               # macOS: /dev/cu.usbmodem*

# Baud rate (deve ser o mesmo configurado no Arduino)
BAUD_RATE = 115200

# URL da API para onde enviar os dados
API_URL = 'http://localhost:3000/api/rfid'  # Altere para sua URL

# Timeout de requisição HTTP (segundos)
REQUEST_TIMEOUT = 5

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
    Cria o payload JSON para enviar à API
    
    Args:
        rfid_data (dict): Dados do RFID lidos do Arduino
    
    Returns:
        dict: Payload formatado com timestamp
    """
    now = datetime.now()
    
    payload = {
        "uid_decimal": rfid_data.get("uid_decimal"),
        "uid_hex": rfid_data.get("uid_hex"),
        "card_type": rfid_data.get("card_type"),
        "date": now.strftime("%Y-%m-%d"),
        "time": now.strftime("%H:%M:%S"),
        "datetime": now.isoformat(),
        "timestamp_ms": int(time.time() * 1000)
    }
    
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
        headers = {
            'Content-Type': 'application/json',
            'User-Agent': 'RFID-Bridge/1.0'
        }
        
        print_colored(f"📤 Enviando para API: {API_URL}", Colors.CYAN)
        
        response = requests.post(
            API_URL,
            json=payload,
            headers=headers,
            timeout=REQUEST_TIMEOUT
        )
        
        if response.status_code in [200, 201]:
            print_colored(f"✅ Enviado com sucesso! Status: {response.status_code}", Colors.GREEN)
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
            print_colored(f"UID (Decimal): {rfid_data.get('uid_decimal')}", Colors.CYAN)
            print_colored(f"UID (Hex):     {rfid_data.get('uid_hex')}", Colors.CYAN)
            print_colored(f"Tipo:          {rfid_data.get('card_type')}", Colors.CYAN)
            
            # Cria payload com data/hora
            payload = create_payload(rfid_data)
            
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
    print_colored("🔌 RFID Bridge - Serial to HTTP", Colors.BOLD + Colors.GREEN)
    print_colored("="*60 + "\n", Colors.BOLD)
    
    print_colored(f"📡 Porta Serial: {SERIAL_PORT}", Colors.CYAN)
    print_colored(f"⚡ Baud Rate:    {BAUD_RATE}", Colors.CYAN)
    print_colored(f"🌐 API URL:      {API_URL}", Colors.CYAN)
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
