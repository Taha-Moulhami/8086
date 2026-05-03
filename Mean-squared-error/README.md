# Mean Squared Error (MSE)

## Overview
This project implements the **Mean Squared Error** algorithm in 16-bit Assembly. MSE is a critical metric in signal processing and machine learning, used to measure the average squared difference between estimated values and actual observations.

The core logic focuses on calculating the average of squared errors from two distinct datasets:
*   **Dataset 1 (D1):** `10, 1, -3, 7, 0
*   **Dataset 2 (D2):** `5, 5, 8, -6, 9`

## Implementation Details
The program executes the following sequence:
1.  **Difference Calculation:** Iterates through arrays using `SI` and `DI` pointers to find the difference between elements.
2.  **Signed Squaring:** Uses the `IMUL` instruction to handle signed integer squaring.
3.  **32-bit Accumulation:** Since squaring numbers can quickly exceed 16-bit limits, the program uses `ADD` and `ADC` (Add with Carry) to maintain a 32-bit `SUM`.
4.  **Averaging:** Performs a final division by `N` to store the result in the `MSE` variable.

## Source Files
*   `Lab1.asm`: The primary assembly source code.
*   `bin/`: Contains the generated `.obj` and `.exe` binaries.

## Debugging & Verification
The implementation was verified through `DEBUG.EXE`, ensuring that the `SUM` and `MSE` values in the Data Segment align with the expected mathematical results.
