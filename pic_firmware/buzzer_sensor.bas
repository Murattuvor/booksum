@ __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _CP_ON & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF
DEFINE OSC 4
CMCON=7
OPTION_REG=%00000000

TRISA=%10111111     ' RA6=ÇIKIŞ(verici 5551Hz)  ← %10011111'den düzeltildi (RA5 MCLR)
TRISB=%11111110     ' RB7=GİRİŞ(sensör) RB0=ÇIKIŞ(buzzer) ← %01000000'den düzeltildi

BILGI VAR BYTE
BILGI=0

FREKANS VAR WORD
FREKANS=5551

DURUM VAR BYTE      ' ← eklendi

PORTA=0             ' ← eklendi
PORTB=0

BASLA:
    FREQOUT PORTA.6, 15, FREKANS    ' RA6 → 5551 Hz kare dalga, 15ms gönder
    COUNT PORTB.7, 15, BILGI        ' RB7'de 15ms'deki gelen darbeleri say

    DURUM = (BILGI = 85)            ' IF yok; 85 darbe gelirse DURUM=1

    PORTB.0 = DURUM                 ' RB0→R5→Q2 baz→Buzzer  ← PORTA.5'den düzeltildi
GOTO BASLA
END
