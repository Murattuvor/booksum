// ─── Pin tanımları (PIC16F628A → Arduino eşleşmesi) ──────────────────────
// RA6  → D6  : Verici elektrota (5551 Hz kare dalga)
// RB7  → D7  : Alıcı sensör/elektrot girişi
// RB0  → D8  : Buzzer çıkışı (R2 → Q1 baz → Buzzer)

#define TX_PIN      6
#define RX_PIN      7
#define BUZZER_PIN  8

// ─── Parametreler ─────────────────────────────────────────────────────────
const uint16_t FREKANS = 5551;   // FREKANS VAR WORD = 5551
const uint8_t  SURE    = 15;     // 15ms pencere (FREQOUT ve COUNT süresi)
const uint8_t  ESIK    = 85;     // IF (BILGI >= 85)

int  bilgi = 0;                  // BILGI VAR BYTE
bool durum = false;              // DURUM VAR BYTE

// ─── COUNT komutu karşılığı: pin üzerindeki yükselen kenarları say ────────
int pulseCount(uint8_t pin, unsigned int ms) {
    int  count     = 0;
    bool lastState = LOW;
    unsigned long t = millis();
    while (millis() - t < ms) {
        bool state = digitalRead(pin);
        if (state == HIGH && lastState == LOW) count++;
        lastState = state;
    }
    return count;
}

void setup() {
    pinMode(TX_PIN,     OUTPUT);
    pinMode(RX_PIN,     INPUT);
    pinMode(BUZZER_PIN, OUTPUT);
    digitalWrite(TX_PIN,     LOW);
    digitalWrite(BUZZER_PIN, LOW);
}

// ─── BASLA: (ana döngü) ───────────────────────────────────────────────────
void loop() {

    // FREQOUT PORTA.6, 15, FREKANS
    tone(TX_PIN, FREKANS);
    delay(SURE);
    noTone(TX_PIN);

    // COUNT PORTB.7, 15, BILGI
    bilgi = pulseCount(RX_PIN, SURE);

    // IF (BILGI >= 85) THEN
    if (bilgi >= ESIK) {
        digitalWrite(BUZZER_PIN, HIGH);   // PORTB.0 = 1
        durum = true;                     // DURUM   = 1
    } else {
        digitalWrite(BUZZER_PIN, LOW);    // PORTB.0 = 0
        durum = false;                    // DURUM   = 0
    }

    // GOTO BASLA → loop() otomatik tekrar eder
}
