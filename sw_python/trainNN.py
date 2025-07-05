import network2
import numpy as np
from PIL import Image
import os
import json

def load_custom_data(directory):
    images = []
    labels = []

    for filename in os.listdir(directory):
        if filename.endswith(".png"):
            image = Image.open(os.path.join(directory, filename))
            image = image.convert('L')  # Ensure the image is in grayscale
            if image.size != (28, 28):
                continue  # Skip images that don't match the expected size
            image = np.array(image, dtype=np.float32).reshape(784)
            images.append(image / 255.0)  # Normalize pixel values
            # Assign labels based on filename or directory structure
            labels.append(1 if 'circle' in filename else 0)

    return np.array(images), np.array(labels)

# Load your custom images from the directory
images, labels = load_custom_data('C:/Users/eusou/Documents/GitHub/NN-on-FPGA/python/train_data_img')

# Function to split data into train, validation, and test sets
def split_data(images, labels, train_ratio=0.7, val_ratio=0.2):
    total = len(images)
    train_end = int(total * train_ratio)
    val_end = int(total * (train_ratio + val_ratio))
    
    training_images, training_labels = images[:train_end], labels[:train_end]
    validation_images, validation_labels = images[train_end:val_end], labels[train_end:val_end]
    test_images, test_labels = images[val_end:], labels[val_end:]
    
    return (training_images, training_labels), (validation_images, validation_labels), (test_images, test_labels)

# Split the data
(training_images, training_labels), (validation_images, validation_labels), (test_images, test_labels) = split_data(images, labels)

# Prepare the data in the format expected by the Network
training_data = [(x.reshape(784, 1), np.array([y]).reshape(1, 1)) for x, y in zip(training_images, training_labels)]
validation_data = [(x.reshape(784, 1), np.array([y]).reshape(1, 1)) for x, y in zip(validation_images, validation_labels)]
test_data = [(x.reshape(784, 1), np.array([y]).reshape(1, 1)) for x, y in zip(test_images, test_labels)]

# Initialize the network; adjust the architecture as needed
net = network2.Network([784, 30, 30, 10, 1])  # Example architecture

# Train the network
net.SGD(training_data, 30, 10, 0.1, lmbda=5.0, evaluation_data=validation_data, monitor_evaluation_accuracy=True)

# Save the trained network weights and biases
net.save("WeightsAndBiases.txt")
