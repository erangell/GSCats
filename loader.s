;
;  loader
;  A very simplistic code loader designed to manage
;  GS code under ProDOS 8 (if it's good enough for Will Harvey...)
;
;  Created by Quinn Dunki on 7/29/17
;

.include "equates.s"
.include "macros.s"

LOADBUFFER = $1000		; Clear of this loader code
BUFFERSIZE = $8200		; About max size we can fit between buffer and this loader code
MAINENTRY = $020000

.org $800

main:
	OP8		; We launch in emulation. Stay there for now

	; Open the main code file
	jsr PRODOS
	.byte $c8
	.addr fileOpenCode
	bne ioError

	; Load the code into bank 0
	jsr PRODOS
	.byte $ca
	.addr fileRead
	bne ioError

	; Close the file
	jsr PRODOS
	.byte $cc
	.addr fileClose

	NATIVE

	; Copy code into bank 2
	ldx fileReadLen
	lda #2
	jsr copyBytes

	EMULATION

	; Open the sprite bank file
	jsr PRODOS
	.byte $c8
	.addr fileOpenSprites
	bne ioError

	; Load the compiled sprites into bank 0
	jsr PRODOS
	.byte $ca
	.addr fileRead
	bne ioError

	; Close the file
	jsr PRODOS
	.byte $cc
	.addr fileClose

	NATIVE

	; Copy sprites into bank 3
	ldx fileReadLen
	lda #3
	jsr copyBytes

	; Set up a long jump into bank 2, and
	; a way for game code to get back here to exit
	; properly to ProDOS 8
	lda #returnToProDOS
	sta PRODOSRETURN
	jml MAINENTRY

returnToProDOS:
	SYNCDBR
	EMULATION
	rts

ioError:
	brk


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; copyBytes
; Copy data from read buffer in bank 0 to
; bottom of any other bank. Must be in native mode.
;
; X = Length of data in bytes
; A = Bank number of destination
;
copyBytes:
	phx
	BITS8
	sta copyBytesDest+3
	BITS16
	plx
	dex
	dex

copyBytesLoop:
	lda LOADBUFFER,x

copyBytesDest:
	sta $010000,x
	dex
	dex
	bpl copyBytesLoop
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fileOpenCode:
	.byte 3
	.addr codePath
	.addr $9200				; 1k below BASIC.SYSTEM
	.byte 0					; Result (file handle)
	.byte 0					; Padding

fileRead:
	.byte 4
	.byte 1					; File handle (we know it's gonna be 1)
	.addr LOADBUFFER
	.word BUFFERSIZE
fileReadLen:
	.word 0					; Result (bytes read)

fileClose:
	.byte 1
	.byte 1					; File handle (we know it's gonna be 1)

fileOpenSprites:
	.byte 3
	.addr spritePath
	.addr $9200				; 1k below BASIC.SYSTEM
	.byte 0					; Result (file handle)
	.byte 0					; Padding

codePath:
	pstring "/GSAPP/CODEBANK"
spritePath:
	pstring "/GSAPP/SPRITEBANK00"
