# Hybrid Matrix Multiplication: C++ and x86 Assembly Integration

## Overview
This project implements a two-dimensional matrix multiplication ($C = A \times B$) using a hybrid approach that combines C++ for high-level management and x86 Assembly for performance-critical computation. The system compares the results of both implementations to ensure mathematical parity and architectural accuracy.

## Technical Architecture
The implementation follows strict x86 calling conventions and memory management protocols within a 32-bit (x86) environment in Visual Studio:
* **High-Level Control**: The C++ layer defines matrices, manages input/output, and handles the performance comparison between the C++ function (`matmul_c`) and the Assembly procedure (`matmul_asm`).
* **Low-Level Procedure**: The Assembly logic is written in a standalone `.asm` file, adhering to the standard procedure skeleton provided for hybrid linkage.

## Technical Features

### 1. Stack-Based Parameter Management
Adhering to strict low-level constraints, the Assembly implementation does not access global variables directly. Instead, it retrieves all necessary data from the stack:
* **Parameter Access**: Uses Base Pointer (EBP) relative addressing (e.g., `[EBP + 8]`, `[EBP + 12]`) to fetch matrix base addresses and dimensions ($A\_rows, A\_cols, B\_cols$).
* **Local Variables**: All loop indices ($i, j, k$) are stored and managed explicitly on the stack to demonstrate manual memory frame control.
* **Register Preservation**: The procedure ensures all register values are preserved upon return to the C++ environment, maintaining system stability.

### 2. Memory Indexing Logic
Since the matrices are stored as one-dimensional arrays in memory, the program implements row-major order indexing:
* **Formula**: To access $A[i, j]$, the program calculates the linear index as $Index = i \times m + j$, where $m$ is the number of columns.
* **Data Type Awareness**: The implementation accounts for the byte-size of the data types defined in C++ (e.g., `int`, `short`) to correctly offset the pointer during memory access.

### 3. Computation Engine
* **Nested Loops**: Implements a triple-nested loop structure in Assembly to handle the dot-product summation required for matrix multiplication.
* **Arithmetic**: Uses 32-bit registers (`EAX`, `EBX`, `ECX`, `EDX`) for efficient multiplication, addition, and address calculation.

## Development Environment
* **Platform**: Microsoft Visual Studio.
* **Architecture**: x86 (32-bit) build configuration.
* **Verification**: The system outputs "Sonuclar AYNI" (Results are SAME) only when the C++ and Assembly outputs match perfectly across all matrix indices.

## Source Files
* `HW1.cpp`: C++ test harness and `matmul_c` implementation.
* `matmul.asm`: x86 Assembly implementation of the matrix multiplication logic.
