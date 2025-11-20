#!/usr/bin/env python3
"""
Simulador de Leituras RFID - Para testar sem Arduino
Simula leituras de tags RFID e envia para a API
"""

import requests
import json
from datetime import datetime
import time
import random

# Configurações
API_URL = "http://localhost:8085/api/leitura"
DISPOSITIVO_ID = 1  # Altere conforme necessário (1-4)

# Tags de exemplo para simular
TAGS_EXEMPLO = [
    "7F:BE:A3:FB",
    "04:A2:B3:C4",
    "1A:2B:3C:4D",
    "FF:EE:DD:CC",
    "AA:BB:CC:DD"
]

def gerar_tag_aleatoria():
    """Gera uma tag RFID aleatória"""
    return ":".join([f"{random.randint(0, 255):02X}" for _ in range(4)])

def enviar_leitura(tag_codigo, dispositivo_id):
    """Envia uma leitura simulada para a API"""
    now = datetime.now()
    
    payload = {
        "tag_codigo": tag_codigo,
        "lido_em": now.strftime("%Y-%m-%d %H:%M:%S"),
        "rssi": random.randint(-80, -30),  # Simula sinal RFID (-30 forte, -80 fraco)
        "payload_json": json.dumps({
            "reader": "Simulador",
            "protocol": "ISO14443A",
            "frequency": "13.56MHz"
        }),
        "fk_id_dispositivo": dispositivo_id
    }
    
    print("\n" + "="*60)
    print("🎫 LEITURA SIMULADA")
    print("="*60)
    print(f"Tag:         {tag_codigo}")
    print(f"Dispositivo: {dispositivo_id}")
    print(f"Data/Hora:   {payload['lido_em']}")
    
    print("\n📋 Payload JSON:")
    print(json.dumps(payload, indent=2))
    
    try:
        print(f"\n📤 Enviando para API: {API_URL}")
        response = requests.post(
            API_URL,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=5
        )
        
        if response.status_code in [200, 201]:
            print(f"✅ Enviado com sucesso! Status: {response.status_code}")
            print(f"   Resposta: {response.text[:200]}")
            return True
        else:
            print(f"⚠️  Resposta inesperada: {response.status_code}")
            print(f"   {response.text[:200]}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Erro: Não foi possível conectar à API")
        print(f"   Verifique se a API está rodando em: {API_URL}")
        return False
        
    except Exception as e:
        print(f"❌ Erro ao enviar: {str(e)}")
        return False
    
    finally:
        print("="*60 + "\n")

def menu():
    """Menu interativo"""
    print("\n" + "="*60)
    print("🔌 SIMULADOR DE LEITURAS RFID")
    print("="*60)
    print(f"\n📡 API URL:      {API_URL}")
    print(f"🎯 Dispositivo:  ID {DISPOSITIVO_ID}")
    print("\nOpções:")
    print("  1 - Simular UMA leitura aleatória")
    print("  2 - Simular leitura de tag específica")
    print("  3 - Simular MÚLTIPLAS leituras (automático)")
    print("  4 - Alterar dispositivo ID")
    print("  0 - Sair")
    print("="*60)

def main():
    global DISPOSITIVO_ID
    
    while True:
        menu()
        escolha = input("\nEscolha uma opção: ").strip()
        
        if escolha == "1":
            # Uma leitura aleatória
            tag = random.choice(TAGS_EXEMPLO)
            enviar_leitura(tag, DISPOSITIVO_ID)
            
        elif escolha == "2":
            # Tag específica
            print("\nTags de exemplo:")
            for i, tag in enumerate(TAGS_EXEMPLO, 1):
                print(f"  {i}. {tag}")
            print("  0. Digitar manualmente")
            
            opcao = input("\nEscolha uma tag: ").strip()
            
            if opcao == "0":
                tag = input("Digite a tag (formato XX:XX:XX:XX): ").strip().upper()
            elif opcao.isdigit() and 1 <= int(opcao) <= len(TAGS_EXEMPLO):
                tag = TAGS_EXEMPLO[int(opcao) - 1]
            else:
                print("❌ Opção inválida!")
                continue
            
            enviar_leitura(tag, DISPOSITIVO_ID)
            
        elif escolha == "3":
            # Múltiplas leituras
            try:
                qtd = int(input("Quantas leituras? (0 = infinito): ").strip())
                intervalo = float(input("Intervalo entre leituras (segundos): ").strip())
            except ValueError:
                print("❌ Valor inválido!")
                continue
            
            print(f"\n▶️  Iniciando simulação... (Ctrl+C para parar)\n")
            
            try:
                contador = 0
                while qtd == 0 or contador < qtd:
                    tag = random.choice(TAGS_EXEMPLO)
                    enviar_leitura(tag, DISPOSITIVO_ID)
                    contador += 1
                    
                    if qtd > 0:
                        print(f"📊 Progresso: {contador}/{qtd}")
                    
                    time.sleep(intervalo)
                    
            except KeyboardInterrupt:
                print("\n\n⏹️  Simulação interrompida!")
                print(f"📊 Total de leituras enviadas: {contador}")
            
        elif escolha == "4":
            # Alterar dispositivo
            print("\nDispositivos disponíveis:")
            print("  1 - Leitor Sala A (DEV-A)")
            print("  2 - Leitor Sala B (DEV-B)")
            print("  3 - Leitor Corredor (DEV-COR)")
            print("  4 - Leitor Externo (DEV-EXT)")
            
            try:
                novo_id = int(input("\nNovo dispositivo ID: ").strip())
                if 1 <= novo_id <= 4:
                    DISPOSITIVO_ID = novo_id
                    print(f"✅ Dispositivo alterado para ID {DISPOSITIVO_ID}")
                else:
                    print("❌ ID inválido! Use 1-4")
            except ValueError:
                print("❌ Valor inválido!")
                
        elif escolha == "0":
            print("\n👋 Encerrando simulador...")
            break
            
        else:
            print("❌ Opção inválida!")

if __name__ == "__main__":
    print("\n🚀 Simulador de Leituras RFID")
    print("Certifique-se que a API está rodando em: http://localhost:8085")
    input("\nPressione ENTER para continuar...")
    
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 Encerrando simulador...")
    except Exception as e:
        print(f"\n❌ Erro inesperado: {e}")
