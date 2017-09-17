;
;  terrain
;
;  Created by Quinn Dunki on 7/29/17
;


TERRAINWIDTH = 640		; In pixels
MAXTERRAINHEIGHT = 100	; In pixels
COMPILEDTERRAINROW = TERRAINWIDTH/4+3	; In words, +2 to make room for clipping jump at end of row
VISIBLETERRAINWIDTH = TERRAINWIDTH/4	; In words- width minus jump return padding
VISIBLETERRAINWINDOW = 80				; In words

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; renderTerrain
;
; No stack operations permitted here!
;
; Current implementation: Unknown cycles per row
; Trashes all registers
;
renderTerrain:
	FASTGRAPHICS
	lda #MAXTERRAINHEIGHT
	sta SCRATCHL2		; Row counter
	lda #$9cff			; 4   Point stack to end of VRAM
	tcs					; 2

	sec
	lda #compiledTerrainEnd-VISIBLETERRAINWINDOW-3
	sbc mapScrollPos
	sta PARAML0

renderTerrainLoop:
	; Note that DP register is normally $0000, so that is used as the BG/BG case
	lda #$0011		; BG/FG
	ldx #$1111		; FG/FG
	ldy #$1100		; FG/BG
	jmp (PARAML0)

renderRowComplete:
	lda PARAML0
	sec
	sbc #COMPILEDTERRAINROW
	sta PARAML0
	dec SCRATCHL2
	bne renderTerrainLoop

	SLOWGRAPHICS
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; craterTerrain
;
; PARAML0 = X pos of center in pixels from logical left terrain edge
; PARAML1 = Y pos of center in pixels from bottom terrain edge
; Y = Radius of circle, in pixels
;
; Trashes SCRATCHL
craterTerrain:
	SAVE_AX

	lda #TERRAINWIDTH		; Convert X pos to terrain-right byte count
	sec
	sbc PARAML0
	sty SCRATCHL			; Center width in bytes
	sbc SCRATCHL
;	sbc SCRATCHL
	and #$fffe				; Force even
	clc
	adc #terrainData
	sta PARAML0

	lda circleTable,y		; Look up circle data
	sta SCRATCHL

	tya						; Iterate over diameter
	asl
	tay

craterTerrainLoop:
	dey
	dey
	bmi craterTerrainDone

	lda (SCRATCHL),y		; Fetch circle Y value
	clc
	adc PARAML1				; Convert to terrain-space
	sta SCRATCHL2
	lda (PARAML0),y
	cmp SCRATCHL2
	bmi craterTerrainLoop

	lda SCRATCHL2			; Circle value is lower, so use that
	sta (PARAML0),y
	bra craterTerrainLoop

craterTerrainDone:
	lda #1
	sta terrainDirty

	RESTORE_AX
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; clipTerrain
;
;
clipTerrain:
	SAVE_AXY

	sec
	lda #COMPILEDTERRAINROW*MAXTERRAINHEIGHT-3
	sbc mapScrollPos
	tay
	ldx #MAXTERRAINHEIGHT

clipTerrainLoop:
	clc		; Compute buffer to for saved data
	txa
	asl
	asl
	adc #clippedTerrainData-4
	sta PARAML0

	lda	compiledTerrain,y
	sta (PARAML0)	; Preserve data we're overwriting
	inc PARAML0
	inc PARAML0

	and #$ff00
	ora #$004c	; jmp in low byte
	sta compiledTerrain,y
	iny

	lda	compiledTerrain,y
	sta (PARAML0)	; Preserve data we're overwriting

	lda #renderRowComplete
	sta compiledTerrain,y

	tya
	sec
	sbc #COMPILEDTERRAINROW+1
	tay

	dex
	bne clipTerrainLoop

	RESTORE_AXY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unclipTerrain
;
;
unclipTerrain:
	SAVE_AXY

	sec
	lda #COMPILEDTERRAINROW*MAXTERRAINHEIGHT-3
	sbc mapScrollPos
	tay
	ldx #MAXTERRAINHEIGHT

unclipTerrainLoop:
	clc		; Compute buffer that saved data is in
	txa
	asl
	asl
	adc #clippedTerrainData-4
	sta PARAML0

	lda	(PARAML0)
	sta compiledTerrain,y
	inc PARAML0
	inc PARAML0
	iny

	lda	(PARAML0)
	sta compiledTerrain,y

	tya
	sec
	sbc #COMPILEDTERRAINROW+1
	tay

	dex
	bne unclipTerrainLoop

	RESTORE_AXY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; compileTerrain
;
;
;
compileTerrain:
	SAVE_AY

	ldy #MAXTERRAINHEIGHT-1
	lda #compiledTerrain
	sta PARAML0

compileTerrainLoop:
	sty PARAML1
	jsr compileTerrainRow
	dey
	bmi compileTerrainDone

	clc
	lda #COMPILEDTERRAINROW
	adc PARAML0
	sta PARAML0

	bra compileTerrainLoop

compileTerrainDone:
	RESTORE_AY
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; compileTerrainRow
;
; PARAML0 = Start of compiled row data
; PARAML1 = Row index
;
; Note: DA = PHX = FG/FG
;       48 = PHA = FG/BG
;		5A = PHY = BG/FG
;		0B = PHD = BG/BG

compileTerrainRow:
	SAVE_AXY
	ldy #0
	ldx #0

compileTerrainColumnLoop:
	stz compileTerrainOpcode

	; Check column 0
	lda terrainData,x
	cmp PARAML1
	bcc compileTerrainColumn0BG
	beq compileTerrainColumn0BG

	; Column 0 is FG, so check column 1
	inx
	inx
	lda terrainData,x
	cmp PARAML1
	bcc compileTerrainColumn1BG
	beq compileTerrainColumn1BG

	; Columns 0 and 1 are FG/FG, so PHX
	lda #$00da

compileTerrainColumn2:
	sta compileTerrainOpcode	; Cache results so far

	; Check column 2
	inx
	inx
	lda terrainData,x
	cmp PARAML1
	bcc compileTerrainColumn2BG
	beq compileTerrainColumn2BG

	; Column 2 is FG, so check column 3
	inx
	inx
	lda terrainData,x
	cmp PARAML1
	bcc compileTerrainColumn3BG
	beq compileTerrainColumn3BG

	; Columns 2 and 3 are FG/FG, so PHX
	lda compileTerrainOpcode
	ora #$da00

compileTerrainColumnStore:
	sta (PARAML0),y
	inx
	inx
	iny
	iny
	cpy #VISIBLETERRAINWIDTH
	bne compileTerrainColumnLoop

	RESTORE_AXY
	rts

compileTerrainColumn0BG:

	; Column 0 is BG, so check column 1
	inx
	inx
	lda terrainData,x
	cmp PARAML1
	bcc compileTerrainColumn01BG
	beq compileTerrainColumn01BG

	; Columns 0 and 1 are BG/FG, so PHA
	lda #$0048
	bra compileTerrainColumn2

compileTerrainColumn01BG:

	; Columns 0 and 1 are BG/BG, so PHD
	lda #$000b
	bra compileTerrainColumn2

compileTerrainColumn1BG:

	; Columns 0 and 1 are FG/BG, so PHY
	lda #$005a
	bra compileTerrainColumn2

compileTerrainColumn2BG:

	; Column 2 is BG, so check column 3
	inx
	inx
	lda terrainData,x
	cmp PARAML1
	bcc compileTerrainColumn23BG
	beq compileTerrainColumn23BG

	; Columns 2 and 3 are BG/FG, so PHA
	lda compileTerrainOpcode
	ora #$4800
	bra compileTerrainColumnStore

compileTerrainColumn23BG:

	; Columns 2 and 3 are BG, so PHD
	lda compileTerrainOpcode
	ora #$0b00
	bra compileTerrainColumnStore

compileTerrainColumn3BG:

	; Columns 2 and 3 are FG/BG, so PHY
	lda compileTerrainOpcode
	ora #$5a00
	bra compileTerrainColumnStore

compileTerrainOpcode:
	.word 0



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; generateTerrain
;
; Trashes everything
;

generateTerrain:
	ldy #0
	ldx #0
	lda #terrainData
	sta SCRATCHL

generateTerrainLoop:

	lda sineTable,x

	lsr
	lsr

	clc
	adc #30

	sta (SCRATCHL),y
	iny
	iny

	inx
	inx
	inx
	inx

	txa
	and #$03ff
	tax

	cpy #TERRAINWIDTH
	bne generateTerrainLoop

	lda #1
	sta terrainData
	lda #2
	sta compiledTerrain-4
	rts



; Terrain data, stored as height values 2 pixels wide (bytes)

terrainData:
	.repeat TERRAINWIDTH/2
	.word 0
	.endrepeat

compiledTerrain:
	.repeat COMPILEDTERRAINROW * MAXTERRAINHEIGHT
	.byte 0
	.endrepeat
compiledTerrainEnd:

clippedTerrainData:
	.repeat MAXTERRAINHEIGHT
	.byte 0,0,0,0	; xx,jmp,addr
	.endrepeat

