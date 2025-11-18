#!/usr/bin/env python3
"""
API de Exemplo em Flask para receber dados RFID

INSTALAÇÃO:
    pip install flask

EXECUÇÃO:
    python3 api_exemplo_flask.py
    
    ou
    
    chmod +x api_exemplo_flask.py
    ./api_exemplo_flask.py
"""

from flask import Flask, request, jsonify
from datetime import datetime
import json

app = Flask(__name__)

# Armazena últimas leituras (em produção, use banco de dados)
leituras_recentes = []

# ==================== CONFIGURAÇÕES ====================
PORT = 3000
DEBUG = True


# ==================== ROTAS ====================

@app.route('/')
def index():
    """Rota raiz - informações da API"""
    return jsonify({
        'message': 'API RFID - Sistema de Rastreamento de Objetos',
        'version': '1.0.0',
        'endpoints': {
            'status': 'GET /api/status',
            'rfid_post': 'POST /api/rfid',
            'rfid_list': 'GET /api/rfid',
            'rfid_stats': 'GET /api/rfid/stats'
        }
    })


@app.route('/api/status', methods=['GET'])
def status():
    """Verificar status da API"""
    return jsonify({
        'status': 'online',
        'service': 'RFID API Flask',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat(),
        'total_leituras': len(leituras_recentes)
    })


@app.route('/api/rfid', methods=['POST'])
def receive_rfid():
    """
    Recebe dados RFID dos leitores
    
    Espera JSON no formato:
    {
        "reader": "Leitor_1",
        "uid_hex": "7F:BE:A3:FB",
        "uid_decimal": 2143200251,
        "card_type": "MIFARE 1KB",
        "date": "2025-11-17",
        "time": "14:35:22",
        "datetime": "2025-11-17T14:35:22",
        "timestamp_ms": 1700234122000
    }
    """
    try:
        data = request.get_json()
        
        # Validação básica
        required_fields = ['reader', 'uid_hex', 'uid_decimal', 'card_type']
        for field in required_fields:
            if field not in data:
                return jsonify({
                    'success': False,
                    'error': f'Campo obrigatório ausente: {field}'
                }), 400
        
        # Log no console
        print('\n' + '='*60)
        print('🎫 RFID RECEBIDO VIA API')
        print('='*60)
        print(f"Leitor:         {data.get('reader')}")
        print(f"UID (Decimal):  {data.get('uid_decimal')}")
        print(f"UID (Hex):      {data.get('uid_hex')}")
        print(f"Tipo Cartão:    {data.get('card_type')}")
        print(f"Data/Hora:      {data.get('datetime')}")
        print(f"Timestamp:      {data.get('timestamp_ms')}")
        print('='*60 + '\n')
        
        # Armazena leitura (em produção, salve no banco de dados)
        leitura = {
            **data,
            'received_at': datetime.now().isoformat(),
            'processed': True
        }
        leituras_recentes.append(leitura)
        
        # Mantém apenas as últimas 100 leituras
        if len(leituras_recentes) > 100:
            leituras_recentes.pop(0)
        
        # ========================================
        # ADICIONE SUA LÓGICA AQUI:
        # ========================================
        
        # Exemplo 1: Verificar cartão específico
        if data['uid_hex'] == '7F:BE:A3:FB':
            print('⚠️  Cartão especial detectado!')
            # await send_notification('Cartão VIP detectado')
        
        # Exemplo 2: Controle de acesso
        # is_authorized = check_authorization(data['uid_hex'])
        # if not is_authorized:
        #     return jsonify({
        #         'success': False,
        #         'error': 'Cartão não autorizado'
        #     }), 403
        
        # Exemplo 3: Registrar por leitor
        # location = 'Entrada' if data['reader'] == 'Leitor_1' else 'Saída'
        # db.access_log.create({
        #     'uid': data['uid_hex'],
        #     'location': location,
        #     'timestamp': data['datetime']
        # })
        
        # Resposta de sucesso
        return jsonify({
            'success': True,
            'message': 'Dados RFID recebidos com sucesso',
            'received_data': {
                'reader': data['reader'],
                'uid_hex': data['uid_hex'],
                'uid_decimal': data['uid_decimal'],
                'card_type': data['card_type'],
                'datetime': data.get('datetime')
            }
        }), 200
        
    except Exception as e:
        print(f'❌ Erro ao processar RFID: {str(e)}')
        return jsonify({
            'success': False,
            'error': 'Erro ao processar dados',
            'details': str(e)
        }), 500


@app.route('/api/rfid', methods=['GET'])
def list_rfid():
    """Lista últimas leituras RFID"""
    limit = request.args.get('limit', 10, type=int)
    
    return jsonify({
        'success': True,
        'total': len(leituras_recentes),
        'limit': limit,
        'leituras': leituras_recentes[-limit:][::-1]  # Últimas N, em ordem reversa
    })


@app.route('/api/rfid/stats', methods=['GET'])
def rfid_stats():
    """Estatísticas das leituras"""
    if not leituras_recentes:
        return jsonify({
            'success': True,
            'message': 'Nenhuma leitura registrada ainda'
        })
    
    # Conta leituras por leitor
    stats_leitor = {}
    for leitura in leituras_recentes:
        leitor = leitura.get('reader', 'unknown')
        stats_leitor[leitor] = stats_leitor.get(leitor, 0) + 1
    
    # Conta leituras por tipo de cartão
    stats_tipo = {}
    for leitura in leituras_recentes:
        tipo = leitura.get('card_type', 'unknown')
        stats_tipo[tipo] = stats_tipo.get(tipo, 0) + 1
    
    return jsonify({
        'success': True,
        'total_leituras': len(leituras_recentes),
        'por_leitor': stats_leitor,
        'por_tipo_cartao': stats_tipo,
        'primeira_leitura': leituras_recentes[0].get('datetime'),
        'ultima_leitura': leituras_recentes[-1].get('datetime')
    })


# ==================== MIDDLEWARE ====================

@app.before_request
def log_request():
    """Log de todas as requisições"""
    print(f'[{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}] {request.method} {request.path}')


@app.errorhandler(404)
def not_found(error):
    """Tratamento de rota não encontrada"""
    return jsonify({
        'success': False,
        'error': 'Endpoint não encontrado',
        'message': 'Verifique a documentação da API'
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Tratamento de erro interno"""
    return jsonify({
        'success': False,
        'error': 'Erro interno do servidor',
        'message': str(error)
    }), 500


# ==================== INICIALIZAÇÃO ====================

if __name__ == '__main__':
    print('\n' + '='*60)
    print('🚀 API RFID Flask Iniciada!')
    print('='*60)
    print(f'📡 Servidor rodando em: http://localhost:{PORT}')
    print(f'🎯 Endpoint RFID:       POST http://localhost:{PORT}/api/rfid')
    print(f'✅ Status:              GET http://localhost:{PORT}/api/status')
    print(f'📊 Estatísticas:        GET http://localhost:{PORT}/api/rfid/stats')
    print('='*60 + '\n')
    print('💡 Aguardando dados dos leitores RFID...\n')
    
    app.run(
        host='0.0.0.0',  # Aceita conexões de qualquer IP
        port=PORT,
        debug=DEBUG
    )
