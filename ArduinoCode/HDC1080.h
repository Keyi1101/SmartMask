//This is the class for the tempurature/humidity sensor for the Mask.
//not used, no needed
#pragma once

#if (ARDUINO >= 100)
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

#include <Wire.h>

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

class HDC1080 {
 public: 
  HDC1080(void);


  private:
 uint16_t CFG_REG_VAL;
};
