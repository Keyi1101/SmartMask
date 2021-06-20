#Contains functions to load and manipulate WESAD dataset for training

#============load_siles()============
#path: String path to WESAD dataset folder
#load the entire WESAD, returns list with entries containing
#data for each subject
#============load_wrist()============
#data: List input from load_files
#Extract wrist signals and corresponding affactive state label
#for each WESAD subject, returns dataframe with 1 row for each WESAD subject
#===========create_dataset()===============
#datadrame: Dataframe input from load_wrist
#relax_factor: (0, 1] float, minimum allowed percentage of samples in a window
#with different label
#augmentation_factor: [0,1) float, Determines the stride of the window
#to sample from the WESAD dataset,
#larger factor -> smaller stride -> more training samples
#verbose: 0=silence
#Returns Dict with list of samples and label for each samples
#============get_unbiased_data()============
#dataset: Dict input from create_dataset()
#FC: (Deprecated) choice to format input to be passed into a FC model
#seed: int, random_state for shuffling, default to None
#verbose: 0=silence
#Returns formatted input X (Dict) ready for trainning and corresponding label
#Ground truths with 50% 1, 50% 0

import os
import pickle
import numpy as np
import pandas as pd
from sklearn.utils import shuffle


def load_files(path = "/content/WESAD/"):
  l = []
  try:
      for dir in os.listdir(path):
        if(dir.startswith('S')):
          with open(os.path.join(path, dir, dir + ".pkl"), "rb") as f:
            tmp = pickle.load(f, encoding="bytes")
            l.append(tmp)
  except:
      print("Please specify a correct file path to the WESAD folder.")

  return l

def load_wrist(data):
  subject = []
  BVP = []
  ACC = []
  TEMP = []
  EDA = []
  label = []
  for i in data:
    subject.append(i[b'subject'])
    BVP.append(i[b'signal'][b'wrist'][b'BVP'])
    ACC.append(i[b'signal'][b'wrist'][b'ACC'])
    TEMP.append(i[b'signal'][b'wrist'][b'TEMP'])
    EDA.append(i[b'signal'][b'wrist'][b'EDA'])
    label.append(i[b'label'])

  df = pd.DataFrame({
      "subject": subject,
      "BVP": BVP,
      "ACC": ACC,
      "TEMP": TEMP,
      "EDA": EDA,
      "label": label
  })
  return df

def create_dataset(dataframe, relax_factor=0.95, augmentation_factor=0.5, verbose=1):
  if augmentation_factor >= 1:
    raise Exception("Invalid aug factor! ", augmentation_factor)

  BVP = []
  ACC = []
  TEMP = []
  EDA = []
  label = []
  count = 0
  for i in dataframe.index:
    label_i = dataframe['label'][i]
    BVP_i = dataframe['BVP'][i]
    ACC_i = dataframe['ACC'][i]
    TEMP_i = dataframe['TEMP'][i]
    EDA_i = dataframe['EDA'][i]
    ##time_frame = len(dataframe['label'][i])/700
    ##size = int(time_frame/5)
    length = len(dataframe['label'][i])
    aug = 1 - augmentation_factor
    stride = int(3500 * aug)
    stride_B = int(320 * aug)
    stride_A = int(160 * aug)
    stride_T = int(20 * aug)
    stride_E = int(20 * aug)
    n = int((length - 3500)/stride + 1)
    #no.samples = int((length - window)/stride + 1)
    for j in range(n):
      #filter data with label 1, 2, 3 > 95%
      label_ij = label_i[j*stride:j*stride+3500]
      if((label_ij==1).mean() >= relax_factor):
        label.append(1)
        BVP.append(BVP_i[j*stride_B:j*stride_B+320])
        ACC.append(ACC_i[j*stride_A:j*stride_A+160])
        TEMP.append(TEMP_i[j*stride_T:j*stride_T+20])
        EDA.append(EDA_i[j*stride_E:j*stride_E+20])
        count += 1
      elif((label_ij==2).mean() >= relax_factor):
        label.append(2)
        BVP.append(BVP_i[j*stride_B:j*stride_B+320])
        ACC.append(ACC_i[j*stride_A:j*stride_A+160])
        TEMP.append(TEMP_i[j*stride_T:j*stride_T+20])
        EDA.append(EDA_i[j*stride_E:j*stride_E+20])
        count += 1
      elif((label_ij==3).mean() >= relax_factor):
        label.append(3)
        BVP.append(BVP_i[j*stride_B:j*stride_B+320])
        ACC.append(ACC_i[j*stride_A:j*stride_A+160])
        TEMP.append(TEMP_i[j*stride_T:j*stride_T+20])
        EDA.append(EDA_i[j*stride_E:j*stride_E+20])
        count += 1
  BVP = np.array(BVP)
  ACC = np.array(ACC)
  TEMP = np.array(TEMP)
  EDA = np.array(EDA)
  label = np.array(label)

  if verbose > 0:
    print("BVP: ", BVP.shape)
    print("ACC: ", ACC.shape)
    print("TEMP: ", TEMP.shape)
    print("EDA: ", EDA.shape)
    print("label: ", label.shape)
    print("no. of samples: ", count)

    sum = 0
    for i in dataframe.index:
      sum += len(dataframe['label'][i])

    print("no. of samples from raw data: ", int(sum/3500))
    print("Percentage of converted samples: ", count/int(sum/3500))

  return {
      'BVP': BVP,
      'ACC': ACC,
      'TEMP': TEMP,
      'EDA': EDA,
      'label': label,
      'sample': count
  }

def get_unbiased_data(dataset, FC=False, seed=None, verbose=1):
  #stress: 2 -> 1
  #baseline: 1 -> 0
  length = min((dataset['label']==1).sum(), (dataset['label']==2).sum())
  mask_b = dataset['label']==1
  mask_s = dataset['label']==2

  label = np.append(dataset['label'][mask_b][:length], dataset['label'][mask_s][:length], axis=0)
  label = np.asarray(label - 1, dtype=np.int32)
  BVP = np.append(dataset['BVP'][mask_b][:length], dataset['BVP'][mask_s][:length], axis=0).squeeze()
  ACC = np.append(dataset['ACC'][mask_b][:length], dataset['ACC'][mask_s][:length], axis=0)
  TEMP = np.append(dataset['TEMP'][mask_b][:length], dataset['TEMP'][mask_s][:length], axis=0).squeeze()
  EDA = np.append(dataset['EDA'][mask_b][:length], dataset['EDA'][mask_s][:length], axis=0).squeeze()

  BVP, ACC, TEMP, EDA, label = shuffle(BVP, ACC, TEMP, EDA, label, random_state=seed)
  if verbose > 0:
    print("Total number of unbiased training samples: ", len(label))

  if FC:
    X = {
        'BVP_in': BVP,
        'ACCx_in': ACC[:,:,0],
        'ACCy_in': ACC[:,:,1],
        'ACCz_in': ACC[:,:,2],
        'TEMP_in': TEMP
    }

  else:
    X = {
        'BVP_in': BVP[:,:,np.newaxis],
        'ACCx_in': ACC[:,:,0][:,:,np.newaxis],
        'ACCy_in': ACC[:,:,1][:,:,np.newaxis],
        'ACCz_in': ACC[:,:,2][:,:,np.newaxis],
        'TEMP_in': TEMP
    }
  return X, label
