# 🚀 Guia de Uso - Sistema RFID com API

## 📋 Visão Geral

Sistema completo de leitura RFID com **2 leitores RC522** que envia dados via HTTP POST para uma API REST.

### Componentes:
1. **Arduino UNO** - Lê os 2 sensores RC522
2. **rfid_bridge.py** - Recebe dados via Serial e envia para API
3. **API REST** - Recebe e processa os dados (você implementa)

---

## 🔌 Configuração Rápida

### 1️⃣ Configurar a URL da API

Edite o arquivo `config.json`:

```json
{
  "api": {
    "url": "http://localhost:3000/api/rfid"
    ⬆️ ALTERE ESTA URL PARA SUA API
  }
}
```

**Exemplos de URLs:**

```json
// API local (desenvolvimento)
"url": "http://localhost:3000/api/rfid"

// API em servidor remoto
"url": "https://meuservidor.com/api/v1/rfid"

// API com autenticação (adicione headers)
"url": "https://api.exemplo.com/rfid"
// E em headers:
"headers": {
  "Content-Type": "application/json",
  "Authorization": "Bearer SEU_TOKEN_AQUI"
}
```

### 2️⃣ Iniciar o Sistema

**Passo 1: Upload do código para o Arduino**
```bash
~/.platformio/penv/bin/platformio run --target upload
```

**Passo 2: Iniciar o Bridge Python**
```bash
python3 rfid_bridge.py
```

✅ Pronto! O sistema está rodando.

---

## 📤 Formato dos Dados Enviados

Quando uma tag RFID for detectada, o bridge envia este JSON para sua API:

```json
{
  "reader": "Leitor_1",
  "uid_decimal": 2143200251,
  "uid_hex": "7F:BE:A3:FB",
  "card_type": "MIFARE 1KB",
  "date": "2025-11-17",
  "time": "14:35:22",
  "datetime": "2025-11-17T14:35:22",
  "timestamp_ms": 1700234122000,
  "arduino_timestamp": 45230
}
```

### Campos:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `reader` | string | Identifica qual leitor detectou (`Leitor_1` ou `Leitor_2`) |
| `uid_decimal` | number | UID em formato decimal |
| `uid_hex` | string | UID em formato hexadecimal (ex: `7F:BE:A3:FB`) |
| `card_type` | string | Tipo do cartão (ex: `MIFARE 1KB`) |
| `date` | string | Data da leitura (formato: `YYYY-MM-DD`) |
| `time` | string | Hora da leitura (formato: `HH:MM:SS`) |
| `datetime` | string | Data/hora ISO 8601 |
| `timestamp_ms` | number | Timestamp em milissegundos (Unix epoch) |
| `arduino_timestamp` | number | Tempo em ms desde que o Arduino ligou |

---

## 🎯 Exemplo de API (Node.js)

Incluí um exemplo funcional em `api_exemplo.js`. Para usá-lo:

```bash
# 1. Instalar dependências
npm init -y
npm install express body-parser

# 2. Iniciar a API
node api_exemplo.js

# Saída:
# 🚀 API RFID Iniciada!
# 📡 Servidor rodando em: http://localhost:3000
```

### Sua API deve:

1. **Aceitar POST** em `/api/rfid`
2. **Retornar status 200** se processar com sucesso
3. **Processar o JSON** recebido

**Exemplo mínimo (Express.js):**

```javascript
app.post('/api/rfid', (req, res) => {
  const { reader, uid_hex, card_type } = req.body;
  
  console.log(`Tag detectada! Leitor: ${reader}, UID: ${uid_hex}`);
  
  // Sua lógica aqui (salvar no banco, verificar acesso, etc)
  
  res.status(200).json({ success: true });
});
```

---

## 🔧 Configurações Avançadas

### Alterar Porta Serial

Se o Arduino estiver em outra porta, edite `config.json`:

```json
{
  "serial": {
    "port": "/dev/ttyUSB0"  // Linux
    // ou
    "port": "COM3"          // Windows
  }
}
```

### Adicionar Headers HTTP Personalizados

Para APIs com autenticação:

```json
{
  "api": {
    "url": "https://api.exemplo.com/rfid",
    "headers": {
      "Content-Type": "application/json",
      "Authorization": "Bearer seu_token_aqui",
      "X-API-Key": "sua_chave_api"
    }
  }
}
```

### Desabilitar Debug

Para reduzir output no terminal:

```json
{
  "debug": {
    "enabled": false,
    "show_payload": false
  }
}
```

---

## 📊 Fluxo de Dados

```
┌─────────────┐
│  Tag RFID   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  RC522 #1   │──┐
└─────────────┘  │
                 │  SPI
┌─────────────┐  │
│  RC522 #2   │──┤
└─────────────┘  │
       │         │
       ▼         ▼
┌──────────────────┐
│  Arduino UNO     │
│  (main.cpp)      │
└────────┬─────────┘
         │ Serial (115200 baud)
         │ JSON
         ▼
┌──────────────────┐
│ rfid_bridge.py   │
│ (Python)         │
└────────┬─────────┘
         │ HTTP POST
         │ JSON
         ▼
┌──────────────────┐
│   Sua API REST   │
│  (Node/Python/   │
│   PHP/etc)       │
└──────────────────┘
         │
         ▼
    Banco de Dados
    Webhooks
    Notificações
    etc.
```

---

## 🐛 Solução de Problemas

### "Erro: Não foi possível conectar à API"

✅ **Verificar:**
- A API está rodando? (`curl http://localhost:3000/api/status`)
- A URL em `config.json` está correta?
- Tem firewall bloqueando?

### "Nenhuma tag detectada"

✅ **Verificar:**
- Monitor serial mostra "Aguardando tag"?
- Aproxime a tag a menos de 3cm do leitor
- Verifique conexões físicas (especialmente SDA e RST)

### "Leitor 2 não responde"

✅ **Verificar:**
- SDA do Leitor 2 está em D8? (não D10)
- RST do Leitor 2 está em D7? (não D9)
- Alimentação 3.3V está conectada?

---

## 📝 Casos de Uso

### Controle de Acesso

```javascript
app.post('/api/rfid', async (req, res) => {
  const { uid_hex, reader } = req.body;
  
  const isAuthorized = await checkAuthorization(uid_hex);
  
  if (isAuthorized) {
    const location = reader === 'Leitor_1' ? 'Entrada' : 'Saída';
    await logAccess(uid_hex, location);
    await unlockDoor(reader);
    
    res.json({ success: true, access: 'granted' });
  } else {
    res.status(403).json({ success: false, access: 'denied' });
  }
});
```

### Rastreamento de Objetos

```javascript
app.post('/api/rfid', async (req, res) => {
  const { uid_hex, reader, datetime } = req.body;
  
  await db.object_tracking.create({
    object_id: uid_hex,
    checkpoint: reader === 'Leitor_1' ? 'Ponto A' : 'Ponto B',
    timestamp: datetime
  });
  
  res.json({ success: true });
});
```

### Registro de Presença

```javascript
app.post('/api/rfid', async (req, res) => {
  const { uid_hex, datetime } = req.body;
  
  const user = await db.users.findOne({ card_uid: uid_hex });
  
  if (user) {
    await db.attendance.create({
      user_id: user.id,
      timestamp: datetime
    });
    
    res.json({ 
      success: true, 
      message: `Bem-vindo, ${user.name}!` 
    });
  }
});
```

---

## 📚 Referências

- **Documentação MFRC522:** https://github.com/miguelbalboa/rfid
- **PlatformIO:** https://platformio.org/
- **Express.js:** https://expressjs.com/

---

**Última atualização:** 17 de Novembro de 2025
