// Se estiver usando PlatformIO com main.cpp:
#include <Arduino.h>
#include <SPI.h>
#include <MFRC522.h>

/*
  Ligações RC522 (Arduino UNO) - DOIS LEITORES:
  
  Pinos compartilhados (barramento SPI):
  MOSI   -> D11 (ambos leitores)
  MISO   -> D12 (ambos leitores)
  SCK    -> D13 (ambos leitores)
  3.3V   -> 3.3V (ambos leitores)
  GND    -> GND (ambos leitores)
  
  Pinos individuais:
  Leitor 1 - SDA/SS -> D10, RST -> D9
  Leitor 2 - SDA/SS -> D8,  RST -> D7
*/

// Leitor 1
constexpr uint8_t PIN_SS1  = 10;
constexpr uint8_t PIN_RST1 = 9;

// Leitor 2
constexpr uint8_t PIN_SS2  = 8;
constexpr uint8_t PIN_RST2 = 7;

MFRC522 mfrc522_1(PIN_SS1, PIN_RST1);
MFRC522 mfrc522_2(PIN_SS2, PIN_RST2);

// Função para testar comunicação básica de um leitor
bool testRC522Communication(MFRC522 &reader, uint8_t ssPin, uint8_t rstPin, const char* readerName) {
  Serial.print(F("\nTestando "));
  Serial.print(readerName);
  Serial.println(F("..."));
  
  // Desabilita TODOS os outros SS primeiro
  digitalWrite(PIN_SS1, HIGH);
  digitalWrite(PIN_SS2, HIGH);
  delay(10);
  
  // Reset manual do módulo
  digitalWrite(rstPin, LOW);
  delay(100);
  digitalWrite(rstPin, HIGH);
  delay(100);
  
  // Habilita apenas este leitor
  digitalWrite(ssPin, LOW);
  delay(50);
  
  // Tenta ler o registrador várias vezes
  for (int i = 0; i < 5; i++) {
    byte version = reader.PCD_ReadRegister(reader.VersionReg);
    Serial.print(F("  Tentativa "));
    Serial.print(i + 1);
    Serial.print(F(": Versao = 0x"));
    Serial.println(version, HEX);
    
    if (version != 0x00 && version != 0xFF) {
      // Desabilita o leitor novamente
      digitalWrite(ssPin, HIGH);
      
      Serial.print(F("  *** "));
      Serial.print(readerName);
      Serial.println(F(" OK! ***"));
      
      if (version == 0x91 || version == 0x92) {
        Serial.println(F("  Chip: MFRC522 v1.0 ou v2.0"));
      } else if (version == 0x12) {
        Serial.println(F("  Chip: Counterfeit MFRC522"));
      } else {
        Serial.print(F("  Chip: Versao desconhecida (0x"));
        Serial.print(version, HEX);
        Serial.println(F(")"));
      }
      return true;
    }
    delay(100);
  }
  
  digitalWrite(ssPin, HIGH);
  
  Serial.print(F("  *** ERRO: "));
  Serial.print(readerName);
  Serial.println(F(" nao responde! ***"));
  return false;
}

// --------- Helpers UID ----------
String uidToHex(const MFRC522::Uid &uid) {
  String s;
  for (byte i = 0; i < uid.size; i++) {
    if (uid.uidByte[i] < 0x10) s += "0";
    s += String(uid.uidByte[i], HEX);
    if (i < uid.size - 1) s += ":";
  }
  s.toUpperCase();
  return s;
}

unsigned long uidToDec32(const MFRC522::Uid &uid) {
  if (uid.size <= 4) {
    unsigned long v = 0;
    for (byte i = 0; i < uid.size; i++) v = (v << 8) | uid.uidByte[i];
    return v;
  }
  uint32_t h = 2166136261u; // FNV-1a
  for (byte i = 0; i < uid.size; i++) { h ^= uid.uidByte[i]; h *= 16777619u; }
  return h;
}

// --------- Animação de espera ----------
unsigned long lastAnim = 0;
int animCount = 0;
const int animMax = 24;    // tamanho máximo da barra
const uint16_t animMs = 120;

void drawIdle() {
  if (millis() - lastAnim >= animMs) {
    lastAnim = millis();
    animCount = (animCount + 1) % (animMax + 1);

    // Monta a barra com 'animCount' sinais de '='
    String bar;
    for (int i = 0; i < animCount; i++) bar += "=";

    // \r volta o cursor pro início da mesma linha (sem pular)
    Serial.print("\rAguardando tag: ");
    Serial.print(bar);

    // Preenche espaço até o tamanho máximo para apagar sobras
    for (int i = animCount; i < animMax; i++) Serial.print(' ');
  }
}

void setup() {
  Serial.begin(115200);
  while (!Serial) { delay(10); } // Aguarda serial estar pronta
  
  Serial.println(F("\n=== Leitor RFID RC522 (UNO) - DOIS LEITORES ==="));
  
  // Configura os pinos dos DOIS leitores
  pinMode(PIN_RST1, OUTPUT);
  pinMode(PIN_SS1, OUTPUT);
  pinMode(PIN_RST2, OUTPUT);
  pinMode(PIN_SS2, OUTPUT);
  
  Serial.println(F("Configurando pinos..."));
  
  // MUITO IMPORTANTE: Fazer hard reset em ambos os módulos primeiro
  digitalWrite(PIN_RST1, LOW);
  digitalWrite(PIN_RST2, LOW);
  delay(100);
  
  // SS deve estar HIGH (desabilitado) ANTES de ativar os módulos
  digitalWrite(PIN_SS1, HIGH);
  digitalWrite(PIN_SS2, HIGH);
  delay(50);
  
  // Agora ativa os módulos (RST HIGH)
  digitalWrite(PIN_RST1, HIGH);
  digitalWrite(PIN_RST2, HIGH);
  delay(100);
  
  Serial.println(F("Inicializando SPI..."));
  SPI.begin();
  delay(100);
  
  Serial.println(F("Inicializando leitores MFRC522..."));
  
  // Desabilita ambos os SS antes de inicializar
  digitalWrite(PIN_SS1, HIGH);
  digitalWrite(PIN_SS2, HIGH);
  delay(10);
  
  // Inicializa o leitor 1
  digitalWrite(PIN_SS1, LOW);
  delay(10);
  mfrc522_1.PCD_Init();
  delay(50);
  digitalWrite(PIN_SS1, HIGH);
  delay(50);
  
  // Inicializa o leitor 2
  digitalWrite(PIN_SS2, LOW);
  delay(10);
  mfrc522_2.PCD_Init();
  delay(50);
  digitalWrite(PIN_SS2, HIGH);
  delay(50);
  
  Serial.println(F("\nTestando comunicacao com os modulos..."));
  
  bool reader1OK = testRC522Communication(mfrc522_1, PIN_SS1, PIN_RST1, "Leitor 1 (SS=D10, RST=D9)");
  bool reader2OK = testRC522Communication(mfrc522_2, PIN_SS2, PIN_RST2, "Leitor 2 (SS=D8, RST=D7)");
  
  if (reader1OK && reader2OK) {
    Serial.println(F("\n*** SUCESSO! Ambos leitores funcionando! ***"));
    
    // Aumenta o ganho da antena para melhor leitura
    digitalWrite(PIN_SS1, LOW);
    delay(5);
    mfrc522_1.PCD_SetAntennaGain(mfrc522_1.RxGain_max);
    digitalWrite(PIN_SS1, HIGH);
    delay(5);
    
    digitalWrite(PIN_SS2, LOW);
    delay(5);
    mfrc522_2.PCD_SetAntennaGain(mfrc522_2.RxGain_max);
    digitalWrite(PIN_SS2, HIGH);
    
    Serial.println(F("Ganho das antenas configurado para maximo"));
    
    Serial.println(F("\n*** Aproxime tags/cartoes nos sensores... ***\n"));
  } else {
    Serial.println(F("\n*** ERRO: Um ou ambos leitores falharam! ***"));
    Serial.println(F("\nVerifique as conexoes:"));
    Serial.println(F("  Pino RC522  ->  Arduino (AMBOS)"));
    Serial.println(F("  ----------------------------------"));
    Serial.println(F("  MOSI        ->  D11"));
    Serial.println(F("  MISO        ->  D12"));
    Serial.println(F("  SCK         ->  D13"));
    Serial.println(F("  3.3V        ->  3.3V"));
    Serial.println(F("  GND         ->  GND"));
    Serial.println(F(""));
    Serial.println(F("  Pinos individuais:"));
    Serial.println(F("  Leitor 1 SDA/SS  ->  D10"));
    Serial.println(F("  Leitor 1 RST     ->  D9"));
    Serial.println(F("  Leitor 2 SDA/SS  ->  D8"));
    Serial.println(F("  Leitor 2 RST     ->  D7"));
    Serial.println(F("\nDicas:"));
    Serial.println(F("- Verifique se os jumpers estao bem conectados"));
    Serial.println(F("- O modulo deve estar alimentado com 3.3V (NAO 5V!)"));
    Serial.println(F("- Cada leitor deve ter seu proprio pino SS/CS e RST"));
    Serial.println(F("- Verifique se nao ha curto-circuito entre os pinos SS"));
    
    if (!reader1OK && !reader2OK) {
      Serial.println(F("- Nenhum leitor respondeu: verifique alimentacao e SPI"));
    }
    
    // Não trava - permite leitura parcial se um funcionar
  }
}

// Função auxiliar para processar leitura de um leitor
bool processReader(MFRC522 &reader, uint8_t ssPin, const char* readerName) {
  // Desabilita TODOS os leitores primeiro
  digitalWrite(PIN_SS1, HIGH);
  digitalWrite(PIN_SS2, HIGH);
  delayMicroseconds(10);
  
  // Habilita apenas este leitor
  digitalWrite(ssPin, LOW);
  delayMicroseconds(10);
  
  if (!reader.PICC_IsNewCardPresent()) {
    digitalWrite(ssPin, HIGH);  // Desabilita novamente
    return false;
  }
  if (!reader.PICC_ReadCardSerial()) {
    digitalWrite(ssPin, HIGH);  // Desabilita novamente
    return false;
  }

  // Quebra a linha antes de imprimir os dados (pra não misturar com a animação)
  Serial.println();

  // Temos um UID válido
  String uidHex = uidToHex(reader.uid);
  unsigned long uidDec = uidToDec32(reader.uid);
  MFRC522::PICC_Type piccType = reader.PICC_GetType(reader.uid.sak);

  // Envia dados em formato JSON para o script Python
  Serial.print(F("{\"event\":\"rfid_read\",\"reader\":\""));
  Serial.print(readerName);
  Serial.print(F("\",\"uid_decimal\":"));
  Serial.print(uidDec);
  Serial.print(F(",\"uid_hex\":\""));
  Serial.print(uidHex);
  Serial.print(F("\",\"card_type\":\""));
  Serial.print(reader.PICC_GetTypeName(piccType));
  Serial.print(F("\",\"timestamp\":"));
  Serial.print(millis());
  Serial.println(F("}"));

  // Também exibe para o usuário (opcional)
  Serial.println(F("----- TAG DETECTADA -----"));
  Serial.print(F("Leitor: ")); Serial.println(readerName);
  Serial.print(F("UID (HEX): ")); Serial.println(uidHex);
  Serial.print(F("UID (DEC): ")); Serial.println(uidDec);
  Serial.print(F("Tipo PICC : ")); Serial.println(reader.PICC_GetTypeName(piccType));
  Serial.println(F("-------------------------"));

  // Finaliza comunicação com a tag até ser removida
  reader.PICC_HaltA();
  reader.PCD_StopCrypto1();
  
  // Desabilita o leitor
  digitalWrite(ssPin, HIGH);

  return true;
}

void loop() {
  // Tenta ler do Leitor 1
  bool read1 = processReader(mfrc522_1, PIN_SS1, "Leitor_1");
  
  // Tenta ler do Leitor 2
  bool read2 = processReader(mfrc522_2, PIN_SS2, "Leitor_2");
  
  // Se algum leitor detectou tag, aguarda anti-duplicação
  if (read1 || read2) {
    delay(200);
    // Limpa possíveis leituras pendentes
    while (mfrc522_1.PICC_IsNewCardPresent() || mfrc522_1.PICC_ReadCardSerial()) {
      delay(50);
    }
    while (mfrc522_2.PICC_IsNewCardPresent() || mfrc522_2.PICC_ReadCardSerial()) {
      delay(50);
    }
    
    // Reseta a animação e volta a exibir a linha de espera
    animCount = 0;
    Serial.println(F("\nAproxime tags/cartoes nos sensores..."));
  } else {
    // Se nenhum detectou, anima a linha de espera
    drawIdle();
  }
}
