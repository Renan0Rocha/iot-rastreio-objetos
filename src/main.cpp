// Se estiver usando PlatformIO com main.cpp:
#include <Arduino.h>
#include <SPI.h>
#include <MFRC522.h>

/*
  Ligações RC522 (Arduino UNO):
  SDA/SS -> D10
  RST    -> D9
  MOSI   -> D11
  MISO   -> D12
  SCK    -> D13
  3.3V   -> 3.3V
  GND    -> GND
*/

constexpr uint8_t PIN_SS  = 10;  // SDA/SS
constexpr uint8_t PIN_RST = 9;   // RST

MFRC522 mfrc522(PIN_SS, PIN_RST);

// Função para testar comunicação básica
bool testRC522Communication() {
  // Reset manual do módulo
  digitalWrite(PIN_RST, LOW);
  delay(50);
  digitalWrite(PIN_RST, HIGH);
  delay(50);
  
  // Tenta ler o registrador várias vezes
  for (int i = 0; i < 5; i++) {
    byte version = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
    Serial.print(F("Tentativa "));
    Serial.print(i + 1);
    Serial.print(F(": Versao = 0x"));
    Serial.println(version, HEX);
    
    if (version != 0x00 && version != 0xFF) {
      return true;
    }
    delay(100);
  }
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
  
  Serial.println(F("\n=== Leitor RFID RC522 (UNO) - Teste de Diagnostico ==="));
  
  // Configura os pinos
  pinMode(PIN_RST, OUTPUT);
  pinMode(PIN_SS, OUTPUT);
  
  Serial.println(F("Configurando pinos..."));
  digitalWrite(PIN_RST, HIGH);
  digitalWrite(PIN_SS, HIGH);
  delay(100);
  
  Serial.println(F("Inicializando SPI..."));
  SPI.begin();
  delay(100);
  
  Serial.println(F("Inicializando MFRC522..."));
  mfrc522.PCD_Init();
  delay(100);
  
  Serial.println(F("\nTestando comunicacao com o modulo..."));
  
  if (testRC522Communication()) {
    byte version = mfrc522.PCD_ReadRegister(mfrc522.VersionReg);
    Serial.println(F("\n*** SUCESSO! ***"));
    Serial.print(F("Versao do Firmware MFRC522: 0x"));
    Serial.println(version, HEX);
    
    // Exibe informações sobre a versão
    if (version == 0x91 || version == 0x92) {
      Serial.println(F("Chip: MFRC522 v1.0 ou v2.0"));
    } else if (version == 0x12) {
      Serial.println(F("Chip: Counterfeit MFRC522"));
    } else {
      Serial.print(F("Chip: Versao desconhecida (0x"));
      Serial.print(version, HEX);
      Serial.println(F(")"));
    }
    
    Serial.println(F("MFRC522 inicializado com sucesso!"));
    
    // Aumenta o ganho da antena para melhor leitura
    mfrc522.PCD_SetAntennaGain(mfrc522.RxGain_max);
    Serial.println(F("Ganho da antena configurado para maximo"));
    
    Serial.println(F("\n*** Aproxime uma tag/cartao no sensor... ***\n"));
  } else {
    Serial.println(F("\n*** ERRO: Falha na comunicacao com o MFRC522! ***"));
    Serial.println(F("\nVerifique as conexoes:"));
    Serial.println(F("  Pino RC522  ->  Arduino"));
    Serial.println(F("  -----------------------"));
    Serial.println(F("  SDA/SS      ->  D10"));
    Serial.println(F("  SCK         ->  D13"));
    Serial.println(F("  MOSI        ->  D11"));
    Serial.println(F("  MISO        ->  D12"));
    Serial.println(F("  RST         ->  D9"));
    Serial.println(F("  3.3V        ->  3.3V"));
    Serial.println(F("  GND         ->  GND"));
    Serial.println(F("\nDicas:"));
    Serial.println(F("- Verifique se os jumpers estao bem conectados"));
    Serial.println(F("- O modulo deve estar alimentado com 3.3V (NAO 5V!)"));
    Serial.println(F("- Teste trocar os jumpers por outros"));
    Serial.println(F("- Verifique se o modulo nao esta com defeito"));
    while (true) { delay(1000); } // Trava o programa
  }
}

void loop() {
  // Se não há nova tag, apenas anima a linha e retorna
  if (!mfrc522.PICC_IsNewCardPresent()) {
    drawIdle();
    return;
  }
  if (!mfrc522.PICC_ReadCardSerial()) {
    drawIdle();
    return;
  }

  // Quebra a linha antes de imprimir os dados (pra não misturar com a animação)
  Serial.println();

  // Temos um UID válido
  String uidHex = uidToHex(mfrc522.uid);
  unsigned long uidDec = uidToDec32(mfrc522.uid);
  MFRC522::PICC_Type piccType = mfrc522.PICC_GetType(mfrc522.uid.sak);

  // Envia dados em formato JSON para o script Python
  Serial.print(F("{\"event\":\"rfid_read\",\"uid_decimal\":"));
  Serial.print(uidDec);
  Serial.print(F(",\"uid_hex\":\""));
  Serial.print(uidHex);
  Serial.print(F("\",\"card_type\":\""));
  Serial.print(mfrc522.PICC_GetTypeName(piccType));
  Serial.print(F("\",\"timestamp\":"));
  Serial.print(millis());
  Serial.println(F("}"));

  // Também exibe para o usuário (opcional)
  Serial.println(F("----- TAG DETECTADA -----"));
  Serial.print(F("UID (HEX): ")); Serial.println(uidHex);
  Serial.print(F("UID (DEC): ")); Serial.println(uidDec);
  Serial.print(F("Tipo PICC : ")); Serial.println(mfrc522.PICC_GetTypeName(piccType));
  Serial.println(F("-------------------------"));

  // Finaliza comunicação com a tag até ser removida
  mfrc522.PICC_HaltA();
  mfrc522.PCD_StopCrypto1();

  // Espera a tag sair do campo (anti-duplicação)
  delay(200);
  while (mfrc522.PICC_IsNewCardPresent() || mfrc522.PICC_ReadCardSerial()) {
    delay(50);
  }

  // Reseta a animação e volta a exibir a linha de espera
  animCount = 0;
  Serial.println(F("\nAproxime uma tag/cartao no sensor..."));
}
