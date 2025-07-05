import sys
import os
from PIL import Image

outputPath = "./testData/"
headerFilePath = "./testData/"
directory = "C:/Users/eusou/Documents/GitHub/NN-on-FPGA/python/test_data_img"

import numpy as np

dataWidth = 16                    #specify the number of bits in test data
IntSize = 1 #Number of bits of integer portion including sign bit

try:
    testDataNum = int(sys.argv[1])
except:
    testDataNum = 3

def DtoB(num,dataWidth,fracBits):                        #funtion for converting into two's complement format
    if num >= 0:
        num = num * (2**fracBits)
        d = int(num)
    else:
        num = -num
        num = num * (2**fracBits)        #number of fractional bits
        num = int(num)
        if num == 0:
            d = 0
        else:
            d = 2**dataWidth - num
    return d


def load_custom_data(directory):
    images = []
    # Load images from directory
    for filename in os.listdir(directory):
        if filename.endswith(".png"):  # Ensure you're only loading .png files
            image_path = os.path.join(directory, filename)
            image = Image.open(image_path)
            image = image.convert('L')  # Convert to grayscale
            image_array = np.array(image)
            images.append(image_array.flatten())  # Flatten the 28x28 image to a 1D array of 784 pixels
    return images

def genTestData(dataWidth, IntSize, directory):
    headerFilePath = "./testData/"
    outputPath = "./testData/"
    
    images = load_custom_data(directory)
    print(f"Total images loaded: {len(images)}")  # Confirm the number of images loaded

    for idx, image in enumerate(images):
        dataHeaderFile = open(headerFilePath + f"dataValues_{idx}.h", "w")
        dataHeaderFile.write("int dataValues[]={")
        
        test_input = np.reshape(image, (784, 1))
        d = dataWidth - IntSize
        count = 0
        fileName = f'test_data_{idx}.txt'
        f = open(outputPath + fileName, 'w')
        visualFileName = f'visual_data_{idx}.txt'
        g = open(outputPath + visualFileName, 'w')
        k = open(outputPath + f'testData_{idx}.txt', 'w')

        for i in range(len(test_input)):
            pixel_value = test_input[i][0]
            k.write(str(pixel_value) + ',')
            dInDec = DtoB(pixel_value, dataWidth, d)
            myData = bin(dInDec)[2:].zfill(dataWidth)
            dataHeaderFile.write(str(dInDec) + ',')
            f.write(myData + '\n')
            # Writing visual data
            if pixel_value > 150:
                g.write('0 ')
            else:
                g.write('1 ')
            count += 1
            if count % 28 == 0:
                g.write('\n')

        k.close()
        g.close()
        f.close()
        dataHeaderFile.write('0};\n')
        dataHeaderFile.write(f'int result=1;\n')  # Assuming all are circles for now
        dataHeaderFile.close()

# Usage example
genTestData(16, 1, 'C:/Users/eusou/Documents/GitHub/NN-on-FPGA/python/test_data_img')

'''      
def genAllTestData(dataWidth,IntSize):
    tr_d, va_d, te_d = load_data('C:/Users/eusou/Documents/GitHub/NN-on-FPGA/python/data')
    test_inputs = [np.reshape(x, (1, 784)) for x in te_d[0]]
    x = len(test_inputs[0][0])
    d=dataWidth-IntSize
    for i in range(len(test_inputs)):
        if i < 10:
            ext = "000"+str(i)
        elif i < 100:
            ext = "00"+str(i)
        elif i < 1000:
            ext = "0"+str(i)
        else:
            ext = str(i)
        fileName = 'test_data_'+ext+'.txt'
        f = open(outputPath+fileName,'w')
        for j in range(0,x):
            dInDec = DtoB(test_inputs[i][0][j],dataWidth,d)
            myData = bin(dInDec)[2:]
            f.write(myData+'\n')
        f.write(bin(DtoB((te_d[1][i]),dataWidth,0))[2:])
        f.close()



if __name__ == "__main__":
    genTestData(dataWidth,IntSize,testDataNum=4)
    #genAllTestData(dataWidth,IntSize)
'''