# SmartMask
This is project with MF Technology
Video is available at: https://imperiallondon-my.sharepoint.com/personal/kw2618_ic_ac_uk/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fkw2618%5Fic%5Fac%5Fuk%2FDocuments%2Fmask%2Em4v&parent=%2Fpersonal%2Fkw2618%5Fic%5Fac%5Fuk%2FDocuments


## Folder Annotation
- Node.js 
  - aws-node-rest-api-with-dynamodb 
  - DB_pressure_get
  - DB_pressure 
 
- Fultter APP
  - test_app
  - There is a screenshot of our user friendly app we designed.
![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/app.png)

- Algorithm
  - Model_deployment
  - Model_training
  - see more in README of folders

- Hardware Code
  - ArduinoCode 
  - see more in README of ArduinoCode folder

- Grafana Json Package
  - Intelligent Mask Grafana Dashboard JSON.json
  - Grafana Dashboard helps users to track their histry data and understand their healthy situations better. 
![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/grafana.png)

## Project Detail
### General design and structure

   - The picture below shows the front and the back side of our mask with different sensors being labelled. The accelerometer, Bluetooth module, MCU and battery are placed on the front side of the mask since their functions are irrelevant of the environment inside the mask.
![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/mask.png)

   - To achieve our project goal, we need to save all data from users at Cloud. We choose AWS Serveless as our Cloud Server. The whole structure of data flow is clealy expained at figure below. It is worth to know that we use Node.js as a bridge to connect app with AWS DynamoDB. 
![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/flowchart.png)

### Project management

   - We use Gantt Chart to set our ddl which make sure we are on time and prevent overwork before the ddl.
![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/timeline.png)

### Future Work 
   - Better way we power our mask
   - Integrate all sensors
   - Commercialize the mask





