import json
import tensorflow as tf
from sklearn.model_selection import train_test_split
import numpy as np
import os
import cv2
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# Function to load images from a folder
def load_images_from_folder(folder):
    images = []
    labels = []
    for filename in os.listdir(folder):
        img = cv2.imread(os.path.join(folder, filename), cv2.IMREAD_GRAYSCALE)
        if img is not None:
            images.append(img)
            labels.append(1 if 'circles' in folder else 0)
    return images, labels

# Load images from both folders
circles_images, circles_labels = load_images_from_folder(os.path.join('dataset', 'circles'))
nocircles_images, nocircles_labels = load_images_from_folder(os.path.join('dataset', 'nocircles'))

# Combine the images and labels
images = np.array(circles_images + nocircles_images, dtype=np.float32)
labels = np.array(circles_labels + nocircles_labels, dtype=np.float32)

# Split the dataset into training and testing sets
x_train, x_test, y_train, y_test = train_test_split(images, labels, test_size=0.2, random_state=42)

# Normalize the images
x_train = tf.keras.utils.normalize(x_train, axis=1)
x_test = tf.keras.utils.normalize(x_test, axis=1)

# Reshape the images to fit the model (28x28 images and 1 channel for grayscale)
x_train = x_train.reshape(-1, 28, 28, 1)
x_test = x_test.reshape(-1, 28, 28, 1)

model = tf.keras.models.Sequential()
model.add(tf.keras.layers.Flatten())
model.add(tf.keras.layers.Dense(128, activation=tf.nn.sigmoid))
model.add(tf.keras.layers.Dense(64, activation=tf.nn.sigmoid))
model.add(tf.keras.layers.Dense(1, activation=tf.nn.sigmoid))

model.compile(optimizer='adam',
              loss='binary_crossentropy',  # Updated loss function
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=50)

(val_loss, val_accuracy) = model.evaluate(x_test, y_test)

# Extract weights and biases
weightList = []
biasList = []
for i in range(1,len(model.layers)):
    weights = model.layers[i].get_weights()[0]
    weightList.append((weights.T).tolist())
    bias = [[float(b)] for b in model.layers[i].get_weights()[1]]
    biasList.append(bias)

data = {"weights": weightList,"biases":biasList}
f = open('weightsandbias.txt', "w")
json.dump(data, f)
f.close()
