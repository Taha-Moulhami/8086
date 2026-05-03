# Fixed-Point Temperature Conversion & Data Analysis

##  Overview
This project processes raw sensor data from a static array of Celsius values, converting them to Fahrenheit and performing statistical analysis. It demonstrates low-level arithmetic handling for decimal multipliers and threshold-based counting.

The project processes the following Celsius dataset: 
`{0, 11, -273, 72, 100, 27, -33}`.

##  Implementation Details

### 1. Fixed-Point Arithmetic
Since the 8086 microprocessor does not natively support floating-point numbers for the conversion formula $F = (1.8 \times C) + 32$, this implementation uses **fixed-point arithmetic**:
*   Multiplies the Celsius value by 18.
*   Divides the result by 10 to simulate the 1.8 multiplier.
*   Adds 32 to finalize the Fahrenheit conversion.

### 2. Statistical Analysis
After conversion, the program performs two analytical passes:
*   **Average Calculation:** Computes the mean Fahrenheit value across the $N=7$ samples.
*   **Threshold Comparison:** Iterates through the Fahrenheit results to count how many readings exceed the calculated mean.

##  Instructions Used
*   `IMUL / IDIV`: For signed multiplication and division to handle negative temperatures (e.g., -273°C).
*   `LOOP`: For efficient array traversal.
*   `CMP / JL`: To implement the conditional logic for counting values above the average.

##  Source Files
*   `temp_analysis.asm`: The primary assembly source code.
