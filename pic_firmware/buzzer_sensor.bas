@ __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _CP_ON & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF
DEFINE OSC 4
CMCON=7
OPTION_REG=%00000000

TRISA=%10111111     ' RA6=ÇIKIŞ(verici), RA5=MCLR giriş, diğerleri giriş
TRISB=%11111110     ' RB7=GİRİŞ(alıcı sensör), RB0=ÇIKIŞ(buzzer Q2)

BILGI VAR BYTE
BILGI=0

DURUM VAR BYTE

PORTA = 0
PORTB = 0

BASLA:
    FREQOUT PORTA.6, 15, 5551   ' RA6'dan 5551 Hz, 15ms gönder
    COUNT PORTB.7, 15, BILGI    ' RB7'de 15ms'deki darbeleri say

    DURUM = (BILGI = 85)        ' Eşleşirse DURUM=1, IF yok

    PORTB.0 = DURUM             ' RB0 → R5 → Q2 → Buzzer
GOTO BASLA
END
