# This project will implement serial communication using the FPGA UART port 
## THE project is done on the NEXYS A7 using VERILOG 
### Method of operation :
#### 1. Create genric modules for Rx and Tx that deals with all rates of UART TRANSMISSIONS
#### 2. The top hierarchy takes the two modules and performs a loop back, which echo the recieved data to serial monitor  
#### 3. We need to create an FSM dealing with new lines in the TOP module.


