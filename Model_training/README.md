# Model_training

## Code Annotation
- WESAD.py
   - Contains functions for preprocessing the WESAD dataset.

- utils.py
   - Contains utility functions.

- model_definition.py
  - Defines the general structure of the Stress Inference model.

- model_selection.py
  - Script to perform Cross-validated grid search and prints results.



## Stress Detection Model
- There are short introductions of our algorithm, more details can be read in reports.
### Dataset selection and manipulation
- we use WESAD which is an open-sourced dataset with physiological signals and corresponding affective states measured from volunteers. 
- The values in the dataset are measured using Empatica 4
- Table below shows A list of signals used in the training of Stress Inference model.
-![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/SignalList.png)


### Defining the stress Inference model
- use one-dimensional convolution layers instead of perceptron layers to do feature extraction, which reduces the number of hyperparameters needs to be trained and consequently solves the problem of overfitting.
- regularization techniques were introduced to further combat overfitting
- architecture is shown below
![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/Screen%20Shot%202021-06-23%20at%209.37.36%20PM.png)


### Model selection and validation
- add dropout layers between convolution layers
- Dropout layers reduce the layers' probability of generalizing towards noise. 







