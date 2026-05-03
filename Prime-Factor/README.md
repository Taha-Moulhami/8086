# 32-bit Prime Factorization and Modular Procedure Design

## Overview
This project implements a 32-bit integer processor capable of analyzing a list of nine 32-bit numbers. It performs primality testing, full prime factorization, and maximum factor identification.

## Technical Features
### 1. 32-bit Arithmetic Engine
The implementation handles 32-bit values on a 16-bit architecture using the following:
* **32-bit I/O**: Custom procedures `GETN32` and `PUTN32` manage data via the `DX:AX` register pair.
* **Extended Precision**: Custom 32-bit division (`DIV32_16`) and 32-bit right-shifting (`SHR32_1`) support the factorization algorithm.

### 2. Advanced Parameter Passing Methods
The program demonstrates three distinct procedure-calling conventions:
* **Register-Based**: `IS_PRIME` receives 32-bit input through registers.
* **Segment-Based**: `FACTORIZE` operates on shared data structures in the DSG segment.
* **Mixed Stack and Pointer Passing**: `MAX_FACTOR_PROC` uses the stack frame (BP) to receive a count by value and a destination by pointer.

### 3. Macro Integration
MASM macros `READ_ARRAY` and `PRINT_ARRAY` are used to automate repetitive array traversal and I/O logic.

