# Hardware Interfacing: 8255 PPI and 7-Segment Control

![schematic](Screenshot.jpg)


## Overview
This project focuses on interfacing an 8086 microprocessor with the 8255 Programmable Peripheral Interface (PPI) to bridge the gap between CPU logic and external hardware. The system is designed to read input from an 8-button matrix and drive a common anode 7-segment display in real-time.

## Hardware Architecture
The implementation utilizes a standard microprocessor bus architecture:
* **CPU**: 8086 Microprocessor.
* **Address Latch**: 74HC373 for demultiplexing address and data signals.
* **PPI**: 8255 Programmable Peripheral Interface to manage I/O ports.
* **Output**: Common Anode 7-segment display with current-limiting resistors.
* **Input**: 8-button switch array with pull-up/pull-down resistors to ensure stable logic levels.



## Technical Features

### 1. 8255 Port Configuration
The 8255 is initialized via a specific Control Word to define the operational mode and port directions:
* **Port A**: Configured as Output to send 7-segment bit patterns.
* **Port B**: Configured as Input to poll the state of the 8 buttons.
* **Port C**: Configured based on system requirements for auxiliary signals.
* **Addressing**: Precise I/O mapping is implemented to select the Control Register and individual ports.

### 2. Common Anode Display Logic
Since the display is a common anode type, the segment logic is inverted (logic 0 activates a segment). The project includes a pre-calculated mapping table for symbols 0 through 7:
* **Lookup Table (LUT)**: Translates button indices directly into the 7-segment bitmasks required for Port A.
* **Stability**: Logic ensures that a value remains constant on the display while a button is held and updates instantly when a different input is detected.

### 3. Real-Time Polling Loop
The software architecture follows an infinite polling design:
* **Initialization**: Sets the DS register and writes the Control Word to the 8255.
* **Read Phase**: Continuously polls Port B to check for active-high or active-low signals from the button matrix.
* **Update Phase**: Processes the input and writes the corresponding LUT value to Port A.

## Simulation and Verification
The system is fully modeled and verified using Proteus simulation software. The project includes:
* **Circuit Schematic**: Complete wiring of the 8086, 8255, and display components.
* **Timing Accuracy**: Verification of the reset circuit and clock source stability.



## Source Files
* `Peripheral Interfacing 8255.pdsprj`: Proteus project file containing the simulated circuit and code.
* `lab5.asm`: The assembly source code containing port initialization and polling logic.
