# Hardware Code

## Sensors and Connections

![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/connection.png)

##  Heart Rate
   - The PPG sensor used is MAX30102.
   - Peaks of heart rate are located by looking for peaks of the cross correlation of PPG IR and red signals.
   - Such method minimizes the effect of the noise from other light sources.
   - The peak detection provides reliable result when both the IR and red signal are well-captured

## Peripheral Oxygen Saturation (SpO2)
   - The same Red and IR PPG signal with Heart Rate
   - Same peak detection algorithm with Heart Rate but there is an improvement, including a cross correlation filter that removes low correlated IR and Red to avoid invalid readings

## Respiration Rate and Oral Temperature
   - Respiration Rate and oral temperature are the two most important indicators of COVID-19 related symptoms. 
   - Environment temperature measured by MCP9808 at 12.5Hz is used to improve the prediction of oral temperature。
   - The respiration rate and oral temperature are both derived from exhaled temperature. 
   - The exhaled temperature varies with breathing periodically. Based on this property, respiration rate can be extracted by looking for the inter-peak intervals of the respiration temperature which is measured by HDC1080 thermistor at 12.5Hzs.
   - The following diagram shows a compact flow chart of the finite state machine compressed data peak detection method. 

![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/hr_temp.png)
   - More Algorithm Details will show in the reports 

## Motion 
   - The motion state is mainly used to determine whether the user is at rest, walking, running, or doing other extreme activities. 

![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/motion.png)


## Operation Mode
   - Low Power Mode, this mode will be entered if the user is not wearing the mask or the battery is low
   - Serverless operation mode: slow update mode, this mode will be entered if the user is wearing the mask, indicating by PPG IR>60000. 
   - Server mode: fast update mode, This mode will be entered if the user is wearing the mask, It can only be automatically entered once for each hour or upon request. 

## Data Management
- After getting and processing the data, it is essential to manage them correctly. The data management system inside the intelligent mask can meet the following requirement:
   - Can store 16.6 minutes processed data and 5 seconds raw measurement data.
   - Given that the storage is not full, data measured will either be sent or stored.
   - Stored unsent data will be sent immediately when Bluetooth is connected.
   - When memory is full, always replace the oldest data with the new data.
   - No real shifting of data happened inside the storage array.







