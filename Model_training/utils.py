import numpy as np
#===========util functions=================
#Adapted from keras-hypetune
#https://github.com/cerlymarco/keras-hypetune/blob/master/kerashypetune/utils.py
def create_fold(X, ids):
    """Create folds from the data received.
    Returns
    -------
    array/list or arrays/dict of arrays containing fold data.
    """

    if isinstance(X, list):
        return [x[ids] for x in X]

    elif isinstance(X, dict):
        return {k: v[ids] for k, v in X.items()}

    else:
        return X[ids]

def normalize(batch_in):
  std = batch_in.std(axis=1)[:,:,np.newaxis]
  u = batch_in.mean(axis=1)[:,:,np.newaxis]

  return (batch_in-u)/std
