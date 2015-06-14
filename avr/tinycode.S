#include <avr/io.h>

#define FREQ 35000L
#define DUTY 25

#define WINKBLINK 17500

#define PERIOD  ((F_CPU)/(FREQ))
#define ONDUTY  ((PERIOD) * (DUTY) / 100)
#define OFFDUTY ((PERIOD) * (100-DUTY) / 100)

#define PUMP 3
#define NIPPLES 4

#define PARAM1  r17
#define PARAM2  r18

ConfigureIO:
    ldi r29, 0

    // outputs
    ldi r16, _BV(PUMP) | _BV(NIPPLES)
    out _SFR_IO_ADDR(DDRB), r16
    out _SFR_IO_ADDR(PORTB), r29

    // analog comparator
    // + = AIN0 = Internal voltage reference = 1.22V
    // - = AIN1 = PB1
    // if AIN0 > AIN1: AC = 1
    //   while AC == 1: pump
    //   when PB1 > 1.22, AC == 0: don't pump
    // ACSR = _BV(AINBG); // enable comparator, enable bandgap reference
    sbi _SFR_IO_ADDR(ACSR), AINBG
    ret

DelayR0:
l1:
    dec r0
    brne l1
    ret

DelayOn:
    nop
	ret
DelayOff:
   nop
   nop
   nop
   ret	

Pumpor:
    ldi r19, 1
    ldi r20, 3
    ldi r22, _BV(ACO)
    ldi r23, 255
    mov r24, r23
    ldi r25, _BV(NIPPLES)
Forever:
	 dec r23
	 brne loc1
	 dec r24
	 brne loc1
	 in r21, _SFR_IO_ADDR(PORTB)
	 eor r21, r25
	 out _SFR_IO_ADDR(PORTB), r21
loc1:	
    // load analog comparator status
    in r21, _SFR_IO_ADDR(ACSR)
    // test output (ACO), bit 5
	 and r21, r22	
	 breq offstate
onstate:	
    sbi _SFR_IO_ADDR(PORTB), PUMP
    rcall DelayOn
    cbi _SFR_IO_ADDR(PORTB), PUMP
    rcall DelayOff
    rjmp Forever
offstate:
    cbi _SFR_IO_ADDR(PORTB), PUMP
	 rcall DelayOff
    rjmp Forever

main:
    rcall ConfigureIO
    rjmp Pumpor


    .global main

