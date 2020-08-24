// Zoef by default has the following pin connections:
//
// B3, A15  - PWM pins for motor A
// B14, B15 - PWM pins for motor B
//          - analog input intensity sensor left
//          - analog input intensity sensor right
//          - ping for ultrasonic sensor front
//          - echo for ultrasonic sensor front
//          - ping for ultrasnoic sensor side
//          - echo for ultrasonic sensor side

// Zoef does not use LEDs by default. 
//
// PB12     - left LED
// PB13     - right LED


// This is a standard blink setup
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
