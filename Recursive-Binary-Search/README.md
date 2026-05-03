# Recursive Binary Search and Stack-Based Parameter Management

## Overview
This project implements a recursive binary search algorithm designed for the 8086 microprocessor architecture. It provides a low-level interface for users to input a natural number array, validate its sorting order, and perform high-speed searches using a divide-and-conquer strategy.

## Technical Features

### 1. Stack-Based Parameter Passing
Unlike register-based architectures, this implementation relies entirely on the stack for procedure communication to demonstrate advanced memory management:
* **Parameter Isolation**: The program pushes the array base address, low index, high index, and search key onto the stack before each call.
* **Stack Return Mechanism**: Instead of using registers like AX for results, the program reserves a placeholder on the stack for the return index or error codes (-1).
* **Frame Pointer Management**: Uses the Base Pointer (BP) to create stable stack frames, allowing for relative addressing of parameters despite recursive depth.

### 2. Recursive Logic Implementation
The binary search is implemented as a true recursive procedure (`BINARY_SEARCH`):
* **Base Case Analysis**: The algorithm checks if the low bound exceeds the high bound to terminate search attempts.
* **Midpoint Calculation**: Efficiently determines the middle index using `SHR` (Shift Right) to perform division by 2.
* **Recursive Branching**: Dynamically adjusts bounds and initiates new procedure calls for the left or right halves of the dataset until the key is found or exhausted.

### 3. Data Validation
To ensure algorithm reliability, a pre-search validation routine is included:
* **IS_SORTED Subroutine**: An iterative check that verifies the input array is in strictly ascending order before allowing search operations.
* **Boolean Flagging**: Returns a 0/1 status via the stack to indicate validation success.

## Implementation Specifications
* **Array Capacity**: Supports up to 10 natural numbers.
* **Memory Management**: Uses `RET n` instructions to ensure proper stack cleanup (yığın dengesi) after recursive calls.
* **Interactive Interface**: Features a continuous search loop that supports a 'q' character command for clean program termination.
