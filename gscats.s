;
;  gscats
;
;  Created by Quinn Dunki on 7/9/17
;


.include "macros.s"
.include "equates.s"

.import renderTerrainSpans
.import unrenderTerrainSpans
.import compileTerrainSpans

.org $0000


mainBank2:
	SYNCDBR
	BITS8
	lda #$f0
	sta TEXTCOLOR
	BITS16

	; Set up video
	jsr initSCBs
	SHRVIDEO
	SHADOWMEMORY

	jmp beginGameplay

quitGame:
	NORMALMEMORY
	CLASSICVIDEO
	jml (PRODOSRETURN)


.include "random.s"
.include "graphics.s"
.include "font.s"
.include "smallNumbers.s"
.include "player.s"
.include "terrain.s"
.include "collision.s"
.include "gameobject.s"
.include "utility.s"
.include "tables.s"
.include "gamemanager.s"
.include "input.s"
.include "fan.s"
.include "projectile.s"
.include "inventory.s"
.include "dirt.s"
endMainBank2:


; Suppress some linker warnings - Must be the last thing in the file
; This is because Quinn doesn't really know how to use ca65 properly
.SEGMENT "ZPSAVE"
.SEGMENT "EXEHDR"
.SEGMENT "STARTUP"
.SEGMENT "INIT"
.SEGMENT "LOWCODE"
