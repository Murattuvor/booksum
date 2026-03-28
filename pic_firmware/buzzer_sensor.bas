@ __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _CP_ON & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF

DEFINE OSC 4

' Karşılaştırıcıları kapat, tüm pinler dijital I/O
CMCON = 7
OPTION_REG = %00000000

' TRISA:  RA7=1(giriş/OSC1), RA6=0(ÇIKIŞ/verici 5551Hz),
'         RA5=1(giriş/MCLR), RA4..RA0=1(giriş)
' NOT: _MCLRE_ON ile RA5 zaten MCLR olarak kullanılıyor, çıkış yapılamaz.
TRISA = %10111111

' TRISB:  RB7=1(GİRİŞ/alıcı sensör-elektrot pin13),
'         RB6..RB1=çıkış, RB0=0(ÇIKIŞ/buzzer Q2 kontrolü)
TRISB = %10000000

BILGI  VAR BYTE     ' RB7'den okunan darbe sayısı
BILGI  = 0
DURUM  VAR BYTE     ' Buzzer durum biti (0=kapalı, 1=açık)
DURUM  = 0

PORTA = 0
PORTB = 0

' ─────────────────────────────────────────────────────────────────────────────
' Devre bağlantıları (referans):
'   RA6   → Verici elektrota (5551 Hz kare dalga çıkışı)
'   RB7   → Alıcı sensör/elektrot (darbe girişi, pin 13)
'   RB0   → R5(10kΩ) → Q2(2N2222) baz → Q2 kolektör → Buzzer(−)
'            Buzzer(+) → L7805 çıkışı (5V)
' ─────────────────────────────────────────────────────────────────────────────

BASLA:
    ' 1) RA6'dan 15ms boyunca 5551 Hz kare dalga gönder (verici)
    FREQOUT PORTA.6, 15, 5551

    ' 2) RB7'de 15ms içinde alınan darbe sayısını ölç (alıcı)
    '    Yol açıkken  : ~83 darbe (5551 Hz × 0.015 s)
    '    Cisim varken : darbe sayısı 85'e ulaşır veya düşer
    COUNT PORTB.7, 15, BILGI

    ' 3) Karşılaştırma (IF kullanmadan):
    '    BILGI = 85 ise DURUM = 1 (algılama var), değilse DURUM = 0
    DURUM = (BILGI = 85)

    ' 4) Buzzer kontrolü: RB0 yüksek → R5 üzerinden Q2 iletir → Buzzer çalar
    PORTB.0 = DURUM

GOTO BASLA
END
