// Exemplo de API REST em Node.js/Express para receber dados RFID
// 
// INSTALAÇÃO:
// npm init -y
// npm install express body-parser
//
// EXECUÇÃO:
// node api_exemplo.js

const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Middleware para parsear JSON
app.use(bodyParser.json());

// Log de requisições
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// ==================== ROTAS ====================

// Rota POST para receber dados RFID
app.post('/api/rfid', (req, res) => {
  const {
    reader,
    uid_decimal,
    uid_hex,
    card_type,
    date,
    time,
    datetime,
    timestamp_ms,
    arduino_timestamp
  } = req.body;

  console.log('\n========================================');
  console.log('🎫 RFID RECEBIDO VIA API');
  console.log('========================================');
  console.log(`Leitor:         ${reader}`);
  console.log(`UID (Decimal):  ${uid_decimal}`);
  console.log(`UID (Hex):      ${uid_hex}`);
  console.log(`Tipo Cartão:    ${card_type}`);
  console.log(`Data/Hora:      ${datetime}`);
  console.log(`Timestamp:      ${timestamp_ms}`);
  console.log('========================================\n');

  // ========================================
  // AQUI VOCÊ PODE ADICIONAR SUA LÓGICA:
  // ========================================
  
  // Exemplo 1: Salvar no banco de dados
  // await database.rfid.create({ uid_hex, card_type, reader, timestamp: datetime });
  
  // Exemplo 2: Verificar se é um cartão autorizado
  // const isAuthorized = await checkAuthorization(uid_hex);
  // if (!isAuthorized) {
  //   return res.status(403).json({ error: 'Cartão não autorizado' });
  // }
  
  // Exemplo 3: Registrar acesso
  // await accessLog.create({
  //   reader_id: reader,
  //   card_uid: uid_hex,
  //   timestamp: datetime,
  //   location: reader === 'Leitor_1' ? 'Entrada' : 'Saída'
  // });
  
  // Exemplo 4: Webhook/notificação
  // if (uid_hex === '7F:BE:A3:FB') {
  //   await sendNotification('Cartão especial detectado!');
  // }

  // Resposta de sucesso
  res.status(200).json({
    success: true,
    message: 'Dados RFID recebidos com sucesso',
    received_data: {
      reader,
      uid_hex,
      uid_decimal,
      card_type,
      datetime
    }
  });
});

// Rota GET para verificar status da API
app.get('/api/status', (req, res) => {
  res.json({
    status: 'online',
    service: 'RFID API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Rota GET para listar leituras (exemplo - em produção viria do banco)
app.get('/api/rfid', (req, res) => {
  // Em produção, buscaria do banco de dados
  res.json({
    message: 'Use POST /api/rfid para enviar dados',
    example: {
      reader: 'Leitor_1',
      uid_hex: '7F:BE:A3:FB',
      uid_decimal: 2143200251,
      card_type: 'MIFARE 1KB',
      date: '2025-11-17',
      time: '14:30:00',
      datetime: '2025-11-17T14:30:00',
      timestamp_ms: 1700234400000
    }
  });
});

// Rota raiz
app.get('/', (req, res) => {
  res.json({
    message: 'API RFID - Sistema de Rastreamento de Objetos',
    endpoints: {
      status: 'GET /api/status',
      rfid_post: 'POST /api/rfid',
      rfid_get: 'GET /api/rfid'
    }
  });
});

// Tratamento de erros
app.use((err, req, res, next) => {
  console.error('Erro:', err);
  res.status(500).json({
    success: false,
    error: 'Erro interno do servidor',
    message: err.message
  });
});

// ==================== INICIALIZAÇÃO ====================

app.listen(PORT, () => {
  console.log('\n========================================');
  console.log('🚀 API RFID Iniciada!');
  console.log('========================================');
  console.log(`📡 Servidor rodando em: http://localhost:${PORT}`);
  console.log(`🎯 Endpoint RFID:       POST http://localhost:${PORT}/api/rfid`);
  console.log(`✅ Status:              GET http://localhost:${PORT}/api/status`);
  console.log('========================================\n');
  console.log('💡 Aguardando dados dos leitores RFID...\n');
});

// Tratamento de shutdown gracioso
process.on('SIGINT', () => {
  console.log('\n\n🛑 Encerrando servidor...');
  process.exit(0);
});
