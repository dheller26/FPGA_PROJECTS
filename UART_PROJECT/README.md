# This project will implement seiral communication using FPGA UART port 
## THE project is done on the NEXYS A7 using VERILOG 
### Method of operation :
#### 1.using python script we will encode character to 8 bytes and send them to the FPGA 
#### 2. In the FPGA after recieveing each character we will add a constant value which change it's value 
#### 3. The new character will transmit back to the host 
#### 4. The python code will encode the character back to its original value using preapred dictionary which map the character to their modified characters 
