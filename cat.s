Spr_000:
	FASTGRAPHICS		; 16x16, 484 bytes, 710 cycles
	clc	
	tya		; Y = Sprite Target Screen Address (upper left corner)
	tcs		; New Stack address
	ldx	#$4444	; Pattern #1 : 4
	ldy	#$0444	; Pattern #2 : 2
	lda	#$4004	; Pattern #3 : 2
	tcd	
;--		
	lda	#$2633	; Line 0
	sta	$A5,S
	lda	$A3,S
	and	#$F000
	ora	#$0226
	sta	$A3,S
	sep	#$20	
	.a8
	lda	$03,S
	and	#$F0
	ora	#$03
	sta	$03,S
	lda	$06,S
	and	#$F0
	ora	#$03
	sta	$06,S
	lda	$A7,S
	and	#$0F
	ora	#$20
	sta	$A7,S
	rep	#$30	
	.a16
	tsc		; Line 2
	adc	#$0140
	tcs	
	sep	#$20	
	.a8
	lda	#$FF
	sta	$00,S
	sta	$A0,S
	lda	$07,S
	and	#$0F
	ora	#$20
	sta	$07,S
	lda	$A7,S
	and	#$0F
	ora	#$20
	sta	$A7,S
	rep	#$30	
	.a16
	tsc	
	adc	#$0006
	tcs	
	pea	$3533
	pea	$2425
	tsc		; Line 3
	adc	#$00A4
	tcs	
	sep	#$20	
	.a8
	lda	#$23
	sta	$9A,S
	lda	$A1,S
	and	#$0F
	ora	#$30
	sta	$A1,S
	rep	#$30	
	.a16
	pea	$3434
	pea	$4423
	tsc		; Line 4
	adc	#$00A4
	tcs	
	lda	$9C,S
	and	#$00F0
	ora	#$2303
	sta	$9C,S
	sep	#$20	
	.a8
	lda	#$24
	sta	$9A,S
	rep	#$30	
	.a16
	phx	
	pea	$4434
	tsc		; Line 5
	adc	#$00A5
	tcs	
	sep	#$20	
	.a8
	lda	#$24
	sta	$99,S
	lda	$A0,S
	and	#$0F
	ora	#$30
	sta	$A0,S
	rep	#$30	
	.a16
	pea	$2340
	phy	
	tsc		; Line 6
	adc	#$00A3
	tcs	
	phd	
	pea	$4433
	tsc		; Line 7
	adc	#$00A5
	tcs	
	sep	#$20	
	.a8
	lda	$99,S
	and	#$F0
	ora	#$03
	sta	$99,S
	rep	#$30	
	.a16
	pea	$236F
	pea	$F64F
	pea	$2233
	pea	$3324
	tsc		; Line 8
	adc	#$00A7
	tcs	
	lda	$9F,S
	and	#$0F00
	ora	#$3022
	sta	$9F,S
	sep	#$20	
	.a8
	lda	$9A,S
	and	#$F0
	ora	#$03
	sta	$9A,S
	rep	#$30	
	.a16
	pea	$F2FF
	pea	$2333
	pea	$3444
	tsc		; Line 9
	adc	#$00A4
	tcs	
	txa	
	sta	$9E,S
	lda	$9C,S
	and	#$00F0
	ora	#$4403
	sta	$9C,S
	lda	$A0,S
	and	#$0F00
	ora	#$F03F
	sta	$A0,S
	pea	$FF43
	phx	
	tsc		; Line 11
	adc	#$0140
	tcs	
	lda	#$4434
	sta	$02,S
	lda	#$2322
	sta	$A2,S
	lda	$00,S
	and	#$00F0
	ora	#$4403
	sta	$00,S
	lda	$04,S
	and	#$0F00
	ora	#$F043
	sta	$04,S
	lda	$A0,S
	and	#$00F0
	ora	#$4303
	sta	$A0,S
	lda	$A4,S
	and	#$0F00
	ora	#$3044
	sta	$A4,S
	tsc		; Line 13
	adc	#$0140
	tcs	
	lda	$00,S
	and	#$00F0
	ora	#$3204
	sta	$00,S
	lda	$03,S
	and	#$00F0
	ora	#$4203
	sta	$03,S
	lda	$A0,S
	and	#$00F0
	ora	#$3203
	sta	$A0,S
	lda	$A3,S
	and	#$00F0
	ora	#$3203
	sta	$A3,S
	sep	#$20	
	.a8
	lda	$05,S
	and	#$0F
	ora	#$30
	sta	$05,S
	rep	#$30	
	.a16
	tsc		; Line 15
	adc	#$0140
	tcs	
	lda	$00,S
	and	#$00F0
	ora	#$F30F
	sta	$00,S
	lda	$03,S
	and	#$00F0
	ora	#$F30F
	sta	$03,S
;--		
SLOWGRAPHICS		
	rts	
		
;------------------------------		
