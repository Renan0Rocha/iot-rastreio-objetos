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
  SPI.begin();
  mfrc522.PCD_Init();
  // mfrc522.PCD_SetAntennaGain(mfrc522.RxGain_max); // opcional

  Serial.println(F("\n=== Leitor RFID RC522 (UNO) ==="));
  Serial.println(F("Aproxime uma tag/cartao no sensor..."));
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
