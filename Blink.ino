/* Zoef by default has the following pin connections:
 *
 * B3, A15  - PWM pins for motor A
 * B14, B15 - PWM pins for motor B
 * A0       - analog input intensity sensor left
 * A1       - analog input intensity sensor right
 * A9       - trigger for ultrasonic sensor front
 * B8       - echo for ultrasonic sensor front
 * A10      - trigger for ultrasnoic sensor side
 * B9       - echo for ultrasonic sensor side
 * B12      - left encoder 
 * B13      - right encoder
 *
 * Zoef does not use LEDs by default. For CSE2425 we connected
 * the leds to the following pins:
 *
 * B10     - left LED
 * B11     - right LED
 */

// This is a standard blink setup (NOTE: you need to add P to the pin number)
int led = PB12;

void setup() {                
  pinMode(led, OUTPUT);     
}

void loop() {
  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(1000);               // wait for a second
}
