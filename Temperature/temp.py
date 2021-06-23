import tensorflow as tf
import numpy as np
import csv

directory="tempdata.csv"
with open(directory,"r") as file:
    reader = csv.reader(file)
    Temp_Pack=list(reader)

Temp_Pack.pop(0)
Temp_Pack=np.array(Temp_Pack)
Temp_Resp=[]
Temp_Env=[]
Temp_Oral=[]
for data_t in Temp_Pack:
    Temp_Resp.append((float(data_t[0])-33))
    Temp_Env.append((float(data_t[1])-32))
    Temp_Oral.append((float(data_t[2])-36.5))
Temp_Resp=np.array(Temp_Resp)
Temp_Env=np.array(Temp_Env)
Temp_Oral=np.array(Temp_Oral)

y_set=Temp_Oral.reshape((30,1))

x_set=np.zeros((30,3))
for i in range (len(Temp_Env)):
    tmp=np.array([1,Temp_Resp[i], Temp_Env[i]])
    x_set[i]=tmp
print(x_set)

N_of_feature_in=2
N_of_data_per_iteration=1
N_of_feature_out=1
x_in=tf.placeholder(tf.float32,shape=(30,N_of_feature_in+1),name="x_in")
y_in=tf.placeholder(tf.float32,shape=(30,N_of_feature_out),name="y_in")

W=tf.Variable([[0.0],[0.0],[0.0]],name="W")

#数据运算流程的定义
Out_Pr=tf.matmul(x_in,W)
Cost=tf.reduce_sum(tf.norm((Out_Pr-y_in),2))/30

optimizer=tf.train.AdamOptimizer(learning_rate=0.005).minimize(Cost)
init_op=tf.global_variables_initializer()
sess=tf.Session()
sess.run(init_op)
max_iteration=9994
His=[]
for o in range (1):
    #Tcost=0
    for j in range (max_iteration):
        tmpc=sess.run((optimizer,Cost),feed_dict={x_in:x_set.reshape((-1,N_of_feature_in+1)),y_in:y_set.reshape((-1,N_of_feature_out))})
        His.append(tmpc[1])

print(His)
Weight=sess.run(W)
print(Weight)
