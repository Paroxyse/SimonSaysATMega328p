;
;
; prfn.asm
;
; Created: 08/11/2022 10:22:27 a. m.
; Author : Particular
;

;
; Proyecto final SP AMDC MSDA RCKI.asm
;
; Created: 07/11/2022 09:51:17 p. m.
; Author : Space
;
.dseg               ;Data segment
.org 0x200          ;Start storing at 0x200
storage: .db 1,2,3,4,5,6    ;Allocate 1 byte for storage

.cseg  
.def L1 = r16
.def counter=r17
.def gvar=r21
.def del=r22
.def del2=r23
.def del3=r24
.def rvar=r25
.def cvar=r28
.def contadorluz=r29
.def LED1 = r19
.def LED2 = r20
.def LED3 = r26
.Def LED4 =r27
.def LED5 =r30

ldi r31,1
ldi gvar, 0b00011100
out ddrd,r21
ldi gvar, 0b00111111
out ddrc,r21
ldi gvar, 0b00001111
out ddrb,r21
eti_init:

  ldi gvar,0b00000100
  out portd, gvar
; Replace with your application code
start1:
  
  ldi gvar, 0b00111111
  out portc,gvar
  rcall del500
  ldi gvar,0
  out portc,gvar
  rcall del500
start:
ldi r16,0
out portb,r16
ldi r16,0b00010000
  snake_loop:
  rcall rd
  /*rcall del100*/
  mov gvar,r16
  out portc, gvar
// switching current ye  
  rcall mat
  rcall btnget
  btnstart:
  //button stuf
  
  in gvar, PIND
  andi gvar, 0b00100100
  cpi gvar, 0b00100100
  brne btstartfin

  miniloopstart:
  
  rcall rd
  in gvar, PIND
  andi gvar, 0b00100100
  cpi gvar, 0b00100100
  breq miniloopstart
//  

  rcall del100  
  rcall del100  

  //rcall randomled
  //rcall randomled


  ldi gvar, 0b00010000
  out portc, gvar
  rcall fillLEDRs
  ldi rvar,1
  gamebegin:
  out portb,rvar

  rcall LIGHTLEDS
  ldi counter,1
  rcall levels

  
  btstartfin:
 
    rjmp snake_loop
	hell:
	ldi r16,0b00100000
	out portc,r16
	rcall mat  
	rcall res
	rcall del100
	rjmp hell
	win:
	ldi r16,0b00110000
	out portc,r16
	rcall mat  
	rcall res
	rcall del100
	rcall del100
	rjmp win
Levels:
rcall lvl
cp cvar, LED1
brne hell
cp counter,rvar
breq LevelUP
inc counter

rcall lvl
cp cvar, LED2
brne hell
cp counter,rvar
breq LevelUP
inc counter

rcall lvl
cp cvar, LED3
brne hell
cp counter,rvar
breq LevelUP
inc counter

rcall lvl
cp cvar, LED4
brne hell
cp counter,rvar
breq LevelUP
inc counter

rcall lvl
cp cvar, LED5
brne hell
cp counter,rvar
breq LevelUP

ret

LevelUP:
inc rvar
cpi rvar,6
breq win//
ldi counter,1
rjmp GameBegin

lvl:
  rcall mat
  rcall btnget
  rcall res
  cpi cvar,0
  breq lvl
  ret


LIGHTLEDS:
rcall del50
ldi counter,1

out portc, LED1
rcall nextlight//Apaga led jiji
cp counter,rvar
breq LENDS
inc counter

out portc, LED2
rcall nextlight
cp counter,rvar
breq LENDS
inc counter

out portc, LED3
rcall nextlight
cp counter,rvar
breq LENDS
inc counter

out portc, LED4
rcall nextlight
cp counter,rvar
breq LENDS
inc counter

out portc, LED5
rcall nextlight
cp counter,rvar
breq LENDS


LENDS:
//rcall nextlight
ret

nextlight:
rcall del250
ldi gvar,0b00010000
out portc, gvar
rcall del250
ret

fillLEDRs:
  mov LED1,r31
				ori LED1,0b00010000
  rcall del50
  rcall rd
  mov LED2,r31
				ori LED2,0b00010000
  rcall del50
  rcall rd
  mov LED3,r31
				 ori LED3,0b00010000
  rcall del50
  rcall rd
  mov LED4,r31
				 ori LED4,0b00010000
  rcall del50
  mov LED5,r31
				ori LED5,0b00010000
  rcall del50
  ret
btnget:
//btn led1
ldi cvar,0
btl1:
in gvar,pind
andi gvar,0b00101000
cpi gvar, 0b00101000
brne btl2
bl1:
in gvar,pind
andi gvar,0b00101000
cpi gvar, 0b00101000
breq bl1

ldi cvar, 1
ori cvar,16
rjmp btngetend
/////
btl2:
in gvar,pind
andi gvar,0b00110000
cpi gvar, 0b00110000
brne btl3
bl2:
in gvar,pind
andi gvar,0b00110000
cpi gvar, 0b00110000
breq bl2
ldi cvar, 2
ori cvar,16
rjmp btngetend
////
btl3:
in gvar,pind
andi gvar,0b01001000
cpi gvar, 0b01001000
brne btl4
bl3:
in gvar,pind
andi gvar,0b01001000
cpi gvar, 0b01001000
breq bl3
ldi cvar, 4
ori cvar,16
rjmp btngetend
btl4:
in gvar,pind
andi gvar,0b01010000
cpi gvar, 0b01010000
brne btngetend
bl4:
in gvar,pind
andi gvar,0b01010000
cpi gvar, 0b01010000
breq bl4
ldi cvar, 8
ori cvar,16


btngetend:
rcall del50
ret
mat:
  in gvar, pind
  andi gvar, 0b00011100
  out portd, gvar

 /* in gvar, pind
  //andi gvar,0b00010000*/
  cpi gvar, 0b00010000
  breq switching

  lsl gvar
  out portd,gvar
  
  rjmp matend
///

  switching:
  ldi gvar, 0b00000100
  out portd, gvar
  matend:
  ret

  res:
  in gvar, PIND
  andi gvar, 0b01000100
  cpi gvar, 0b01000100
  brne resetEnd
  Reset:
  in gvar, PIND
  andi gvar, 0b01000100
  cpi gvar, 0b01000100
  breq reset

  /*ldi gvar, 0b00000000
  out portc,gvar*/
  rcall del100
  rjmp start1
  resetend:
  ret
randomled:
mov gvar, r31
  ori gvar, 0b00010000
  out portc, gvar
  rcall del100
  rcall del100
  rcall rd
  rcall rd
  rcall rd
  rcall rd
  rcall rd
  rcall rd
  rcall rd


  ldi gvar, 0b00010000
  out portc, gvar
  rcall del100
  rcall del100
  
ret
  
  //
del250:
LDI del,80
rjmp et3
del500:
LDI del, 160
rjmp et3
del50:
ldi del,16
rjmp et3
del100:
ldi del,32
et3:
LDI del2, 50
et2:
LDI del3, 250
et1:
NOP
; Itera 250 veces, emplea 4 uS por iteraci?n
DEC del3
; 250 x 4 uS = 1000 uS =1 mS
BRNE et1

DEC del2
BRNE et2
; 1 mS x 250 = 250 mS

DEC del
BRNE et3
; 250 mS x 2 = 500 mS
RET

rd:
  lsl r31
  cpi r31,0b0010000
  breq rdr
  
  ret
  rdr:
  ldi r31,1
  ret