
# MEDIAN FILTER IMAGE PROCESSING PROJECT 

## This project focuses on real-time image processing using a median filter to enhance image quality. By integrating an external camera module, the system captures video streams, processes the data using FPGA-based logic, and displays the filtered output via the board's VGA interface. The design ensures efficient and accurate processing for live image enhancement.

##THIS REPOSITORY CONTAINS THE MODULE WITHOUT CONNECTION TO OUTSIDE PERIPERIHALS


### This project implements an image processing project which :
#### INPUT -> image, which streams to the IP core with salt and pepper noise 
#### OUTPUT -> clear image using median filter algorithm 

### KEY BLOCKS  :
#### 1. ODD EVEN algorithm for sorting the pixels arrived
#### 2. Three block rams connected to 3 SRL (SHIFT REGISTER) to implement a 3x3 matrix

