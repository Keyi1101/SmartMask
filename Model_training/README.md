# Model_training

## Code Annotation
### WESAD.py
Contains functions for preprocessing the WESAD dataset.

### utils.py
Contains utility functions.

### model_definition.py
Defines the general structure of the Stress Inference model.

### model_selection.py
Script to perform Cross-validated grid search and prints results.



## Stress Detection Model
## There are short introductions of our algorithm, more details can be read in reports.
### Dataset selection and manipulation
- The WESAD is an open-sourced dataset with physiological signals and corresponding affective states measured from volunteers. 
- Table below shows A list of signals used in the training of Stress Inference model.
-![image](https://github.com/Keyi1101/SmartMask/blob/main/picture/SignalList.png)


### Defining the stress Inference model
- use one-dimensional convolution layers instead of perceptron layers to do feature extraction.
- reduces the number of hyperparameters needs to be trained and consequently solves the problem of overfitting.
- regularization techniques were introduced to further combat overfitting


### Model selection and validation
- add dropout layers between convolution layers
- Dropout layers randomly disable neurons during training, thus reducing the layers' probability of generalizing towards noise. 







