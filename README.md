# Leitor RFID RC522 - Arduino UNO

Projeto de leitura de tags RFID usando o módulo RC522 com Arduino UNO.

## 📋 Componentes Necessários

- Arduino UNO
- Módulo RFID RC522
- Jumpers para conexão
- Cabo USB para programação
- Tags/cartões RFID (13.56MHz)

## 🔌 Esquema de Ligação

Conecte o módulo RC522 ao Arduino UNO conforme o esquema abaixo:

| Pino RC522 | Pino Arduino UNO |
|------------|------------------|
| SDA/SS     | D10              |
| SCK        | D13              |
| MOSI       | D11              |
| MISO       | D12              |
| RST        | D9               |
| 3.3V       | 3.3V             |
| GND        | GND              |

⚠️ **IMPORTANTE**: O módulo RC522 opera em **3.3V**. Não conecte ao pino 5V!

## 🚀 Como Iniciar

### Pré-requisitos

- PlatformIO instalado (via extensão do VS Code ou CLI)
- Arduino UNO conectado via USB
- Porta serial configurada (padrão: `/dev/ttyACM0`)

### Passo 1: Clonar/Abrir o Projeto

```bash
cd /home/Documentos/PlatformIO/Projects/Teste
```

### Passo 2: Compilar e Fazer Upload

Execute o comando para compilar e enviar o código para o Arduino:

```bash
~/.platformio/penv/bin/platformio run --target upload
```

Ou se tiver o PlatformIO no PATH:

```bash
pio run --target upload
```

**Saída esperada:**
```
[SUCCESS] Took X.XX seconds
```

### Passo 3: Iniciar a Leitura

Após o upload bem-sucedido, abra o monitor serial para visualizar as leituras:

```bash
~/.platformio/penv/bin/platformio device monitor --baud 115200
```

Ou:

```bash
pio device monitor --baud 115200
```

## 📖 Como Usar

1. Após abrir o monitor serial, você verá uma animação de espera:
   ```
   Aguardando tag: ========
   ```

2. Aproxime uma tag ou cartão RFID do leitor RC522

3. As informações serão exibidas:
   ```
   ----- TAG DETECTADA -----
   UID (HEX): 04:A2:B3:C4
   UID (DEC): 78901234
   Tipo PICC : MIFARE 1KB
   -------------------------
   ```

4. Para encerrar o monitor serial, pressione `Ctrl+C`

## 🛠️ Configurações do Projeto

### platformio.ini

```ini
[env:uno]
platform = atmelavr
board = uno
framework = arduino
lib_deps = miguelbalboa/MFRC522
monitor_speed = 115200
upload_port = /dev/ttyACM0
```

**Ajuste a porta serial** (`upload_port`) se necessário:
- Linux: `/dev/ttyACM0` ou `/dev/ttyUSB0`
- Windows: `COM3`, `COM4`, etc.
- macOS: `/dev/cu.usbmodem*`

## 📊 Funcionalidades

- ✅ Leitura de UID em formato Hexadecimal
- ✅ Leitura de UID em formato Decimal
- ✅ Identificação do tipo de tag/cartão (PICC Type)
- ✅ Animação visual de espera
- ✅ Anti-duplicação de leitura
- ✅ Suporte para múltiplas leituras consecutivas

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
