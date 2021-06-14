

/*
  This is the central code for Smart Mask.
  The code is designed for seeduino XIAO and other M0+ processors
  Functions:
  Real time clock with time stamp.
  Data storage management and sending via bluetooth.
  Power saving system (should disable debug mode by define)
  Processed data: Heart Rate, SPO2, Respiration Rate, Body Tempuration, Motion
  Raw data: IR +Red PPG, Accelerometer XYZ, Resp Temp, skin temp, enviroment temp.
  
  Hardware Connections (Breakoutboard to Arduino):
  MAX3010X
  -5V = 5V (3.3V is allowed)
  -GND = GND
  -SDA = A4 (or SDA)
  -SCL = A5 (or SCL)
  -INT = Not connected

  //check read me for details

  
 
  The MAX30105 Breakout can handle 5V or 3.3V I2C logic. We recommend powering the board with 5V
  but it will also run at 3.3V.

  
*/

#include <Wire.h>
#include "MAX30105.h"
//#include "spo2_algorithm.h"//by spark fun, free 
#include "algorithm_by_RF.h"//by aromring on Github, free

#include "heartRate.h"

#include "calendar.h" //software RTC
#include <EnergySaving.h>
#include <TimerTCC0.h>

//#include <pgmspace.h>


//you need to download the following libraries.
#include "RTCZero.h" //this is the build_in HW real time clock, but it do not have a time stamp
//#include <ArduinoLowPower.h>
/*
#include <EnergySaving.h>
//C:\Users\hp\AppData\Local\Arduino15\packages\Seeeduino\hardware\samd\1.8.1\libraries\EnergySaving\src
*/


MAX30105 particleSensor;


const byte RATE_SIZE = 2; //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE]; //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0; //Time at which the last beat occurred

bool spoi_done=0;

float beatsPerMinute;
int beatAvg;
bool No_spoi=0;//1 to disable spoi algorithmn to speed up 

#define MMA8452Q_Addr 0x1C


#define MAX_NAME_LENGTH 20
char NAME_OF_MASK[MAX_NAME_LENGTH]="Smart Mask";

#define MASK_COMMAND_SIZE 10
#define BLE_STAT_PIN 2
#define MAX_BRIGHTNESS 255
#define SLEEP_TIME_uS 1000000
#define IN_DEBUGING 1 //1 to prevent the seeduino from sleeping

#define Env_Temp_Coe 10
#define Resp_Temp_Coe 90
#define Ear_Temp_Coe 10
#define Diff_Coe 2
uint8_t Oral_Temp=60; //30+(x/10)
uint16_t Ear_Temp;
uint16_t Peak_Temp;
uint16_t Env_Temp;

#define Data_Set_Length_Max 1000
#if defined(__AVR_ATmega328P__) || defined(__AVR_ATmega168__)
//Arduino Uno doesn't have enough SRAM to store 100 samples of IR led data and red led data in 32-bit format
//To solve this problem, 16-bit MSB of the sampled data will be truncated. Samples become 16-bit data.
uint32_t irBuffer[200]; //infrared LED sensor data
uint32_t redBuffer[200];  //red LED sensor data

#else
uint32_t irBuffer[200]; //infrared LED sensor data
uint32_t redBuffer[200];  //red LED sensor data
#endif

#define HDC1080_ADDR          0x40 //7-bit I2C Address
#define HDC1080_CFG_REG       0x02 //config mode
#define HDC1080_TEMP_REG      0x00 //read tempurature
#define HDC1080_HUMI_REG      0x01 //read humidity


#define HDC1080_RST 0x8000
#define HDC1080_HEAT 0x2000
#define HDC1080_TEMP_HUM 0x1000
#define HDC1080_LOW_TRES 0x0400
#define HDC1080_LOW_HRES 0x0200
#define HDC1080_MID_HRES 0x0100

#define MCP9808_I2CADDR_A 0x1A ///< I2C address,  A1 connected to VCC

#define MCP9808_I2CADDR_B 0x18 ///< I2C address, A0 connected to ground
#define MCP9808_REG_CONFIG 0x01      ///< MCP9808 config register

#define MCP9808_REG_CONFIG_SHUTDOWN 0x0100   ///< shutdown config
#define MCP9808_REG_CONFIG_CRITLOCKED 0x0080 ///< critical trip lock
#define MCP9808_REG_CONFIG_WINLOCKED 0x0040  ///< alarm window lock
#define MCP9808_REG_CONFIG_INTCLR 0x0020     ///< interrupt clear
#define MCP9808_REG_CONFIG_ALERTSTAT 0x0010  ///< alert output status
#define MCP9808_REG_CONFIG_ALERTCTRL 0x0008  ///< alert output control
#define MCP9808_REG_CONFIG_ALERTSEL 0x0004   ///< alert output select
#define MCP9808_REG_CONFIG_ALERTPOL 0x0002   ///< alert output polarity
#define MCP9808_REG_CONFIG_ALERTMODE 0x0001  ///< alert output mode

#define MCP9808_REG_UPPER_TEMP 0x02   ///< upper alert boundary
#define MCP9808_REG_LOWER_TEMP 0x03   ///< lower alert boundery
#define MCP9808_REG_CRIT_TEMP 0x04    ///< critical temperature
#define MCP9808_REG_AMBIENT_TEMP 0x05 ///< ambient temperature
#define MCP9808_REG_MANUF_ID 0x06     ///< manufacture ID
#define MCP9808_REG_DEVICE_ID 0x07    ///< device ID
#define MCP9808_REG_RESOLUTION 0x08   ///< resolutin



uint32_t irCurrent;
uint32_t redCurrent;
uint8_t spoiRead=0;
uint8_t spoiPTR=0;

uint8_t Mask_Mode=1; //mormal 1//measurement only
bool PPG_List_Sent=1;

int32_t bufferLength; //data length
//int32_t spo2; //SPO2 value
float spo2; //SPO2 value
int8_t validSPO2; //indicator to show if the SPO2 calculation is valid
int32_t heartRate; //heart rate value
int8_t validHeartRate; //indicator to show if the heart rate calculation is valid
float signalRatio;
float signalCorel;

  byte ledBrightness = 60; //Options: 0=Off to 255=50mA
  byte sampleAverage = 1; //Options: 1, 2, 4, 8, 16, 32
  byte ledMode = 2; //Options: 1 = Red only, 2 = Red + IR, 3 = Red + IR + Green
  byte sampleRate = 400; //Options: 50, 100, 200, 400, 800, 1000, 1600, 3200
  int pulseWidth = 411; //Options: 69, 118, 215, 411
  int adcRange = 4096; //Options: 2048, 4096, 8192, 16384

byte pulseLED = 9; //Must be on PWM pin
byte readLED = 10; //Blinks with each data read

bool Stress_Measured = 0;
uint16_t Stress_Refresh_Count=3599;

uint8_t NextSecond=0; //the alarm will take place when time change to the next second.


struct Data_Set{
   uint32_t Second_Stamp_S;
   uint8_t Heart_Rate_S;
   uint8_t SPO2_S;
   uint16_t MOTION_LEVEL_S; 
   uint8_t TEMP_S;          //30+TEMP_S/10
   uint8_t Resp_Rate_S;

  
};


struct PPG_Set{
//uint32_t Milli_Stamp;
uint32_t PPG_Red;
uint32_t PPG_IR;

};
uint16_t BLE_Data_Read_RC=0;
uint16_t BLE_Data_Write_RC=0;

#define PPG_List_Length 992
struct PPG_List{
 uint32_t Second_Stamp; //start
 PPG_Set PPG_Sig[PPG_List_Length];
};
bool BLE_LAST_STAT=0;

Data_Set Normal_Mode_Data[Data_Set_Length_Max];
PPG_List  PPG_List_Ins;


uint16_t BT_SLEEP_COUNT=0;
uint16_t BT_SLEEP_SECOND=90;

bool TEMP_COUNT_NORM=1;
uint8_t TEMP_COUNT=4;

datetime My_Time;
RTCZero rtc;
EnergySaving nrgSave;

bool isLEDOn = false;
bool Mask_On = false; //detect whether the user is wearing the mask


uint16_t ACCEL[7];
int8_t ACCEL_X_LIST[PPG_List_Length/2];
int8_t ACCEL_Y_LIST[PPG_List_Length/2];
int8_t ACCEL_Z_LIST[PPG_List_Length/2];

uint16_t TEMP_A[PPG_List_Length/6];

int16_t TEMP_B[PPG_List_Length/6];

int16_t TEMP_C[PPG_List_Length/6];

uint16_t HDC1080_VAL;

uint8_t spoiPTR_MAX=50;  //25 1 data/s, 50, 1 data/2s..... 100, 1 data/4s..  Total data storage = 1000.

uint16_t Resp_Temp[200];
uint8_t Resp_Temp_Count=0;
uint8_t Resp_Rate_Buff=0;
uint16_t peak_temp=0;

uint8_t MOT_PEAK_X=0;
uint8_t MOT_PEAK_Y=0;
uint8_t MOT_PEAK_Z=0;
int16_t MOT_MEAN_X=0;
int16_t MOT_MEAN_Y=0;
int16_t MOT_MEAN_Z=0;

uint8_t MOT_COUNT=0;

uint16_t MOT_LEVEL=0;

bool CLEAN_MOT_INTI=0;


bool Freeze_m=0; //shut down to power save at low power


void setup()
{ 
   pinMode(3, OUTPUT); 
    digitalWrite(3, 1);
    pinMode(1, INPUT); 
   Wire.begin();
   Wire.setClock(400000);

   //################################Accelerometer config##############################################
   // Start I2C Transmission
  Wire.beginTransmission(MMA8452Q_Addr);
  // Select control register
  Wire.write(0x2A);
  // StandBy mode
  Wire.write(0x00);
  // Stop I2C Transmission
  Wire.endTransmission();
 
  // Start I2C Transmission
  Wire.beginTransmission(MMA8452Q_Addr);
  // Select control register
  Wire.write(0x2A);
  // Active mode
  Wire.write(0x01);
  // Stop I2C Transmission
  Wire.endTransmission();
 
  // Start I2C Transmission
  Wire.beginTransmission(MMA8452Q_Addr);
  // Select control register
  Wire.write(0x0E);
  // Set range to +/- 2g
  Wire.write(0x00);
  // Stop I2C Transmission
  Wire.endTransmission();
  delay(100);
  //#####################################HDC1080#############################################
 /* 
#define HDC1080_ADDR          0x40 //7-bit I2C Address
#define HDC1080_CFG_REG       0x02 //config mode
#define HDC1080_TEMP_REG      0x00 //read tempurature
#define HDC1080_HUMI_REG      0x01 //read humidity


#define HDC1080_RST 0x80
#define HDC1080_HEAT 0x20
#define HDC1080_TEMP_HUM 0x10
#define HDC1080_LOW_TRES 0x04
#define HDC1080_LOW_HRES 0x02
#define HDC1080_MID_HRES 0x01
  */
  Wire.beginTransmission(HDC1080_ADDR);
  Wire.write(HDC1080_CFG_REG);
  Wire.endTransmission(false);
  Wire.requestFrom(HDC1080_ADDR,2);
  if(Wire.available()==2)
  {HDC1080_VAL=Wire.read();
   Wire.read();
    
  }
  HDC1080_VAL=0;
  Wire.beginTransmission(HDC1080_ADDR);
  Wire.write(HDC1080_CFG_REG);
  Wire.write(0);
  Wire.write(0);
  Wire.endTransmission();

  //#####################################MPC9808_A#############################################

  Wire.beginTransmission(MCP9808_I2CADDR_A);
  Wire.write(MCP9808_REG_CONFIG);
  Wire.write(0);
  Wire.write(0);
  Wire.endTransmission(false);

    //#####################################MPC9808_B#############################################

  Wire.beginTransmission(MCP9808_I2CADDR_B);
  Wire.write(MCP9808_REG_CONFIG);
  Wire.write(0);
  Wire.write(0);
  Wire.endTransmission(false);
  

  
  Serial.begin(115200); // initialize serial communication at 115200 bits per second:
  Serial1.begin(9600);
  Serial.println(F("setting up"));
  pinMode(pulseLED, OUTPUT);
  pinMode(readLED, OUTPUT);
 pinMode(BLE_STAT_PIN,INPUT);
  pinMode(3, OUTPUT);
 // attachInterrupt(1, NewPPG,FALLING);

  



  
  My_Time.init_Datetime(); //start the soft RTC
  
  
  rtc.begin(); //start the hard RTC
  rtc.setTime(0,0,0);
  rtc.setDate(0,1,1);//Year offset? 
  rtc.enableAlarm(rtc.MATCH_SS);//second matched alarm
  rtc.setAlarmSeconds(NextSecond);
  rtc.attachInterrupt(RTC_Isr);
  nrgSave.begin(WAKE_RTC_ALARM);  //standby setup for external interrupts
  //rtc.setAlarm();

  

  // Initialize sensor
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) //Use default I2C port, 400kHz speed
  {
    Serial.println(F("MAX30105 was not found. Please check wiring/power."));
    while (1);
  }

  Serial.println(F("Attach sensor to finger with rubber band. Press any key to start conversion"));
 /*
  while (Serial.available() == 0) ; //wait until user presses a key
  Serial.read(); */
   delay(3000);
 Serial1.print("AT+CMODE=1\r\n");
  delay(100);
  
  Serial1.print("AT+ROLE=0\r\n");
  delay(100);
  Serial1.print("AT+NAME=Smart Mask\r\n");
  delay(100);
   Serial1.print("AT+UART=115200,0,0\r\n");
  delay(100);
  Serial1.begin(115200);
  

  

  /*

 //Serial1.print("AT+STARTEN1\r\n");
 // delay(100);

  Serial1.print("AT+BAUD0\r\n");
  delay(100);

  Serial1.begin(115200);
  

  
  //Serial1.print("AT+DEFAULT");
  //Serial1.print("\r\n");
  //delay(100); 

  
  Serial1.print("AT+NAME");
  Serial1.print(NAME_OF_MASK);
  Serial1.print("\r\n");
  delay(100);
  Serial1.print("AT+ADVIN0\r\n");
  delay(100);
  Serial1.print("AT+RST\r\n");
  delay(100);

  
 
  Serial1.print("AT+STARTEN0\r\n");
  delay(100);
  */



 Serial.println(F("Attach sensor to finger with rubber band. Press any key to start conversion"));
   /*
   while (Serial.available() == 0) ; //wait until user presses a key
  Serial.read();*/

  



 

  particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange); //Configure sensor with these settings
  //particleSensor.setup();
 //  particleSensor.setPulseAmplitudeRed(0x0A); //Turn Red LED to low to indicate sensor is running
 // particleSensor.setPulseAmplitudeGreen(0); //Turn off Green LED

 //    TimerTcc0.initialize((100000/sampleRate*sampleAverage));


}

void loop()
{ 
  bufferLength = 200; //buffer length of 100 stores 4 seconds of samples running at 25sps

  //read the first 100 samples, and determine the signal range
  
  My_Time.To_Stamp(2021, 5, 23, 9, 16, 0);
  //Serial.println(HDC1080_VAL);


  for(int i=100; i<150; i++)//leave the rest sample empty to make faster
{  Wire.beginTransmission(HDC1080_ADDR);
   Wire.write(HDC1080_TEMP_REG);
   Wire.endTransmission(false);
   delay(79);
    Wire.requestFrom(HDC1080_ADDR,2);
       uint16_t temp_r=0;
       if(Wire.available()==2)
       {temp_r=(Wire.read())<<8;
        temp_r=temp_r+Wire.read();
       
       Resp_Temp[i]=temp_r;
       Serial.println(Resp_Temp[i]); 
       
       }
      

  
}
  
 uint8_t Temp_Read=3;
  for (byte i = 0 ; i < bufferLength ; i++)
  {
 //   while (particleSensor.available() == false) //do we have new data?
 //     particleSensor.check(); //Check the sensor for new data
    Temp_Read++;
    if(Temp_Read==4)
    { Temp_Read=0;
      
      Wire.beginTransmission(HDC1080_ADDR);
      Wire.write(HDC1080_TEMP_REG);
      Wire.endTransmission(false);
      
    }
    redBuffer[i] = particleSensor.getRed();
    irBuffer[i] = particleSensor.getIR();
    delay(17);
    if(Temp_Read==3)
    {
       Wire.requestFrom(HDC1080_ADDR,2);
       uint16_t temp_r=0;
       if(Wire.available()==2)
       {temp_r=(Wire.read())<<8;
        temp_r=temp_r+Wire.read();
       
       Resp_Temp[(i+200)>>2]=temp_r;
       Serial.println(Resp_Temp[(i+600)>>2]); 
       
       }
    }
    
 //   particleSensor.nextSample(); //We're finished with this sample so move to next sample

    Serial.print(F("red="));
    Serial.print(redBuffer[i], DEC);
    Serial.print(F(", ir="));
    Serial.println(irBuffer[i], DEC);
  }



  //calculate heart rate and SpO2 after first 100 samples (first 4 seconds of samples)
//  maxim_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate);
   rf_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate, &signalRatio, &signalCorel);
      for (byte i = spoiPTR_MAX; i < 200; i++)
      {
       redBuffer[i - spoiPTR_MAX] = redBuffer[i];
       irBuffer[i - spoiPTR_MAX] = irBuffer[i];
      }
  //Continuously taking samples from MAX30102.  Heart rate and SpO2 are calculated every 1 second
 // TimerTcc0.attachInterrupt(timerIsr);//not working
  char MASK_COMMAND[MASK_COMMAND_SIZE];
  uint8_t COMMAND_COUNT=0;
  while (1)
  {
    if(Serial.available())
    {if(Serial.read()=='s')
     {   Serial1.begin(9600);
        Serial1.print("AT+CMODE=1\r\n");
        delay(100);
  
        Serial1.print("AT+ROLE=0\r\n");
        delay(100);
        Serial.print(Serial1.read());
        Serial1.print("AT+NAME=Smart Mask\r\n");
        delay(100);
        Serial.print(Serial1.read());
        Serial1.print("AT+UART=115200,0,0\r\n");
        delay(100);
        Serial.print(Serial1.read());

        Serial1.begin(115200);
      
     }
    }

   if(Mask_Mode==0 || Stress_Measured==1)
    {
    
      if(Serial1.available())
      {COMMAND_COUNT=0;
       Serial.printf("Bluetooth:");
        while(Serial1.available() && COMMAND_COUNT<MASK_COMMAND_SIZE)
       { 
        MASK_COMMAND[COMMAND_COUNT]=Serial1.read();
        Serial.print(MASK_COMMAND[COMMAND_COUNT]);
        COMMAND_COUNT++;
       }
      
      }
   if(Mask_On)
    {
    
      Mask_On=0;
 //    particleSensor.wakeUp(); 
    
     
  //    while (particleSensor.available() == false) //do we have new data?
  //      particleSensor.check(); //Check the sensor for new data
  //    digitalWrite(readLED, !digitalRead(readLED)); //Blink onboard LED with every data read

   //do not get red here to save time.
   
      irCurrent = particleSensor.getIR();
      redCurrent= particleSensor.getRed();

    spoiRead++;
    if(spoiRead==2)
    {   


         // Request 7 bytes of data
      Wire.requestFrom(MMA8452Q_Addr, 7);
 
  // Read 7 bytes of data
  // staus, xAccl lsb, xAccl msb, yAccl lsb, yAccl msb, zAccl lsb, zAccl msb
      if(Wire.available() == 7) 
      {
        ACCEL[0] = Wire.read();
        ACCEL[1] = Wire.read();
        ACCEL[2] = Wire.read();
        ACCEL[3] = Wire.read();
        ACCEL[4] = Wire.read();
        ACCEL[5] = Wire.read();
        ACCEL[6] = Wire.read();
     }
 
  // Convert the data to 12-bits
      int8_t xAccl = ACCEL[1] ;

 
      int8_t yAccl = ACCEL[3]; 

 
      int8_t zAccl =ACCEL[5];
    
 
       // Output data to serial monitor

      
      if(CLEAN_MOT_INTI)
      {
        if(MOT_COUNT!=0)
       {
        MOT_MEAN_X=MOT_MEAN_X/MOT_COUNT;
        MOT_MEAN_Y=MOT_MEAN_Y/MOT_COUNT;
        MOT_MEAN_Z=MOT_MEAN_Z/MOT_COUNT;
        if(MOT_MEAN_X<0)
        {MOT_MEAN_X=-MOT_MEAN_X;}
        if(MOT_MEAN_Y<0)
        {MOT_MEAN_Y=-MOT_MEAN_Y;}
        if(MOT_MEAN_Z<0)
        {MOT_MEAN_Z=-MOT_MEAN_Z;}
         MOT_LEVEL=(MOT_PEAK_X-MOT_MEAN_X)*(MOT_PEAK_X-MOT_MEAN_X)+(MOT_PEAK_Y-MOT_MEAN_Y)*(MOT_PEAK_Y-MOT_MEAN_Y)+(MOT_PEAK_Z-MOT_MEAN_Z)*(MOT_PEAK_Z-MOT_MEAN_Z);
   //     Serial.print("MOT_LEVEL: ");
   //     Serial.println(MOT_LEVEL);
        
       }



       MOT_PEAK_X=0;
       MOT_PEAK_Y=0;
       MOT_PEAK_Z=0;
       MOT_MEAN_X=0;
       MOT_MEAN_Y=0;
       MOT_MEAN_Z=0;
       MOT_COUNT=0;
       CLEAN_MOT_INTI=0;
      }
      else
      {
       
       MOT_MEAN_X+=xAccl;
       MOT_MEAN_Y+=yAccl;
       MOT_MEAN_Z+=zAccl;
      if(MOT_PEAK_X<xAccl)
       {MOT_PEAK_X=xAccl;}
      else if(MOT_PEAK_X<-xAccl)
       {MOT_PEAK_X=-xAccl;}
      if(MOT_PEAK_Y<yAccl)
       {MOT_PEAK_Y=yAccl;}
      else if(MOT_PEAK_Y<-yAccl)
       {MOT_PEAK_Y=-yAccl;}
      if(MOT_PEAK_Z<zAccl)
       {MOT_PEAK_Z=zAccl;}
      else if(MOT_PEAK_Z<-zAccl)
       {MOT_PEAK_Z=-zAccl;}
    
       MOT_COUNT++; 
      }


        
      
      
    }

    if(spoiRead==1)
    { 
      Wire.beginTransmission(HDC1080_ADDR);
      Wire.write(HDC1080_TEMP_REG);
      Wire.endTransmission(false);

        Wire.beginTransmission(MCP9808_I2CADDR_A);
        Wire.write(MCP9808_REG_AMBIENT_TEMP);
        Wire.endTransmission(false);

        Wire.beginTransmission(MCP9808_I2CADDR_B);
        Wire.write(MCP9808_REG_AMBIENT_TEMP);
        Wire.endTransmission(false);
        
    
    }
    if(spoiRead==3)
      {  Resp_Temp_Count++;
        if(Resp_Temp_Count==25)
        {Resp_Temp_Count=0;
         uint8_t Rise_Count=0;
         uint8_t Fall_Count=0;
         uint8_t Last_Fall=0;
         uint8_t Last_Rise=0;
         bool is_rising=0;
         bool is_falling=0;
         bool peak_found=0;
         bool first_peak_valid=0;
         bool second_peak_valid=0;
         uint8_t first_peak_index=0;
         uint8_t second_peak_index=0;
         for(int i=0; i<199; i++)
         {if(Resp_Temp[i+1]>Resp_Temp[i])
          {
            Rise_Count++;
            Fall_Count=0;
          }
          else if(Resp_Temp[i+1]<Resp_Temp[i])
          { Rise_Count=0;
            Fall_Count++;      
          }
   /*      else
          {if(!Rise_Count)
           {Fall_Count++;}
           else
           {Rise_Count++;}
            
          } */
          
          if(is_rising && !Rise_Count && !peak_found)
          {peak_found=1;
           if(!first_peak_valid)
           {first_peak_index=i;
            peak_temp=Resp_Temp[i];
           }
           else
           {second_peak_index=i;
            if(Resp_Temp[i]>peak_temp)
            {peak_temp=Resp_Temp[i];}
           }    
          }

          if(peak_found && is_falling)
          {if(!first_peak_valid)
           {first_peak_valid=1;
            peak_found=0;
          //  Serial.print(first_peak_index);
           }
           else
           {second_peak_valid=1;
            peak_found=0;
            break;
           }
            
          }

          if(peak_found && Fall_Count==0)
          {peak_found=0;
           Rise_Count=Last_Rise-Last_Fall;
          }
   
          
          if(Rise_Count>3)   // change to tune the peak detection
          {is_rising=1;}
          else
          {is_rising=0;}

          if(Fall_Count>2)   // change to tune the peak detection
          {is_falling=1;}
          else
          {is_falling=0;}

     

    
          
          if(Fall_Count!=0)
          {Last_Fall=Fall_Count;}
          if(Rise_Count!=0)
          {Last_Rise=Rise_Count;}
/*
          Serial.print(Rise_Count);
          Serial.print(' ');
          Serial.println(Fall_Count);
          */
          
          
         }

        
         Peak_Temp=peak_temp;
         if(second_peak_index>first_peak_index)
         { Resp_Rate_Buff=1500/(second_peak_index-first_peak_index);
           
         }//this is 2x resp rate.
         else
         {Resp_Rate_Buff=0;
          if(first_peak_index==0)
          {
            Peak_Temp=Resp_Temp[0];
          }
         
         }
         
    
          //estimate core temp
     
          //Oral_Temp=((int32_t)(Resp_Temp_Coe*(int32_t)(((int16_t)(Peak_Temp-15888)>>2)+11912)/24.8242424)+(int32_t)(Ear_Temp_Coe*(Ear_Temp+2440)/5.0)+Env_Temp_Coe*(int32_t)(400-Env_Temp)-48000)/160; //this give 0 at 25 degree
                                               //coe=1600                   //coe=1600
         Oral_Temp=(Diff_Coe*(int32_t)((float)((int16_t)(Peak_Temp-15888))/24.8242424)-(Diff_Coe-1)*(int32_t)Env_Temp-480)*10/16;

         
          for (byte i = 25; i < 200; i++)
          {
           Resp_Temp[i - 25] = Resp_Temp[i];
          }
         
          
        }
         
       Wire.requestFrom(HDC1080_ADDR,2);
       uint16_t temp_r=0;
       if(Wire.available()==2)
       {temp_r=(Wire.read())<<8;
        temp_r=temp_r+Wire.read();
     //  Serial.println(temp_r); 
       }
       
       Resp_Temp[Resp_Temp_Count+75]=temp_r;
        
        
        Wire.requestFrom(MCP9808_I2CADDR_A,2);
       uint16_t temp_a=0;
       if(Wire.available()==2)
       {temp_a=(Wire.read() & 0xf)<<8;
        temp_a=temp_a+Wire.read();
        //Serial.println(temp_a);
         if(temp_a & 0x1000)
           {
             temp_a-=4096;
           }
          Env_Temp=temp_a;
       }


      
        
        
        
        
        Wire.requestFrom(MCP9808_I2CADDR_B,2);
       uint16_t temp_b=0;
       if(Wire.available()==2)
       {temp_b=(Wire.read() & 0xf)<<8;
        temp_b=temp_b+Wire.read();
       // Serial.println(temp_b);
          if(temp_b & 0x1000)
           {
             temp_b-=4096;
           }
           Ear_Temp=temp_b;
       }
        
        

      
    }

   if(spoiRead==4)
   {
    spoiRead=0;
    
   }
  
   if( No_spoi==0 )
   {

     



    redBuffer[spoiPTR+200-spoiPTR_MAX] =  redCurrent;
    irBuffer[spoiPTR+200-spoiPTR_MAX] =  irCurrent;
    spoiPTR++;
    
   if(spoiPTR==spoiPTR_MAX)
    {spoiPTR=0;
 
     // maxim_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate);
      rf_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate, &signalRatio, &signalCorel);
      //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

      //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      
      for (byte i = spoiPTR_MAX; i < 200; i++)
      {
       redBuffer[i - spoiPTR_MAX] = redBuffer[i];
       irBuffer[i - spoiPTR_MAX] = irBuffer[i];
       }




 

            //send samples and calculation result to terminal program through UART
         if(digitalRead(BLE_STAT_PIN) && digitalRead(3)) //BLE connected, send the data
         {if(BLE_LAST_STAT == digitalRead(BLE_STAT_PIN))
          {while (BLE_Data_Read_RC!=BLE_Data_Write_RC)
           {
           Serial1.print("{");
          Serial1.print('"');
          Serial1.print("tim");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].Second_Stamp_S, DEC);
          Serial1.print(',');

          
          Serial1.print('"');
          Serial1.print("spo");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].SPO2_S, DEC);
          Serial1.print(',');

        //fake data
      //    Normal_Mode_Data[BLE_Data_Read_RC].MOTION_LEVEL_S=3; //will be classified later by ACCELERO
      //    Normal_Mode_Data[BLE_Data_Read_RC].TEMP_S=63;  //will be calculate from three other temp
         // Normal_Mode_Data[BLE_Data_Read_RC].Resp_Rate_S=25;  //will be calculated from HDC1080 data
          

         
          Serial1.print('"');
          Serial1.print("hr");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].Heart_Rate_S, DEC);
          Serial1.print(',');
          float TEMP_tmp;

          Serial1.print('"');
          Serial1.print("mot");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].MOTION_LEVEL_S, DEC);
          Serial1.print(',');

          Serial1.print('"');
          Serial1.print("tem");
          Serial1.print('"');
          Serial1.print(':');
          TEMP_tmp=((float)(Normal_Mode_Data[BLE_Data_Read_RC].TEMP_S))/10.0+30.0;
          Serial1.print(TEMP_tmp, 1);
          Serial1.print(',');


          Serial1.print('"');
          Serial1.print("rr");
          Serial1.print('"');
          Serial1.print(':');
           TEMP_tmp=((float)(Normal_Mode_Data[BLE_Data_Read_RC].Resp_Rate_S))/2.0;
          Serial1.print(TEMP_tmp, 1);
            Serial1.print(',');

           
           uint16_t sensorValue = analogRead(1);
            if(sensorValue<900)
            {Freeze_m=1;}
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
      //     float voltage = sensorValue * (5.0 / 1023.0);
         TEMP_tmp= (float)(sensorValue-899)/(float)(1023-899); // a rough estimation, but enough for this kind of applications
                     // (Vbat-2.9V)/(4.2V-2.9V)

          Serial1.print('"');
          Serial1.print("bat");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(TEMP_tmp, 2);

          Serial1.print('}');
          Serial1.print("\r\n");
          BLE_Data_Read_RC++;
           if(BLE_Data_Read_RC>=Data_Set_Length_Max)
            {
            BLE_Data_Read_RC=0;
            }  

          
          }
          }
         }
   
          
           
           Normal_Mode_Data[BLE_Data_Write_RC].Heart_Rate_S=beatAvg;
           Normal_Mode_Data[BLE_Data_Write_RC].Second_Stamp_S=My_Time.Get_Stamp();
           Normal_Mode_Data[BLE_Data_Write_RC].SPO2_S=spo2;
           Normal_Mode_Data[BLE_Data_Write_RC].Resp_Rate_S=Resp_Rate_Buff;
           Normal_Mode_Data[BLE_Data_Write_RC].TEMP_S=Oral_Temp;
           Normal_Mode_Data[BLE_Data_Read_RC].MOTION_LEVEL_S=MOT_LEVEL;


           BLE_Data_Write_RC++;
           if(BLE_Data_Write_RC>=Data_Set_Length_Max)
           {
            BLE_Data_Write_RC=0;
           }
           if(BLE_Data_Write_RC==BLE_Data_Read_RC)
           {
            BLE_Data_Read_RC++;
            if(BLE_Data_Read_RC>=Data_Set_Length_Max)
            {
            BLE_Data_Read_RC=0;
            }  
           }
           BLE_LAST_STAT=digitalRead(BLE_STAT_PIN);
          
         
 /*    Serial.print(My_Time.Get_Hour());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Minute());
     Serial.print(" "); 
     Serial.println(My_Time.Get_Second());
      Serial.print(" "); */

    /*
      Serial.print(F("red="));
      Serial.print(redBuffer[99], DEC);
      Serial.print(F(", ir="));
      Serial.print(irBuffer[99], DEC);
*/
      Serial.print(F(", HRspoi="));
      Serial.print(heartRate, DEC);

      Serial.print(", HRPBA=");
      Serial.print(beatsPerMinute);
    //  Serial.print(", Avg BPM=");
    //  Serial.print(beatAvg);

      Serial.print(", TResp=");
      Serial.print(Peak_Temp/397.187878787-40);
      Serial.print(", TSkin=");
      Serial.print(Ear_Temp/16.0);
      Serial.print(", TEnv=");
      Serial.print(Env_Temp/16.0);

      Serial.print(", TOral=");
      Serial.print(Oral_Temp/10.0+30.0);
   
   /*   Serial.print(F(", HRvalid="));
      Serial.print(validHeartRate, DEC);*/



      Serial.print(F(", SPO2="));
      Serial.println(spo2, DEC);


  /*    Serial.print(F(", SPO2Valid="));
      Serial.println(validSPO2, DEC);*/
    
    
    
     }
   } 
      

       Mask_On=Mask_On || (irCurrent>50000);

   //     particleSensor.nextSample(); //We're finished with this sample so move to next sample
  
      

  if (checkForBeat((long)(irCurrent)) == true)
  {
    //We sensed a beat!
    long delta = millis() - lastBeat;
    lastBeat = millis();

    beatsPerMinute = 60 / (delta / 1000.0);

 
  } 

    if (heartRate < 200 && heartRate > 35)
    {/*
      rates[rateSpot++] = (byte)heartRate; //Store this reading in the array
      rateSpot %= RATE_SIZE; //Wrap variable

      //Take average of readings
      beatAvg = 0;
      for (byte x = 0 ; x < RATE_SIZE ; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;

      */
      beatAvg=heartRate;
      
    }
    else if(beatsPerMinute < 200 && beatsPerMinute > 35)
    { /*
      rates[rateSpot++] = (byte)beatsPerMinute; //Store this reading in the array
      rateSpot %= RATE_SIZE; //Wrap variable

      //Take average of readings
      beatAvg = 0;
      for (byte x = 0 ; x < RATE_SIZE ; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;*/
      beatAvg=beatsPerMinute;
      
    }
    else
    {
      beatAvg=0;
      //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      //XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
      
    }
  
/*
      Serial.print(", HRPBA=");
      Serial.print(beatsPerMinute);
      Serial.print(", Avg BPM=");
      Serial.println(beatAvg);
*/
    
    
     
    //PPG test
    //dumping the first 25 sets of samples in the memory and shift the last 75 sets of samples to the top
  
    //take 25 sets of samples before calculating the heart rate.

   /* 
    for (byte i = 75; i < 100; i++)
    { */
     
     
 

  //  }

    //After gathering 25 new samples recalculate HR and SP02
    
  
 
  

   /*

   //calendar test
   if(My_Time.To_Stamp(My_Time.Get_Year(), My_Time.Get_Month(), My_Time.Get_Day(), My_Time.Get_Hour(), My_Time.Get_Minute(), My_Time.Get_Second()))
   {
    Serial.read();
   }
   
   My_Time.To_Datetime(My_Time.Get_Stamp());
   
     Serial.print(My_Time.Get_Stamp());
    Serial.print(My_Time.Get_Year());
     Serial.print(" ");
      Serial.print(My_Time.Get_Month());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Day());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Hour());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Minute());
     Serial.print(" "); 
     Serial.println(My_Time.Get_Second());
     for(int i=0; i<3600; i++)
     {My_Time.Next_Datetime();}
   */
   
  }
  if(!Mask_On)
   {Mask_On=0;
    particleSensor.clearFIFO();
    particleSensor.shutDown(); 
    uint16_t sensorValue = analogRead(1);
  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
      //     float voltage = sensorValue * (5.0 / 1023.0);
   // TEMP_tmp= (sensorValue-593)/(859-593); // a rough estimation, but enough for this kind of applications
                     // (Vbat-2.9V)/(4.2V-2.9V)
   if(sensorValue<900)
   {Freeze_m=1;}
    

    if(!IN_DEBUGING)
    {nrgSave.standby();}  //now mcu goes in standby mode, this will affect debugging
    else
    {delay(1000);} //fake sleep
    
     if(BT_SLEEP_COUNT>=BT_SLEEP_SECOND)
     {
      digitalWrite(3,0);
     }
     else
     {
       BT_SLEEP_COUNT++;
     }
      particleSensor.wakeUp(); 
         if(digitalRead(BLE_STAT_PIN) && digitalRead(3)) //BLE connected, send the data
         {if(BLE_LAST_STAT == digitalRead(BLE_STAT_PIN))
          {while (BLE_Data_Read_RC!=BLE_Data_Write_RC)
           {   Serial1.print("{");
          Serial1.print('"');
          Serial1.print("tim");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].Second_Stamp_S, DEC);
          Serial1.print(',');

          
          Serial1.print('"');
          Serial1.print("spo");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].SPO2_S, DEC);
          Serial1.print(',');

        //fake data
   //       Normal_Mode_Data[BLE_Data_Read_RC].MOTION_LEVEL_S=3; //will be classified later by ACCELERO
   //       Normal_Mode_Data[BLE_Data_Read_RC].TEMP_S=63;  //will be calculate from three other temp
         // Normal_Mode_Data[BLE_Data_Read_RC].Resp_Rate_S=25;  //will be calculated from HDC1080 data
          

         
          Serial1.print('"');
          Serial1.print("hr");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].Heart_Rate_S, DEC);
          Serial1.print(',');
          float TEMP_tmp;

          Serial1.print('"');
          Serial1.print("mot");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(Normal_Mode_Data[BLE_Data_Read_RC].MOTION_LEVEL_S, DEC);
          Serial1.print(',');

          Serial1.print('"');
          Serial1.print("tem");
          Serial1.print('"');
          Serial1.print(':');
          TEMP_tmp=((float)(Normal_Mode_Data[BLE_Data_Read_RC].TEMP_S))/10.0+30.0;
          Serial1.print(TEMP_tmp, 1);
          Serial1.print(',');


          Serial1.print('"');
          Serial1.print("rr");
          Serial1.print('"');
          Serial1.print(':');
           TEMP_tmp=((float)(Normal_Mode_Data[BLE_Data_Read_RC].Resp_Rate_S))/2.0;
          Serial1.print(TEMP_tmp, 1);
          Serial1.print(',');

           TEMP_tmp= (float)(sensorValue-899)/(float)(1023-899); // a rough estimation, but enough for this kind of applications
                     // (Vbat-2.9V)/(4.2V-2.9V)


          Serial1.print('"');
          Serial1.print("bat");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(TEMP_tmp, 2);


          Serial1.print('}');
          Serial1.print("\r\n");
          BLE_Data_Read_RC++;
           if(BLE_Data_Read_RC>=Data_Set_Length_Max)
            {
            BLE_Data_Read_RC=0;
            }  

          
          }
          }
         }
         BLE_LAST_STAT = digitalRead(BLE_STAT_PIN);
      
 //   while (particleSensor.available() == false) //do we have new data?
 //    particleSensor.check(); //Check the sensor for new data
    //  redBuffer[0] = particleSensor.getRed();
      irBuffer[0] = particleSensor.getIR();
  //     particleSensor.nextSample(); //We're finished with this sample so move to next sample
     if((irBuffer[0]>50000))
     {Mask_On=1;
      digitalWrite(3, 1);
      BT_SLEEP_COUNT=0;
      
  for (byte i = 0 ; i < bufferLength ; i++)
  {
 //   while (particleSensor.available() == false) //do we have new data?
 //     particleSensor.check(); //Check the sensor for new data

    redBuffer[i] = particleSensor.getRed();
  
    irBuffer[i] = particleSensor.getIR();
 
    
 //   particleSensor.nextSample(); //We're finished with this sample so move to next sample
  /*
    Serial.print(F("red="));
    Serial.print(redBuffer[i], DEC);
    Serial.print(F(", ir="));
    Serial.println(irBuffer[i], DEC); */
  }

  //calculate heart rate and SpO2 after first 100 samples (first 4 seconds of samples)
//  maxim_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate);
   rf_heart_rate_and_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2, &heartRate, &validHeartRate, &signalRatio, &signalCorel);
     
      for (byte i = spoiPTR_MAX; i < 200; i++)
      {
       redBuffer[i - spoiPTR_MAX] = redBuffer[i];
       irBuffer[i - spoiPTR_MAX] = irBuffer[i];
      }
      
      
     }
   }
  

    

  
    }

    else if (Mask_Mode==1 && Stress_Measured==0)
    {
      particleSensor.setup(60, 1,2, 400, 411, 4096); //Configure sensor with these settings
      //particleSensor.setup();
      
/*
struct PPG_Set{
uint32_t Milli_Stamp;
//uint32_t PPG_Red;
uint32_t PPG_IR;
};
uint16_t BLE_Data_Read_RC=0;
uint16_t BLE_Data_Write_RC=0;

#define PPG_List_Length 2000
struct PPG_List{
 uint32_t Second_Stamp; //start
 PPG_Set PPG_Sig[PPG_List_Length];
};
*/
     PPG_List_Sent=0; 
     Stress_Measured=1;
     PPG_List_Ins.Second_Stamp=My_Time.Get_Stamp();
     uint8_t ACCEL_READ_COUNT=1;

       Wire.beginTransmission(MCP9808_I2CADDR_B);
       Wire.write(MCP9808_REG_AMBIENT_TEMP);
       Wire.endTransmission(false);
      for (int j=0; j<PPG_List_Length; j++)
      {//PPG_List_Ins.PPG_Sig[j].Milli_Stamp=millis();
        PPG_List_Ins.PPG_Sig[j].PPG_IR=particleSensor.getIR();
        PPG_List_Ins.PPG_Sig[j].PPG_Red=particleSensor.getRed();
    //    delay(2);
    if(PPG_List_Ins.PPG_Sig[j].PPG_IR<20000)
    {Stress_Measured=1;//not valid measurment
      Stress_Refresh_Count=120;//retry in 2 munites
      PPG_List_Sent=1;//not valid measurment, nothing to sent
      break;
    }//stop       
        ACCEL_READ_COUNT++;
        TEMP_COUNT++;
        if(TEMP_COUNT==6) //do not use 1,3,5
        { 
               
          
          TEMP_COUNT=0;

            Wire.requestFrom(MCP9808_I2CADDR_B,2);
                 uint16_t temp_b=0;
                 if(Wire.available()==2)
                 {TEMP_C[j/6]=(Wire.read() & 0xf)<<8;
                  TEMP_C[j/6]=TEMP_C[j/6]+Wire.read();
                 // Serial.println(temp_b);
                  if(TEMP_C[j/6] & 0x1000)
                  {
                    TEMP_C[j/6]-=4096;
                  }
                 }
          Wire.beginTransmission(HDC1080_ADDR);
          Wire.write(HDC1080_TEMP_REG);
          Wire.endTransmission(false);

        
         }

         
      
        if(TEMP_COUNT==2)
        { Wire.requestFrom(HDC1080_ADDR,2);
          if(Wire.available()==2)
          {TEMP_A[j/6]=(Wire.read())<<8;
           TEMP_A[j/6]=TEMP_A[j/6]+Wire.read();
           //Serial.println(temp_r); 
          }  
           Wire.beginTransmission(MCP9808_I2CADDR_A);
              Wire.write(MCP9808_REG_AMBIENT_TEMP);
              Wire.endTransmission(false);
      
         
          
        }

             if(TEMP_COUNT==4)
             { 
                Wire.requestFrom(MCP9808_I2CADDR_A,2);
                 uint16_t temp_a=0;
                 if(Wire.available()==2)
                 {TEMP_B[j/6]=(Wire.read() & 0xf)<<8;
                  TEMP_B[j/6]=TEMP_B[j/6]+Wire.read();
                  //Serial.println(temp_a);
                  if(TEMP_B[j/6] & 0x1000)
                  {
                    TEMP_B[j/6]-=4096;
                  }
                 }

                 Wire.beginTransmission(MCP9808_I2CADDR_B);
                   Wire.write(MCP9808_REG_AMBIENT_TEMP);
                   Wire.endTransmission(false);
        
      
             
    
              }

              
            
         
          
        
      
        
        if(ACCEL_READ_COUNT==2)
        {
          
          Wire.requestFrom(MMA8452Q_Addr, 7);
          ACCEL_READ_COUNT=0;
 
        // Read 7 bytes of data
        // staus, xAccl lsb, xAccl msb, yAccl lsb, yAccl msb, zAccl lsb, zAccl msb
        if(Wire.available() == 7) 
        {
          Wire.read();
          ACCEL_X_LIST[j>>1] = Wire.read();
          Wire.read();
          ACCEL_Y_LIST[j>>1] = Wire.read();
          Wire.read();
          ACCEL_Z_LIST[j>>1] = Wire.read();
          Wire.read();
         }

        
         
          
        }
        
       //set Stress Measured to 0 if data not valid
      }
        
         
      
      particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange); //Configure sensor with these settings
      //particleSensor.setup();
    }
    if(Mask_Mode==1 && Stress_Measured==1 && !PPG_List_Sent && digitalRead(3))
    {  if(digitalRead(BLE_STAT_PIN))
      {   Serial1.print('{');

           Serial1.print('"');
          Serial1.print("mode");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('"');
          Serial1.print("fast");
          Serial1.print('"');
          Serial1.print(',');
         
         Serial1.print('"');
          Serial1.print("time");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print(PPG_List_Ins.Second_Stamp);
          Serial1.print(',');
       //    delay(20   );
  
         PPG_List_Sent=1; 

          Serial1.print('"');
          Serial1.print("ppgir");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');
      for (int j=0; j<PPG_List_Length; j++)
      { 
          Serial1.print(PPG_List_Ins.PPG_Sig[j].PPG_IR);
          if(j!=PPG_List_Length-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }
          Serial1.print(']');
          Serial1.println(',');

          Serial1.print('"');
          Serial1.print("ppgred");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');

      for (int j=0; j<PPG_List_Length; j++)
      { 
     
          Serial1.print(PPG_List_Ins.PPG_Sig[j].PPG_Red);

          if(j!=PPG_List_Length-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }

          Serial1.print(']');
          Serial1.println(',');

          
          Serial1.print('"');
          Serial1.print("accelx");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');


      for (int j=0; j<(PPG_List_Length>>1); j++)
      { 
          Serial1.print(ACCEL_X_LIST[j]);

          if(j!=(PPG_List_Length>>1)-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }

          Serial1.print(']');
          Serial1.println(',');

          
          Serial1.print('"');
          Serial1.print("accely");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');



      

      for (int j=0; j<(PPG_List_Length>>1); j++)
      {    
          Serial1.print(ACCEL_Y_LIST[j]);
          if(j!=(PPG_List_Length>>1)-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }
          Serial1.print(']');
          Serial1.println(',');
          
          Serial1.print('"');
          Serial1.print("accelz");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');   
     for (int j=0; j<(PPG_List_Length>>1); j++)
      {    
          Serial1.print(ACCEL_Z_LIST[j]);
          if(j!=(PPG_List_Length>>1)-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }  
          Serial1.print(']');
          Serial1.println(',');


          Serial1.print('"');
          Serial1.print("tresp");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');   
     for (int j=0; j<(PPG_List_Length/6); j++)
      {    
          Serial1.print(TEMP_A[j]);
          if(j!=(PPG_List_Length/6)-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }  
          Serial1.print(']');
          Serial1.println(',');


          Serial1.print('"');
          Serial1.print("tskin");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');   
     for (int j=0; j<(PPG_List_Length/6); j++)
      {    
          Serial1.print(TEMP_B[j]);
          if(j!=(PPG_List_Length/6)-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }  
          Serial1.print(']');
          Serial1.println(',');



          Serial1.print('"');
          Serial1.print("tenv");
          Serial1.print('"');
          Serial1.print(':');
          Serial1.print('[');   
     for (int j=0; j<(PPG_List_Length/6); j++)
      {    
          Serial1.print(TEMP_C[j]);
          if(j!=(PPG_List_Length/6)-1)
          {Serial1.print(',');}

        if(digitalRead(BLE_STAT_PIN)==0)
        { PPG_List_Sent=0; 
          break;
        }
      }  
          Serial1.println(']');
          Serial1.println('}');



          

         
      

  
        
     

          

          
        
     //     delay(20);

          
  
     
       
       
      
         
      }
      
    }
  // LowPower.sleep(1);  //now mcu goes in standby mode
  }
}

void timerIsr() // not work
{if(Mask_On)
    {Mask_On=0;
 //    particleSensor.wakeUp(); 
    
     
  //    while (particleSensor.available() == false) //do we have new data?
  //      particleSensor.check(); //Check the sensor for new data
  //    digitalWrite(readLED, !digitalRead(readLED)); //Blink onboard LED with every data read

      redCurrent = particleSensor.getRed();
      irCurrent = particleSensor.getIR();

       Mask_On=Mask_On || (irCurrent>50000);

   //     particleSensor.nextSample(); //We're finished with this sample so move to next sample
  
      

  
     
    //PPG test
    //dumping the first 25 sets of samples in the memory and shift the last 75 sets of samples to the top
  
    //take 25 sets of samples before calculating the heart rate.

   /* 
    for (byte i = 75; i < 100; i++)
    { */
     
     
 

  //  }

    //After gathering 25 new samples recalculate HR and SP02
    
    spoiRead++;
    spoi_done=0;

  
   if(spoiRead==6)
   {spoiRead=0;
    spoi_done=0;

    
   }

   /*

   //calendar test
   if(My_Time.To_Stamp(My_Time.Get_Year(), My_Time.Get_Month(), My_Time.Get_Day(), My_Time.Get_Hour(), My_Time.Get_Minute(), My_Time.Get_Second()))
   {
    Serial.read();
   }
   
   My_Time.To_Datetime(My_Time.Get_Stamp());
   
     Serial.print(My_Time.Get_Stamp());
    Serial.print(My_Time.Get_Year());
     Serial.print(" ");
      Serial.print(My_Time.Get_Month());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Day());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Hour());
     Serial.print(" "); 
     Serial.print(My_Time.Get_Minute());
     Serial.print(" "); 
     Serial.println(My_Time.Get_Second());
     for(int i=0; i<3600; i++)
     {My_Time.Next_Datetime();}
   */
   
  }
  

 

  
}
/*
void NewPPG()//not used
{  digitalWrite(13, isLEDOn);
   isLEDOn = !isLEDOn;
  
}
*/

void RTC_Isr()  //the MCU is waked up by RTC,every 1 second
{ My_Time.Next_Datetime();//run the soft RTC
 // My_Time.Next_Datetime();//run the soft RTC
  NextSecond=rtc.getSeconds();//set next wake up
  
  rtc.setAlarmSeconds(NextSecond);
 // digitalWrite(13, isLEDOn);
 // isLEDOn = !isLEDOn;
 CLEAN_MOT_INTI=1;
 Stress_Refresh_Count+=1;
 if(Stress_Refresh_Count==3600)
 {
  Stress_Measured=0;
 }
}
