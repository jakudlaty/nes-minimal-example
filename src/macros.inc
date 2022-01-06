
.macro VBLANK_WAIT
  : bit PPU_STATUS
  bpl :-
.endmacro

; WARNING - it clears also stack, do not run after any jsr because it will ruin you stack!
.macro CLEAR_MEMORY
: lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne :-
.endmacro