//This is a timing system designed for Intellegent Mask, Imperial College London
//The system use a time stamps of seconds passed after 2000 1.1 0:00
//The system is only designed for 21th century, not for other centuries(not meaningfull)

#pragma once

#if (ARDUINO >= 100)
 #include "Arduino.h"
#else
 #include "WProgram.h"
#endif

#define Stamp_Max 3155760000 //2099 12.31 23:59:60
#define Seconds_In_Four_Years 126230400
#define Seconds_In_One_Year 31536000
#define Seconds_In_One_Lp_Year 31622400
static char Day_Max[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

class datetime
{public:
 datetime(void);
 uint32_t Get_Stamp();
 uint16_t Get_Year();
 uint8_t Get_Month();
 uint8_t Get_Day();
 uint8_t Get_Hour();
 uint8_t Get_Minute();
 uint8_t Get_Second();
 void init_Datetime();
 bool Is_Leap(uint16_t Year_In);
 void Set_Stamp(uint32_t Stamp_In); //Set the stamp only
 bool Next_Datetime();//a fast way to time increament, will also increase the stamp by 1s.
 //the following two functions take user input and set the result to private variables, call Get_xxx aftrwards to use the result
 bool To_Stamp( uint16_t Year_In, uint8_t Month_In, uint8_t Day_In, uint8_t Hour_In, uint8_t Minute_In, uint8_t Second_In);
 void To_Datetime(uint32_t Stamp_In);


private:
 uint32_t Stamp;
 uint16_t Year;
 uint8_t Month;
 uint8_t Day;
 uint8_t Hour;
 uint8_t Minute;
 uint8_t Second;
 bool In_Setup;
};
