#Performs a Cross-validated grid search on CNN_Stress_model hyperparameters
import os
from WESAD import *
from tensorflow import keras
from model_definition import build_model
from utils import *
from sklearn.model_selection import KFold
from tensorflow.keras.callbacks import EarlyStopping, LearningRateScheduler
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '1' 

#=======Load Dataset=====================
#Assume dataset in current working directory
path = os.getcwd() + '/WESAD/'
wrist_data = load_wrist(load_files(path))
#=======Define search grid & CrossValidation scheme=============
augmentation = [0.7, 0.8, 0.9]
drop_out = [0.1, 0.2, 0.3]
n_splits = 7
cv = KFold(n_splits=n_splits, shuffle=False)
#=======Callbacks=============
def scheduler(epoch, lr):
  if(epoch >0):
    if(epoch%15):
      return lr
    else:
      return lr*0.46
  else:
    return lr

es = EarlyStopping(patience=5, min_delta=0.0001, monitor='val_accuracy', verbose=1)
lr_scheduler = LearningRateScheduler(scheduler)
#========GridSearchCV===============
total_search = len(augmentation)*len(drop_out)
search_hist = []
search = 0
for i in augmentation:
  X, Y = get_unbiased_data(create_dataset(wrist_data, augmentation_factor=i, verbose=0), verbose=0)
  X['BVP_in'] = normalize(X['BVP_in'])

  for j in drop_out:
    #model = build_model(j)
    print("="*10, search+1, '/', total_search, '='*10)
    print("Search: aug= {}, drop= {}".format(i, j))
    fold_hist = []

    for fold, (train_idx, val_idx) in enumerate(cv.split(X['BVP_in'])):
      model = build_model(j)
      X_train = create_fold(X, train_idx)
      Y_train = create_fold(Y, train_idx)
      X_val = create_fold(X, val_idx)
      Y_val = create_fold(Y, val_idx)
      print("*"*5, fold+1, '/', n_splits, '*'*5)
      history = model.fit(X_train, Y_train,
                  validation_data=(X_val, Y_val),
                  epochs=100, batch_size=40,
                  callbacks=[es, lr_scheduler],
                  verbose=0)
      fold_hist.append(history)
      idx = np.argmax(history.history['val_accuracy'])
      print("Train_accuracy= {}, Val_accuracy= {}, @epochs= {}".format(
          history.history['accuracy'][idx],
          history.history['val_accuracy'][idx],
          idx+1))

    search_hist.append(fold_hist)
    search += 1
print("="*10, "End of GridSearchCV", "="*10)
print("\n", "="*10, "Evaluation", "="*10)
#==========Evaluation================
search_idx = 0
for i in search_hist:
  avg_train = 0
  avg_val = 0
  avg_epoch = 0

  for j in i:
    idx = np.argmax(j.history['val_accuracy'])
    avg_epoch += idx + 1
    avg_train += j.history['accuracy'][idx]
    avg_val += j.history['val_accuracy'][idx]

  print('='*5, "Search: {}".format(search_idx + 1), '='*5)
  print("avg_train_acc = {}, avg_val_acc = {}, avg_epoch = {}".format(avg_train/7, avg_val/7, avg_epoch/7))
  search_idx += 1

  #Results: aug = 0.9, drop = 0.2
