
.include "nesdefs.inc"
.include "macros.inc"
.import Main

.segment "HEADER"
  .byte "NES", $1A  ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $00, $00            ; mapper 0, vertical mirroring

; # Hardware Vectors at End of 2nd 8K ROM, processor will jump to reset coroutine after reset / power on
.segment "VECTORS"
  .addr nmi
  .addr reset
  .addr 0

;first segment of the PRG-ROM
.segment "STARTUP"

; ACTUAL EXECUTION STARTS HERE!
.proc reset
  sei ;ignore IRQ
  cld ;Disable decimal mode - now available in NES

  ; disable APU frame IRQ  
  ldx #%01000000
  stx APU_FRAME

  ; Setup stack
  ldx #$ff
  txs

  ldx #$0
  stx PPU_CTRL      ; disable NMI
  stx PPU_MASK      ; disable rendering
  stx APU_DMC_CTRL  ; disable DMC IRQs

  ; now we have wait 2 vblanks for PPU initialization, we will clear memory in meantime
  VBLANK_WAIT
  CLEAR_MEMORY      ; clear RAM
  VBLANK_WAIT
  
  jsr clearPPU      ; clear nametables
main:
  jsr Main
endlessLoop:
  jmp endlessLoop
.endproc

.proc nmi
  bit PPU_STATUS
  lda #0
  sta PPU_ADDR
  sta PPU_ADDR
  rti
.endproc

.segment "CODE"
.proc clearPPU
  lda PPU_STATUS 	; reading PPUSTATUS (reset address latch)
  lda #$20	    ; writing 0x2000 in PPUADDR to write on PPU, the address for nametable 0
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  ldx #0
  ldy #0
@nametable_loop:
	lda #$00
	sta PPU_DATA
	iny
	cpy #$00
	bne @nametable_loop
	inx
	cpx #$04	; size of nametable 0: 0x0400
	bne @nametable_loop
  rts
.endproc

