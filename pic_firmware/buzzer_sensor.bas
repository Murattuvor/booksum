@ __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _CP_ON & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF
DEFINE OSC 4
CMCON=7
OPTION_REG=%00000000

TRISA=%10111111
TRISB=%11111110     ' %01000000 → RB7=GİRİŞ(sensör), RB0=ÇIKIŞ(buzzer)

BILGI VAR BYTE
BILGI=0

FREKANS VAR WORD
FREKANS=000000000000000000000000005551

DURUM VAR BYTE      ' eklendi

PORTA=0             ' eklendi
PORTB=0

BASLA:
    FREQOUT PORTA.6, 15, FREKANS    ' IF bloğu yerine: RA6'dan 5551Hz, 15ms gönder
    COUNT PORTB.7, 15, BILGI        '                  RB7'deki darbeleri say
    DURUM = (BILGI = 85)            '                  85 darbe = algılama (IF yok)
    PORTB.0 = DURUM                 ' PORTA.5 yerine: RB0 → R5 → Q2 → Buzzer
GOTO BASLA
END
