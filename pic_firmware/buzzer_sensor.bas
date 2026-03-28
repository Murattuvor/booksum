' ============================================================
' Devre: PIC16F628A + L7805 + Q2(2N2222) + Buzzer
' ------------------------------------------------------------
' Pin 15 RA6        → Verici elektrota (5551 Hz kare dalga)
' Pin 13 RB7        → Alıcı sensör/elektrot girişi
' Pin  6 RB0 → R5(10k) → Q2 baz → Q2 col → Buzzer(−)
'                          Buzzer(+) → L7805 çıkışı (5V)
' Pin  5 VSS        → GND → Q2 emiter
' Pin  4 RA5/MCLR   → R4(10k) → VDD  (donanım reset için)
' Pin 14 VDD        → 5V (L7805 çıkışı)
' ============================================================

@ __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _CP_ON & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF

DEFINE OSC 4

' Karşılaştırıcılar kapalı → RA0..RA3 ve RB0..RB3 dijital I/O
CMCON = 7

' OPTION_REG: PORTB pull-up'ları aktif (bit7=0), TMR0 dahili, prescaler 1:2
OPTION_REG = %00000000

' TRISA:
'   Bit 7 = 1  RA7/OSC1  → Giriş (dahili osilator kullanıyor)
'   Bit 6 = 0  RA6       → ÇIKIŞ (5551 Hz verici kare dalga)
'   Bit 5 = 1  RA5/MCLR  → Giriş (MCLRE_ON ile MCLR pini, değiştirilemez)
'   Bit 4 = 1  RA4       → Giriş
'   Bit 3 = 1  RA3       → Giriş
'   Bit 2 = 1  RA2       → Giriş
'   Bit 1 = 1  RA1       → Giriş
'   Bit 0 = 1  RA0       → Giriş
TRISA = %10111111

' TRISB:
'   Bit 7 = 1  RB7 → GİRİŞ  (alıcı sensör/elektrot, pin 13)
'   Bit 6 = 1  RB6 → Giriş  (kullanılmıyor)
'   Bit 5 = 1  RB5 → Giriş  (kullanılmıyor)
'   Bit 4 = 1  RB4 → Giriş  (kullanılmıyor)
'   Bit 3 = 1  RB3 → Giriş  (kullanılmıyor)
'   Bit 2 = 1  RB2 → Giriş  (kullanılmıyor)
'   Bit 1 = 1  RB1 → Giriş  (kullanılmıyor)
'   Bit 0 = 0  RB0 → ÇIKIŞ (Q2 baz kontrolü → Buzzer)
TRISB = %11111110

' Değişkenler
BILGI VAR BYTE   ' RB7'den 15ms'de sayılan darbe adedi
DURUM VAR BYTE   ' 1 = algılama var → buzzer çal, 0 = yok → sessiz

' Başlangıçta tüm çıkışlar sıfır
PORTA = 0
PORTB = 0

' ============================================================
' ANA DÖNGÜ
' ============================================================
BASLA:

    ' 1) RA6'dan 15ms süreyle 5551 Hz kare dalga gönder (verici)
    FREQOUT PORTA.6, 15, 5551

    ' 2) RB7'de 15ms içinde gelen darbeleri say (alıcı)
    '    Yol açıkken   → ~83 darbe  (5551 Hz × 0.015 s ≈ 83)
    '    Cisim varken  → darbe sayısı değişir (artabilir veya azalabilir)
    COUNT PORTB.7, 15, BILGI

    ' 3) Karşılaştırma (IF kullanmadan):
    '    Sayı tam 85 ise DURUM=1 (algılama), değilse DURUM=0
    DURUM = (BILGI = 85)

    ' 4) Buzzer kontrolü:
    '    PORTB.0 = 1 → RB0 yüksek → R5 → Q2 bazdan akım → Q2 iletir → Buzzer çalar
    '    PORTB.0 = 0 → RB0 alçak  → Q2 kesimlerde → Buzzer sessiz
    PORTB.0 = DURUM

GOTO BASLA
END
