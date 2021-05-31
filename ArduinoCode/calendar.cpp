#include "calendar.h"

datetime::datetime() {
  // Constructor
}
void datetime::To_Datetime(uint32_t Stamp_In)
{ In_Setup=1;
  
  Stamp=Stamp_In;
  if(Stamp>Stamp_Max)
  {
    Stamp=Stamp-Stamp_Max;
  }

  uint8_t Fourth=Stamp/Seconds_In_Four_Years;
  uint32_t Stamp_Remain=Stamp%Seconds_In_Four_Years;
  bool Leap_Y=0;
  Year=2000+Fourth*4;
  if(Stamp_Remain>=Seconds_In_One_Lp_Year)
  {Year=Year+1;
   Stamp_Remain=Stamp_Remain-Seconds_In_One_Lp_Year;
   Year=Year+(Stamp_Remain/Seconds_In_One_Year);
   Stamp_Remain=Stamp_Remain%Seconds_In_One_Year;  
  }
  else
  {
    Leap_Y=1;
  }
  uint16_t Daytmp=Stamp_Remain/86400;
  uint8_t Month=0;
  uint8_t Day_Max_tmp=Day_Max[0];
  while(Daytmp>=Day_Max_tmp)
  { 
    Daytmp=Daytmp-Day_Max_tmp;
    Month+=1;
    if(Month==1 && Leap_Y)
    {
      Day_Max_tmp=29;
    }
    else
    {
      Day_Max_tmp=Day_Max[Month];
    }
  }
  Day=Daytmp;
  Stamp_Remain=Stamp_Remain%86400;
  Hour=Stamp_Remain/3600;
  Stamp_Remain=Stamp_Remain%3600;
  Minute=Stamp_Remain/60;
  Second=Stamp_Remain%60;
 
  
  
 In_Setup=0;
}



//month in is in range 1 to 12
bool datetime::To_Stamp( uint16_t Year_In, uint8_t Month_In, uint8_t Day_In, uint8_t Hour_In, uint8_t Minute_In, uint8_t Second_In)
{In_Setup=1;
  if(Year_In>=2000 && Year_In<=2099 && Month_In<=12 && Month_In>0 && Hour_In<=23 && Minute_In<=59 && Second_In<=59 ) 
  {uint8_t Fourth=(Year_In-2000)>>2; //for 21th centuries only
   
   uint8_t Y_Remain=(Year_In-2000)%4;
   bool Y_Leap=Is_Leap(Year_In);
   if(Month_In==2)
    {if(Y_Leap)
     {if(Day_In>29)
      {
       In_Setup=0; 
       return 1;
      } 
     }
     else
     {if(Day_In>28)
      {
       In_Setup=0;
       return 1;
      }
      
     }
      
    }
    else
    {if(Day_In>Day_Max[Month_In-1])
     {In_Setup=0;
      return 1;
     }
      
    }
   
    Stamp=Seconds_In_Four_Years * Fourth;
   
    if(Y_Remain > 0) 
   {
    Stamp=Stamp+Seconds_In_One_Year*Y_Remain+86400; //add the leap day directly after counting the rest year
   }
   else if(Month_In > 2)
   { 
    Stamp=Stamp+86400; //add the leap day
   }
  
   //year done
   for(int j=0; j<(Month_In-1); j++)//counting months 
   {
     Stamp=Stamp+Day_Max[j]*86400;
   }
   //month done

   Stamp=Stamp+(Day_In-1)*86400;
   Stamp=Stamp+Hour_In*3600+Minute_In*60+Second_In;

   Second=Second_In;
   Minute=Minute_In;
   Day=Day_In-1;
   Hour=Hour_In;
   Month=Month_In-1;
   Year=Year_In;

   In_Setup=0;
   return 0;
   

   }
  else
  { In_Setup=0;
    return 1;
    //invalid date
  }

  
}







 bool datetime::Next_Datetime()
 {
  if(!In_Setup) 
  {
    Stamp=Stamp+1;
   if(Stamp>=Stamp_Max)
   {
    Stamp=Stamp-Stamp_Max;
   }

   if(Second<59)
   {
    Second+=1;
    return 0;
   }
   Second=0;
   if(Minute<59)
   { Minute+=1;
     return 0;
   }
   Minute=0;
   if(Hour<23)
   { Hour+=1;
     return 0;
   }
   Hour=0;
   if(Month!=1) //not February
   {
    if(Day<(Day_Max[Month]-1))
    { Day+=1;
     return 0;
    }
    Day=0;
   }
   else //not February
   {if(!Is_Leap(Year))
    { if(Day<27)
      { Day+=1;
       return 0;
      }
      Day=0;  
    }
    else
    { if(Day<28)
      { Day+=1;
       return 0;
      }
      Day=0; 
      
    }
    
    
   }
   if(Month<11)
   {
    Month+=1;
    return 0;
   }
   Month=0;
   if(Year<2099)
   {  
    Year+=1;
    return 0;
   }
   Year=2000;
   return 1;//overflowed!
   }
   return 0; 
  }
  
 void datetime::init_Datetime()
 {In_Setup=1;
  Stamp=0;

  Year=2000;
  Month=0;//0 is 1
  Day=0;//0 is 1
  Hour=0;
  Minute=0;
  Second=0;
  In_Setup=0;
 }
bool datetime::Is_Leap(uint16_t Year_In)
{if((Year_In%4) == 0)
 {
  if((Year_In%100) == 0)
  {
    if((Year_In%400) == 0)
    {return 1;}
    else
    {return 0;}
  }
  else
  {return 1;}
 }
 return 0;
}

 void datetime::Set_Stamp(uint32_t Stamp_In)
 {In_Setup=1;
  Stamp=Stamp_In;
  if(Stamp>=Stamp_Max)
  {
    Stamp=Stamp-Stamp_Max;
  }
  In_Setup=0;
 }

 uint32_t datetime::Get_Stamp()
 {return Stamp;}
 uint16_t datetime::Get_Year()
 {return Year;}
 uint8_t datetime::Get_Month()
 {return Month+1;}
 uint8_t datetime::Get_Day()
  {return Day+1;}
 uint8_t datetime::Get_Hour()
 {return Hour;}
 
 uint8_t datetime::Get_Minute()
 {return Minute;}
 uint8_t datetime::Get_Second()
 {return Second;}
