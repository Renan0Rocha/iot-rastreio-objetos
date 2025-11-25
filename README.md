# 🏷️ Sistema RFID - Rastreamento IoT

Sistema com **3 leitores RFID RC522** no Arduino UNO que envia leituras automaticamente para o frontend via API.

## ⚡ Quick Start

### 1. Hardware - Conectar os 3 Leitores

**Pinos Compartilhados (SPI):**  
MOSI→D11, MISO→D12, SCK→D13, 3.3V, GND

**Pinos Individuais:**
- **Leitor 1 (Sala A):** SDA→D10, RST→D9
- **Leitor 2 (Sala B):** SDA→D8, RST→D7
- **Leitor 3 (Externo):** SDA→D4, RST→D3

⚠️ **Importante:** Cada leitor precisa de SDA/SS e RST próprios! Use 3.3V (não 5V).

### 2. Programar o Arduino

```bash
platformio run --target upload
```

### 3. Instalar Dependências Python

```bash
pip install pyserial requests
```

### 4. Configurar o Banco de Dados

O sistema usa MySQL/MariaDB via Docker:

```bash
# Iniciar container (se não estiver rodando)
docker start mysql_db

# Verificar se está rodando
docker ps | grep mysql
```

### 5. Iniciar o Frontend

```bash
cd iot-front
npm run dev
# Acesse: http://localhost:8085
```

### 6. Iniciar o Bridge RFID

```bash
python3 rfid_bridge.py
```

Agora aproxime uma tag RFID de qualquer leitor! 🎯

---

## 📊 Mapeamento de Leitores

O sistema mapeia automaticamente cada leitor para o dispositivo correto:

| Leitor Arduino | Pinos | Dispositivo | ID |
|----------------|-------|-------------|-----|
| Leitor_1 | SS=D10, RST=D9 | Leitor Sala A | 1 |
| Leitor_2 | SS=D8, RST=D7 | Leitor Sala B | 2 |
| Leitor_3 | SS=D4, RST=D3 | Leitor Externo | 4 |

---

## 🧪 Testar sem Arduino (Simulador)

```bash
python3 simulador_rfid.py
```

**Menu do simulador:**
- `1` - Enviar uma leitura aleatória
- `2` - Escolher tag específica
- `3` - Enviar múltiplas leituras automaticamente
- `4` - Trocar o dispositivo (1, 2 ou 4)

---

## 📋 O que você verá

### No Terminal (Bridge)

```
============================================================
🎫 RFID DETECTADO
============================================================
Leitor:        Leitor_2
UID (Hex):     2E:C7:91:AB
Tipo:          MIFARE 1KB

📋 Payload JSON:
{
  "tag_codigo": "2E:C7:91:AB",
  "lido_em": "2025-11-24 19:30:45",
  "rssi": -50,
  "payload_json": "{...}",
  "fk_id_dispositivo": 2
}

📤 Enviando para API: http://localhost:8085/api/leitura
✅ Enviado com sucesso! Status: 201
============================================================
```

### No Frontend

- **Leituras:** Todas as tags detectadas
- **Movimentações:** Rastreamento automático de objetos cadastrados
- **Itens:** Cadastro com busca automática da última tag lida

---

## 🔧 Problemas Comuns

### Porta serial não encontrada

```bash
ls /dev/ttyACM* /dev/ttyUSB*
sudo usermod -a -G dialout $USER  # Depois relogar
```

### Leitor não detecta tags

- Verifique alimentação **3.3V** (não 5V!)
- Confirme que cada SDA está em pino diferente
- Teste cada leitor individualmente

### Banco de dados não conecta

```bash
# Verificar se o container está rodando
docker ps | grep mysql

# Iniciar se necessário
docker start mysql_db

# Reiniciar o Next.js após iniciar o banco
cd iot-front
npm run dev
```

### Frontend não atualiza

- Confirme que `npm run dev` está rodando
- Verifique se o bridge Python está ativo
- A lista de movimentações atualiza automaticamente a cada 3 segundos

---

## 📂 Estrutura do Projeto

```
iot-rastreio-objetos/
├── src/main.cpp           # Código Arduino (3 leitores)
├── rfid_bridge.py         # Bridge Serial→HTTP (com Arduino)
├── simulador_rfid.py      # Simulador (sem Arduino) ⭐
├── config.json            # Configuração da API
└── iot-front/             # Frontend Next.js + MySQL
```

---

## 🎯 Fluxo Completo

**COM Arduino:**  
Arduino (lê tag) → Serial USB → Bridge Python → HTTP POST → API Next.js → MySQL → Frontend

**SEM Arduino (Teste):**  
Simulador Python → HTTP POST → API Next.js → MySQL → Frontend

---

## ✨ Funcionalidades

- ✅ **3 leitores RFID simultâneos** com mapeamento automático
- ✅ **Auto-refresh** nas listas de movimentação (3 segundos)
- ✅ **Busca automática de tag** no cadastro de itens
- ✅ **Rastreamento de objetos** por tag RFID
- ✅ **Simulador** para testes sem hardware
- ✅ **API RESTful** com Next.js e MySQL

---

**Desenvolvido para rastreamento de objetos IoT** 🚀
