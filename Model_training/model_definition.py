from tensorflow import keras
from tensorflow.keras import layers

#Define tunable CNN model
def build_model(drop_out):
  #Input layers
  BVP_input = keras.Input(shape=(320, 1), name='BVP_in')
  ACCx_input = keras.Input(shape=(160, 1), name='ACCx_in')
  ACCy_input = keras.Input(shape=(160, 1), name='ACCy_in')
  ACCz_input = keras.Input(shape=(160, 1), name='ACCz_in')
  TEMP_input = keras.Input(shape=(20, ), name='TEMP_in')


  #BVP feature layers
  BVP_1 = layers.Conv1D(2, 16, strides=2, activation='relu', input_shape=(None, 320, 1), name='BVP_1')(BVP_input)
  BVP_1 = layers.MaxPool1D(4, strides=2)(BVP_1)
  BVP_1 = layers.Dropout(drop_out)(BVP_1)
  BVP_2 = layers.Conv1D(4, 8, strides=1, activation='relu', name='BVP_2')(BVP_1)
  BVP_2 = layers.MaxPool1D(4, strides=1)(BVP_2)
  BVP_2 = layers.Dropout(drop_out)(BVP_2)
  BVP_2 = layers.Flatten()(BVP_2)

  #ACC feature layers
  ACCx_1 = layers.Conv1D(2, 16, activation='relu', name='ACCx_1', input_shape=(None, 160, 1))(ACCx_input)
  ACCx_1 = layers.MaxPool1D(4, strides=2)(ACCx_1)
  ACCx_1 = layers.Dropout(drop_out)(ACCx_1)
  ACCx_1 = layers.Flatten()(ACCx_1)

  ACCy_1 = layers.Conv1D(2, 16, activation='relu', name='ACCy_1', input_shape=(None, 160, 1))(ACCy_input)
  ACCy_1 = layers.MaxPool1D(4, strides=2)(ACCy_1)
  ACCy_1 = layers.Dropout(drop_out)(ACCy_1)
  ACCy_1 = layers.Flatten()(ACCy_1)

  ACCz_1 = layers.Conv1D(2, 16, activation='relu', name='ACCz_1', input_shape=(None, 160, 1))(ACCz_input)
  ACCz_1 = layers.MaxPool1D(4, strides=2)(ACCz_1)
  ACCz_1 = layers.Dropout(drop_out)(ACCz_1)
  ACCz_1 = layers.Flatten()(ACCz_1)

  #Flatten Concatenate
  x = layers.concatenate([BVP_2, ACCx_1, ACCy_1, ACCz_1, TEMP_input])

  #Decision layers
  Decision = layers.Dense(32, activation='relu')(x)
  Decision = layers.Dense(16, activation='relu')(Decision)
  Decision = layers.Dense(8, activation='relu')(Decision)
  Decision = layers.Dense(1, activation='sigmoid', name='Prediction')(Decision)

  model = keras.Model(inputs=[
    BVP_input,
    ACCx_input,
    ACCy_input,
    ACCz_input,
    TEMP_input], outputs= [Decision])

  #model.compile(loss=loss, optimizer=meta['optimizer'], metrics=['accuracy'])
  model.compile(loss=keras.losses.binary_crossentropy, optimizer=keras.optimizers.Adam(learning_rate=1e-3), metrics=['accuracy'])
  return model
