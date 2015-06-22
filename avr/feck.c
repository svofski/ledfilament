#include <avr/io.h>

#define FREQ 35000L
#define DUTY 25

#define WINKBLINK 17500

#define PERIOD  ((F_CPU)/(FREQ))
#define ONDUTY  ((PERIOD) * (DUTY) / 100) 
#define OFFDUTY ((PERIOD) * (100-DUTY) / 100)

#define PUMP 3
#define NIPPLES 4

void ConfigureIO()
{
    // outputs
    DDRB |= _BV(NIPPLES) | _BV(PUMP);
    PORTB = 0;

    // analog comparator 
    // + = AIN0 = Internal voltage reference = 1.22V
    // - = AIN1 = PB1 
    // if AIN0 > AIN1: AC = 1 
    //   while AC == 1: pump
    //   when PB1 > 1.22, AC == 0: don't pump
    ACSR = _BV(AINBG); // enable comparator, enable bandgap reference
}

void Pumpor()
{
    static uint16_t blinkctr = 0;

    for(;;) {
        PORTB |= _BV(PUMP);
        _delay_us(ONDUTY);
        PORTB &= _BV(PUMP);
        _delay_us(OFFDUTY);

        if (blinkctr-- == 0) {
            blinkctr = WINKBLINK;
            PORTB ^= _BV(NIPPLES);
        }
    }
}

void main()
{
    ConfigureIO();
    Pumpor();
}
