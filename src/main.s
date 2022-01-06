
.include "nesdefs.inc"
.include "macros.inc"
.export Main

.segment "CODE"
.proc Main
  jsr ResetPalettes ; setup palettes
  jsr writeText

  ;reset PPU address and scroll registers
  lda PPU_STATUS 	; reading PPUSTATUS
  lda #0
  sta PPU_ADDR
  sta PPU_ADDR	; PPU addr = $0000
  sta PPU_SCROLL
  sta PPU_SCROLL  ; PPU scroll = $0000

  ;Turning on NMI and rendering
	lda #%10010000
	sta PPU_CTRL	; PPUCTRL
	lda #%00011010	; show background
	sta PPU_MASK	; PPUMASK, controls rendering of sprites and backgrounds

  rts
.endproc

.proc writeText
  lda PPU_STATUS 
  lda #$21        ;set ppu to start of VRAM
  sta PPU_ADDR       
  lda #$09     
  sta PPU_ADDR 
	ldy #0		; set Y counter to 0
@loop:
	lda HelloMsg,y	; get next character
        beq :+	; is 0? exit loop
	sta PPU_DATA	; store+advance PPU
        iny		; next character
	bne @loop	; loop
: rts
.endproc

.proc ResetPalettes
; reset PPU address latch before addresswrite
  bit PPU_STATUS

  ; $3f00 - bgcolor, Background pallette
  lda #$3f
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldx #00

:
  lda example_palette, X
  sta PPU_DATA
  inx
  cpx #32
  bne :-
  rts
.endproc

.segment "RODATA"
example_palette:
  .byte $0F,$15,$26,$37 ; bg0 purple/pink
  .byte $0F,$01,$11,$21 ; bg1 blue
  .byte $0F,$09,$19,$29 ; bg2 green
  .byte $0F,$00,$10,$30 ; bg3 greyscale
  .byte $0F,$18,$28,$38 ; sp0 yellow
  .byte $0F,$14,$24,$34 ; sp1 purple
  .byte $0F,$1B,$2B,$3B ; sp2 teal
  .byte $0F,$12,$22,$32 ; sp3 marine

HelloMsg:
	.byte "Witaj Julia!"
  .byte 0		; zero terminator


; CHR-ROM contents
.segment "CHARS"
  .incbin "assets/jroatch.chr"
  .incbin "assets/jroatch.chr" ; included twice to fill all banks
