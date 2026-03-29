@ __config _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _CP_ON & _PWRTE_ON & _MCLRE_ON & _BODEN_OFF
DEFINE OSC 4
DEFINE INTHAND TIMER_ISR       ' ISR'yi interrupt vektörüne bağla

CMCON      = 7
OPTION_REG = %00001000         ' PSA=1: prescaler WDT'ye → TMR0 tick=1µs (1:1)
                               ' %00000000'den düzeltildi: 500000/FREKANS formülü
                               ' 1µs tick gerektirir, 2µs tick ile frekans yarıya düşer

TRISA = %10111111
TRISB = %01000000

WSAVE VAR BYTE $20 SYSTEM      ' ISR için W kayıt alanı
SSAVE VAR BYTE $21 SYSTEM      ' ISR için STATUS kayıt alanı

BILGI   VAR BYTE
BILGI   = 0
FREKANS VAR WORD
FREKANS = 5551
DURUM   VAR BYTE
DURUM   = 0
PRELOAD CON 166                ' Sabit: 256-(500000/5551)=166  ← runtime overflow önlendi
                               ' 90 tick × 1µs = 90µs toggle → 5555 Hz ≈ 5551 Hz

PORTA = 0
PORTB = 0

TMR0   = PRELOAD
INTCON = %10100000             ' GIE=1, T0IE=1

BASLA:
    COUNT   PORTB.7, 15, BILGI
    DURUM   = (BILGI > 80) * (BILGI < 90)  ' 5551Hz×0.015s=83 darbe, range daha güvenli
    PORTB.0 = DURUM
GOTO BASLA

ASM
TIMER_ISR:
    MOVWF   WSAVE           ; W kaydet
    SWAPF   STATUS, W
    CLRF    STATUS          ; Bank 0 seç
    MOVWF   SSAVE           ; STATUS kaydet

    MOVLW   .166            ; TMR0 yeniden yükle (PRELOAD)
    MOVWF   TMR0

    MOVLW   b'01000000'     ; RA6 toggle: BTG yerine XOR (BTG PIC18'e ait, PIC16'da yok)
    XORWF   PORTA, F

    BCF     INTCON, T0IF    ; Kesme bayrağını temizle

    SWAPF   SSAVE, W        ; STATUS geri yükle
    MOVWF   STATUS
    SWAPF   WSAVE, F
    SWAPF   WSAVE, W        ; W geri yükle
    RETFIE
ENDASM
END
