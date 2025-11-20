# 🏷️ Sistema RFID - Rastreamento IoT# 🏷️ Sistema RFID - Rastreamento IoT# 🏷️ Sistema RFID - Rastreamento de Objetos IoT# Leitor RFID RC522 - Arduino UNO



Sistema com **2 leitores RFID RC522** no Arduino UNO que envia leituras automaticamente para o frontend via API.



## ⚡ Quick StartSistema com **2 leitores RFID RC522** no Arduino UNO que envia leituras automaticamente para o frontend via API.



### 1. Hardware - Conectar os Leitores



**Pinos Compartilhados (SPI):** MOSI→D11, MISO→D12, SCK→D13, 3.3V, GND  ## ⚡ Quick StartSistema de leitura RFID com **2 leitores RC522** no Arduino UNO que envia dados automaticamente via HTTP POST para uma API.Projeto de leitura de tags RFID usando o módulo RC522 com Arduino UNO.

**Leitor 1:** SDA→D10, RST→D9  

**Leitor 2:** SDA→D8, RST→D7



⚠️ **Cada leitor precisa de SDA/SS e RST próprios!**### 1. Hardware - Conectar os Leitores



### 2. Programar o Arduino



```bash**Pinos Compartilhados (SPI):** MOSI→D11, MISO→D12, SCK→D13, 3.3V, GND  ## 🔌 Hardware## 📋 Componentes Necessários

pio run --target upload

```**Leitor 1:** SDA→D10, RST→D9  



### 3. Instalar Dependências Python**Leitor 2:** SDA→D8, RST→D7



```bash

pip install pyserial requests

```⚠️ **Cada leitor precisa de SDA/SS e RST próprios!**### Componentes- Arduino UNO



### 4. Configurar o Dispositivo



Edite `config.json` e escolha qual leitor está usando:### 2. Programar o Arduino- Arduino UNO- Módulo RFID RC522



```json

{

  "api": {```bash- 2x Módulos RFID RC522- Jumpers para conexão

    "dispositivo_id": 1

  }pio run --target upload

}

``````- Jumpers- Cabo USB para programação



**IDs disponíveis:**

- `1` = Leitor Sala A (DEV-A)

- `2` = Leitor Sala B (DEV-B)### 3. Instalar Dependências Python- Tags/cartões RFID 13.56MHz- Tags/cartões RFID (13.56MHz)

- `3` = Leitor Corredor (DEV-COR)

- `4` = Leitor Externo (DEV-EXT)



### 5. Iniciar o Frontend```bash



```bashpip install pyserial requests

cd iot-front

npm run dev```### Conexões## 🔌 Esquema de Ligação

# Roda em http://localhost:8085

```



### 6. Testar### 4. Configurar o Dispositivo



**Opção A: COM Arduino**

```bash

python3 rfid_bridge.pyEdite `config.json` e escolha qual leitor está usando:**Pinos Compartilhados (SPI):**Conecte o módulo RC522 ao Arduino UNO conforme o esquema abaixo:

# Aproxime uma tag

```



**Opção B: SEM Arduino (Simulador)**```json| Pino RC522 | Arduino |

```bash

python3 simulador_rfid.py{

```

  "api": {|------------|---------|| Pino RC522 | Pino Arduino UNO |

**Menu do simulador:**

- `1` - Enviar uma leitura aleatória    "dispositivo_id": 1

- `2` - Escolher tag específica

- `3` - Enviar múltiplas leituras automaticamente  }| MOSI       | D11     ||------------|------------------|

- `4` - Trocar o dispositivo (1-4)

}

## 📊 O que você verá

```| MISO       | D12     || SDA/SS     | D10              |

### No Terminal (Bridge ou Simulador)



```

============================================================**IDs disponíveis:**| SCK        | D13     || SCK        | D13              |

🎫 RFID DETECTADO / LEITURA SIMULADA

============================================================- `1` = Leitor Sala A (DEV-A)

Leitor:        Leitor_1

UID (Hex):     7F:BE:A3:FB- `2` = Leitor Sala B (DEV-B)| 3.3V       | 3.3V    || MOSI       | D11              |



📋 Payload JSON:- `3` = Leitor Corredor (DEV-COR)

{

  "tag_codigo": "7F:BE:A3:FB",- `4` = Leitor Externo (DEV-EXT)| GND        | GND     || MISO       | D12              |

  "lido_em": "2025-11-20 15:30:45",

  "fk_id_dispositivo": 1

}

### 5. Iniciar o Frontend| RST        | D9               |

📤 Enviando para API: http://localhost:8085/api/leitura

✅ Enviado com sucesso! Status: 201

============================================================

``````bash**Pinos Individuais:**| 3.3V       | 3.3V             |



### No Frontendcd iot-front



A leitura aparecerá automaticamente na interface do iot-front!npm run dev| Leitor | SDA/SS | RST || GND        | GND              |



## 🔧 Problemas Comuns# Roda em http://localhost:8085



**"Porta serial não encontrada"** (apenas com Arduino)```|--------|--------|-----|

```bash

ls /dev/ttyACM* /dev/ttyUSB*

sudo usermod -a -G dialout $USER  # Depois relogar

```### 6. Iniciar o Bridge RFID| 1      | D10    | D9  |⚠️ **IMPORTANTE**: O módulo RC522 opera em **3.3V**. Não conecte ao pino 5V!



**"Device disconnected or multiple access"** (apenas com Arduino)

- Feche o monitor serial do PlatformIO (Ctrl+C)

- Use apenas o bridge Python (ele mostra tudo)```bash| 2      | D8     | D7  |



**Leitor não detecta tags** (apenas com Arduino)python3 rfid_bridge.py

- Verifique 3.3V (não 5V!)

- Confira se cada SDA está em pino diferente (D10 e D8)```## 🚀 Como Iniciar



**"Não foi possível conectar à API"**

- Verifique se `npm run dev` está rodando no iot-front

- Confirme que a porta é 8085### 7. Testar - Aproxime uma Tag!⚠️ **IMPORTANTE:** Cada leitor precisa de **SDA/SS e RST próprios**. Os pinos SPI são compartilhados.

- Teste: `curl http://localhost:8085/api/leitura`



**Frontend não atualiza**

- Confirme `dispositivo_id` no config.json (1-4)O sistema irá:### Pré-requisitos

- Veja logs no terminal do bridge/simulador

- Verifique se a API retornou status 2011. ✅ Ler a tag do Arduino



## 📂 Arquivos Importantes2. ✅ Enviar POST para `http://localhost:8085/api/leitura`## 🚀 Instalação



```3. ✅ Salvar no MySQL

iot-rastreio-objetos/

├── src/main.cpp       # Código Arduino (2 leitores)4. ✅ **Aparecer no frontend automaticamente**- PlatformIO instalado (via extensão do VS Code ou CLI)

├── rfid_bridge.py     # Bridge Serial→HTTP (com Arduino)

├── simulador_rfid.py  # Simulador (sem Arduino) ⭐

├── config.json        # Configuração (edite aqui!)

└── iot-front/         # Frontend Next.js## 📊 O que você verá no terminal### 1. Programar o Arduino- Arduino UNO conectado via USB

```



## 🎯 Fluxo Completo

```- Porta serial configurada (padrão: `/dev/ttyACM0`)

### COM Arduino:

**Arduino** (lê tag) → **Serial USB** → **Bridge Python** → **HTTP POST** → **API Next.js** → **MySQL** → **Frontend**============================================================



### SEM Arduino (Teste):🎫 RFID DETECTADO```bash

**Simulador Python** → **HTTP POST** → **API Next.js** → **MySQL** → **Frontend**

============================================================

---

Leitor:        Leitor_1# Upload do código### Passo 1: Clonar/Abrir o Projeto

**Pronto para usar!** Inicie o frontend e escolha testar com Arduino ou simulador. 🚀

UID (Hex):     7F:BE:A3:FB

pio run --target upload

📋 Payload JSON:

{```bash

  "tag_codigo": "7F:BE:A3:FB",

  "lido_em": "2025-11-20 15:30:45",# Monitorar serial (opcional)cd /home/Documentos/PlatformIO/Projects/Teste

  "fk_id_dispositivo": 1

}pio device monitor --baud 115200```



📤 Enviando para API: http://localhost:8085/api/leitura```

✅ Enviado com sucesso! Status: 201

============================================================### Passo 2: Compilar e Fazer Upload

```

### 2. Instalar dependências Python

## 🔧 Problemas Comuns

Execute o comando para compilar e enviar o código para o Arduino:

**"Porta serial não encontrada"**

```bash```bash

ls /dev/ttyACM* /dev/ttyUSB*

sudo usermod -a -G dialout $USER  # Depois relogarpip install pyserial requests```bash

```

```~/.platformio/penv/bin/platformio run --target upload

**"Device disconnected or multiple access"**

- Feche o monitor serial do PlatformIO (Ctrl+C)```

- Use apenas o bridge Python (ele mostra tudo)

## ⚙️ Configuração

**Leitor não detecta tags**

- Verifique 3.3V (não 5V!)Ou se tiver o PlatformIO no PATH:

- Confira se cada SDA está em pino diferente (D10 e D8)

Edite `config.json` para sua API:

**Frontend não atualiza**

- Verifique se `npm run dev` está rodando```bash

- Confirme `dispositivo_id` no config.json

- Veja logs no terminal do bridge```jsonpio run --target upload



## 📂 Arquivos Importantes{```



```  "serial": {

iot-rastreio-objetos/

├── src/main.cpp       # Código Arduino    "port": "/dev/ttyACM0",**Saída esperada:**

├── rfid_bridge.py     # Bridge Serial→HTTP

├── config.json        # Configuração (edite aqui!)    "baud_rate": 115200```

└── iot-front/         # Frontend Next.js

```  },[SUCCESS] Took X.XX seconds



## 🎯 Fluxo Completo  "api": {```



**Arduino** (lê tag) → **Serial USB** → **Bridge Python** (converte) → **HTTP POST** → **API Next.js** → **MySQL** → **Frontend atualiza**    "base_url": "http://localhost:3000",



---    "route": "/api/rfid",### Passo 3: Iniciar a Leitura



**Pronto para usar!** Inicie o frontend, rode o bridge e aproxime uma tag. 🚀    "payload_fields": ["reader", "uid_hex", "timestamp_ms"]


  }Após o upload bem-sucedido, abra o monitor serial para visualizar as leituras:

}

``````bash

~/.platformio/penv/bin/platformio device monitor --baud 115200

**Campos disponíveis:** `reader`, `uid_hex`, `uid_decimal`, `card_type`, `date`, `time`, `datetime`, `timestamp_ms`, `arduino_timestamp````



## 🎯 UsoOu:



### Iniciar o sistema```bash

pio device monitor --baud 115200

```bash```

python3 rfid_bridge.py

```## 📖 Como Usar



### O que acontece ao aproximar uma tag:1. Após abrir o monitor serial, você verá uma animação de espera:

   ```

1. ✅ Arduino detecta a tag   Aguardando tag: ========

2. ✅ Envia JSON via Serial   ```

3. ✅ Bridge Python captura

4. ✅ **Dispara POST automático** para sua API2. Aproxime uma tag ou cartão RFID do leitor RC522

5. ✅ Mostra resultado no terminal

3. As informações serão exibidas:

### Exemplo de POST enviado   ```

   ----- TAG DETECTADA -----

**URL:** `POST http://localhost:3000/api/rfid`   UID (HEX): 04:A2:B3:C4

   UID (DEC): 78901234

**Body:**   Tipo PICC : MIFARE 1KB

```json   -------------------------

{   ```

  "reader": "Leitor_1",

  "uid_hex": "7F:BE:A3:FB",4. Para encerrar o monitor serial, pressione `Ctrl+C`

  "timestamp_ms": 1700271930123

}## 🛠️ Configurações do Projeto

```

### platformio.ini

## 📝 Exemplo de API (Node.js)

```ini

```javascript[env:uno]

app.post('/api/rfid', (req, res) => {platform = atmelavr

  const { reader, uid_hex } = req.body;board = uno

  console.log(`Tag ${uid_hex} detectada no ${reader}`);framework = arduino

  res.json({ success: true });lib_deps = miguelbalboa/MFRC522

});monitor_speed = 115200

```upload_port = /dev/ttyACM0

```

## 🔧 Troubleshooting

**Ajuste a porta serial** (`upload_port`) se necessário:

**Porta serial não encontrada:**- Linux: `/dev/ttyACM0` ou `/dev/ttyUSB0`

```bash- Windows: `COM3`, `COM4`, etc.

ls /dev/ttyACM* /dev/ttyUSB*  # Listar portas- macOS: `/dev/cu.usbmodem*`

sudo usermod -a -G dialout $USER  # Permissões (relogar após)

```## 📊 Funcionalidades



**Leitor não detecta tags:**- ✅ Leitura de UID em formato Hexadecimal

- Verifique alimentação 3.3V (não 5V!)- ✅ Leitura de UID em formato Decimal

- Confira se SDA de cada leitor está em pino diferente- ✅ Identificação do tipo de tag/cartão (PICC Type)

- Teste cada leitor individualmente- ✅ Animação visual de espera

- ✅ Anti-duplicação de leitura

**API não recebe requisições:**- ✅ Suporte para múltiplas leituras consecutivas

- Confirme que API está rodando- ✅ **Envio de dados via HTTP POST para API REST** (via bridge Python)

- Verifique `base_url` e `route` no `config.json`

- Veja logs no terminal do bridge## 🌐 Integração com API REST



## 📂 Estrutura do ProjetoO projeto inclui um bridge Python que lê os dados do Arduino via Serial e envia para uma API REST via HTTP POST.



```### Formato JSON dos Dados Enviados

iot-rastreio-objetos/

├── src/main.cpp          # Código Arduino (2 leitores)```json

├── rfid_bridge.py        # Bridge Serial → HTTP POST{

├── config.json           # Configuração da API  "uid_decimal": 78901234,

├── platformio.ini        # Config PlatformIO  "uid_hex": "04:A2:B3:C4",

└── requirements.txt      # Dependências Python  "card_type": "MIFARE 1KB",

```  "date": "2025-10-13",

  "time": "19:45:30",

## 🎓 Como Funciona  "datetime": "2025-10-13T19:45:30",

  "timestamp_ms": 1697224530000

1. **Arduino:** Lê tags dos 2 leitores RC522 e envia JSON pela Serial}

2. **Bridge Python:** Lê Serial, monta payload configurável e dispara POST```

3. **Sua API:** Recebe os dados e processa (salvar no DB, notificar, etc)

### Configuração do Bridge Python

---

#### 1. Instalar Dependências

**Última atualização:** Novembro 2025

```bash
pip install -r requirements.txt
```

Ou manualmente:
```bash
pip install pyserial requests
```

#### 2. Configurar URL da API

Edite o arquivo `rfid_bridge.py` e altere as seguintes configurações:

```python
# Porta serial (ajuste conforme necessário)
SERIAL_PORT = '/dev/ttyACM0'  # Linux
# SERIAL_PORT = 'COM3'        # Windows

# URL da API
API_URL = 'http://localhost:3000/api/rfid'  # Altere para sua URL
```

#### 3. Executar o Bridge

Com o Arduino conectado e programado:

```bash
python3 rfid_bridge.py
```

Ou torne-o executável:
```bash
chmod +x rfid_bridge.py
./rfid_bridge.py
```

### Exemplo de Saída do Bridge

```
============================================================
🔌 RFID Bridge - Serial to HTTP
============================================================

📡 Porta Serial: /dev/ttyACM0
⚡ Baud Rate:    115200
🌐 API URL:      http://localhost:3000/api/rfid

============================================================

✅ Conectado! Aguardando leituras RFID...

============================================================
🎫 RFID DETECTADO
============================================================
UID (Decimal): 78901234
UID (Hex):     04:A2:B3:C4
Tipo:          MIFARE 1KB

📋 Payload JSON:
{
  "uid_decimal": 78901234,
  "uid_hex": "04:A2:B3:C4",
  "card_type": "MIFARE 1KB",
  "date": "2025-10-13",
  "time": "19:45:30",
  "datetime": "2025-10-13T19:45:30",
  "timestamp_ms": 1697224530000
}

📤 Enviando para API: http://localhost:3000/api/rfid
✅ Enviado com sucesso! Status: 200
============================================================
```

### Exemplo de API (Node.js/Express)

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.post('/api/rfid', (req, res) => {
  const { uid_decimal, uid_hex, card_type, date, time } = req.body;
  
  console.log('RFID detectado:', {
    uid_decimal,
    uid_hex,
    card_type,
    date,
    time
  });
  
  // Processar dados (salvar no banco, etc.)
  
  res.status(200).json({ 
    success: true, 
    message: 'Dados recebidos com sucesso' 
  });
});

app.listen(3000, () => {
  console.log('API rodando na porta 3000');
});
```

## 🔧 Solução de Problemas

### Erro: "porta serial não encontrada"

Verifique se o Arduino está conectado:
```bash
ls /dev/ttyACM* /dev/ttyUSB*
```

Ajuste o `upload_port` no arquivo `platformio.ini` conforme necessário.

### Erro: "permissão negada"

Adicione seu usuário ao grupo dialout:
```bash
sudo usermod -a -G dialout $USER
```
Faça logout e login novamente.

### Leitor não detecta tags

1. Verifique as conexões dos fios
2. Confirme que o módulo está alimentado com 3.3V
3. Teste com diferentes tags/cartões
4. Verifique se a tag é compatível (13.56MHz)

### Monitor serial não abre

Feche outras aplicações que possam estar usando a porta serial (Arduino IDE, minicom, etc.).

## 📚 Bibliotecas Utilizadas

- **MFRC522** (miguelbalboa/MFRC522): Biblioteca para comunicação com o módulo RC522
- **SPI**: Comunicação SPI nativa do Arduino
- **Arduino.h**: Framework Arduino

## 💡 Próximos Passos

Possíveis melhorias para o projeto:

- [ ] Adicionar gravação de dados nas tags
- [ ] Implementar controle de acesso
- [ ] Armazenar UIDs em memória EEPROM
- [ ] Adicionar buzzer para feedback sonoro
- [ ] Integrar com display LCD para exibição local
- [ ] Conectar com ESP32 para envio de dados via Wi-Fi

## 📝 Licença

Este projeto é de código aberto e está disponível para uso educacional e comercial.

## 👤 Autor

Desenvolvido para rastreamento de objetos IoT.

---

**Última atualização:** Outubro de 2025
