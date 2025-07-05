# 🤖 FPGA MLP Circle Detector

This project aimed to implement a **Multi-Layer Perceptron (MLP)** neural network on an FPGA (Altera DE2-115) to recognize **hand-drawn circles** via VGA and mouse, 
unfortunately it was not completed, due to the high complexity of implementing neurons and interconnecting them on the de2 board using only HW, 
using a more state of the art board and hardware-software co-design would be easier.

> 📚 **Course**: PDigital Systems Design (PSD)  
> 🏫 **Institution**: Universidade de Coimbra – DEEC  
> 🧠 **Supervision**: Prof. Jorge Dias  
> 👥 **Authors**: Gonçalo Bastos (2020238997), Leonardo Cordeiro (2020228071)

---

## 🧠 Project Overview

The project aims to explore the feasibility of deploying a neural network directly on hardware for real-time classification tasks. It consists of:

- Pre-trained MLP using **Python (network2/TensorFlow)**
- Fixed-point arithmetic implementation
- VGA drawing area (28x28 px) via **mouse input**
- On-chip **Neuronal Network Inference** using Verilog
- Output: prediction of circle vs non-circle

---

## 📐 System Architecture

1. **Input**: VGA screen + Mouse input (user draws a shape)
2. **Pre-processing**: VGA logic captures a 28x28 area in RAM
3. **Inference Engine**:
   - Modular Verilog **Neuron**
   - 5-layer MLP
   - **Weights/Bias loaded via `.mif` files**
   - Fixed-point arithmetic
4. **Output**: Binary classification displayed via LEDs or VGA

![Overview of FPGA neuron](<img width="376" alt="neuron" src="https://github.com/user-attachments/assets/bcd59f94-ae94-4e09-8ca0-8ea72bf61ea7" />
) <!-- Add an actual overview diagram here -->

---

## 🔧 Hardware Components

| Module              | Description                                     |
|---------------------|-------------------------------------------------|
| `neuron.v`          | Single neuron with parameterized inputs/weights|
| `sigmoid.v`         | LUT-based activation function                  |
| `vga.v`             | VGA controller for drawing                     |
| `mouse.v`           | Mouse decoder module                           |
| `input_ram.v`       | RAM for 28x28 pixel drawing capture            |
| `top_level.v`       | MLP integration and control FSM                |

---

## 🧪 Training and Deployment

- Training done using **Python** and the `network2` library
- Output weights and biases exported to **`.mif` files**
- Network architecture:
    Input (784) → [30] → [30] → [10] → [10] → [1]


---

## 📦 Project Contents

- `hw_fpga/`: Verilog HDL files for the MLP and interface
- `sw_python/`: Scripts for training and generating `.mif`
- `project/`: Quartus project files
- `docs/`: Reports, presentation and documentation


