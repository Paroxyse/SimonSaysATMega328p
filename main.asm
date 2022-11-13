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

ldi r31,1 //Se inicializa r31 para funcionamiento correcto de la funcion rd
//se inicializan los puertos con sus respectivas entradas y salidas
ldi gvar, 0b00011100
out ddrd,r21
ldi gvar, 0b00111111
out ddrc,r21
ldi gvar, 0b00011111
out ddrb,r21

eti_init:
//se inicializa PD2 para poder realizar la detección de pulsaciones de forma matricial

  ldi gvar,0b00000100
  out portd, gvar
; Replace with your application code
start1:
  //secuencia de inicio
  //Se prenden todos los LEDS y se realiza un rápido parpadeo
  ldi gvar, 0b00111111
  out portc,gvar
  rcall del500
  ldi gvar,0
  out portc,gvar
  rcall del500
  //Fin de secuencia de inicio//
start:
//Se carga 0 a r16 y se despliega el valor en la pantalla de 7 seg
ldi r16,0
out portb,r16

ldi r16,0b00010000

  snake_loop:
  rcall rd
  mov gvar,r16
  out portc, gvar
// Se inicia la detección de botones
  rcall mat
  rcall btnget
  btnstart:
//Se revisa si se está presionando el botón de inicio
  in gvar, PIND
  andi gvar, 0b00100100
  cpi gvar, 0b00100100
  brne btstartfin
//Mientras está presionado el botón de inicio, se cicla
  miniloopstart:
  rcall rd
  in gvar, PIND
  andi gvar, 0b00100100
  cpi gvar, 0b00100100
  breq miniloopstart
//  
  rcall del100  
  rcall del100  
//Se prende el led de inicio
  ldi gvar, 0b00010000
  out portc, gvar
//Se llenan los registros con los valores de los LEDs que se encenderán
  rcall fillLEDRs
  ldi rvar,1 //Se carga el valor de 1 a rvar(contador de nivel)
  gamebegin:
  //Se muestra el valor del nivel en el que se está
  out portb,rvar
  //Se prenden los LEDs de la secuencia
  rcall LIGHTLEDS
  //Se carga el valor de 1 al contador de ronda actual contador =ronda dentro del nivel /rvar = nivel
  ldi counter,1
  //Se llama el método levels, que detecta pulsaciones y las compara con el registro correspondiente a la ronda actual
  rcall levels
  
  btstartfin:
	
    rjmp snake_loop
	hell: //Este es el ciclo en el que se queda atorado el código si se pierde
	//Se prende el botón de reset y se cicla esperando un reinicio manual
	ldi r16,0b00100000
	out portc,r16
	rcall mat  
	rcall res

	rcall Recibir
	rjmp hell
	win:  //Este es el ciclo en el que se queda atorado el código si se gana
	//Se prenden los botones de reset e inicio y se cicla esperando un reinicio manual
	ldi r16,0b00110000
	out portc,r16
	rcall mat  
	rcall res
	rcall Transmitir
	rcall del100
	rcall del100
	rjmp win


Levels:
//Se llama método de detección de botones lvl
rcall lvl
//Se compara el valor del botón pulsado con el del registro correspondiente a la ronda actual de LED1 a LED5
cp cvar, LED1
brne hell
cp counter,rvar
breq LevelUP
//En caso de que el contador sea igual al número del nivel, se sube de nivel, en caso de no haber ganado, reinicia el contador
//En caso de haber ganado, salta al ciclo win
inc counter
//Esta comparación se repite para cada uno de los registros
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
//En caso de que el contador sea igual al número del nivel, se sube de nivel, en caso de no haber ganado, reinicia el contador
//En caso de haber ganado, salta al ciclo win
inc rvar
cpi rvar,6
breq win//
ldi counter,1
rjmp GameBegin

lvl:
//Esta rutina llama a mat y a btn get para la detección de botones y a res en caso de que se quiera reiniciar el juego
//se cicla hasta que el usuario presione un botón
  rcall mat
  rcall btnget
  rcall res
  cpi cvar,0
  breq lvl
  ret
Transmitir:
//Detectar botón
//salto en falso
//ciclo botón
rcall SerialInit
ldi r18,'A'
rcall SerialTransmit
Tret:
ret

Recibir:
rcall SerialInit
_Recibir:
lds gvar, UCSR0A
sbrs gvar, RXC0
rjmp _Recibir
lds r18, UDR0
cpi r18, 'A'
breq RecibirLED
ldi r18,0
ret
RecibirLED:
ldi gvar,pinb
ori gvar, 0b00010000
out portb,gvar
rcall del100
ldi gvar,pinb
andi gvar, 0b11101111
out portb,gvar
rcall del100
ret
/*SerialReceive:
lds gvar, UCSR0A
sbrs gvar, RXC0
rjmp SerialReceive
lds r18, UDR0
ret*/

SerialTransmit:
lds gvar,UCSR0A
sbrs gvar, UDRE0
rjmp SerialTransmit
sts UDR0,r18
ret

SerialInit:
ldi gvar, 103
clr r18
sts UBRR0H, r18
sts UBRR0L, gvar

ldi gvar, (1<<RXEN0) | (1<<TXEN0)
sts UCSR0A,gvar
ldi gvar, (1<<RXEN0) | (1<<TXEN0)
sts UCSR0B,gvar

ldi gvar, 0b00001110
sts UCSR0C, gvar
ret

LIGHTLEDS:
rcall del50
ldi counter,1 //carga el valor de 1 al contador para que se desplieguen solamente los LEDs que deben (los menores o iguales al número de nivel)

out portc, LED1 //Despliega el valor del pin asociado al LED almacenado en LED1 (de igual manera para los posteriores)
rcall nextlight//Apaga led y deja encendido el LED de inicio
cp counter,rvar //Si el contador es igual al nivel, termina.
breq LENDS
inc counter //Incrementa contador

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
//Apaga los LEDs y deja encendido el de Inicio
rcall del250
ldi gvar,0b00010000
out portc, gvar
rcall del250
ret

fillLEDRs:
//Para cada uno de los registros que almacenan los valores correspondientes a los LEDs, se carga un valor pseudoaleatorio resultante de rd
//se le aplica un OR inmediato para encender también el LED de inicio
//Se llama un delay y un rd para cambiar el valor del número pseudoaleatorio
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
//se verifican los pines correspondientes a cada botón en el arreglo matricial, dependiendo de cada posible configuración
//para cada uno de los 4 botones de juego, se carga un valor a cvar que corresponde a un LED
//Después se aplica un or inmediato con 16 para hacer set al quinto bit, el cual corresponde al LED de inicio
ldi cvar,0
btl1: //Botón 1
in gvar,pind //Se carga el valor de pind a gvar
andi gvar,0b00101000
cpi gvar, 0b00101000 //se compara con el valor correspondiente al botón
brne btl2 //si no es igual, salta a comparar para el siguiente botón
bl1: //en caso de ser igual, se cicla hasta que se suelte el botón
in gvar,pind
andi gvar,0b00101000
cpi gvar, 0b00101000
breq bl1

ldi cvar, 1 //se carga el valor correspondiente al pin al que está conectado el LED
ori cvar,16 //se settea el quinto bit, el cual corresponde al LED de inicio
rjmp btngetend
/////
btl2: //Botón 2
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
btl3://Botón 3
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
btl4://Botón 4
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
  andi gvar, 0b00011100 //Se carga el valor de pind a gvar y se filtra con AND
  out portd, gvar //Se lanza el valor obtenido al puerto d (nada más pq sí)

  cpi gvar, 0b00010000 //Se compara el valor con el mayor posible (el quinto bit)
  breq switching //En caso de haber alcanzado el valor máximo, regresar el valor a 1
  lsl gvar //Desplazar bits hacia la izquierda para prender el siguiente pin de los 3
  out portd,gvar //Prender el bit resultante
  rjmp matend

  switching:
  ldi gvar, 0b00000100 //cargar valor para prender el tercer bit
  out portd, gvar //prender tercer bit
  matend:
  ret

  res:
  //se carga a gvar el valor de PIND y se filtra para verificar que el botón de reset está presionado
  in gvar, PIND
  andi gvar, 0b01000100
  cpi gvar, 0b01000100
  brne resetEnd //Si el botón de reset no está presionado, se termina la rutina

  Reset: //Ciclo mientras el botón de reset siga presionado
  in gvar, PIND
  andi gvar, 0b01000100
  cpi gvar, 0b01000100
  breq reset
  rcall del100
  rjmp start1 //Se salta al inicio del programa (secuencia de encendido e inicialización de valores en registros)
  resetend:
  ret
  //Rutinas de Delay
del250:
LDI del,80 //3.125*80=250ms
rjmp et3
del500:
LDI del, 160 //3.125*160=500ms
rjmp et3
del50:
ldi del,16 //3.125*32=50ms
rjmp et3
del100:
ldi del,32 //3.125*32=100ms
et3:
LDI del2, 50 //62.5 us * 50=3125 us = 3.125ms
et2:
LDI del3, 250 
et1:
NOP
; Itera 250 veces, emplea 1/4 uS por iteraci?n
DEC del3
; 250 x 1/4 uS = 62.5 uS 
BRNE et1
DEC del2
BRNE et2
; 1 mS x 250 = 250 mS
DEC del
BRNE et3
; 250 mS x 2 = 500 mS
RET

rd:
//desplaza el valor de 31 un bit a la izquierda (Se inicializa en 1 al inicio del programa)
  lsl r31
  cpi r31,0b0010000 //Si r31 es el quinto bit, se regresa su valor a 1
  breq rdr 
  ret
  rdr:
  ldi r31,1
  ret