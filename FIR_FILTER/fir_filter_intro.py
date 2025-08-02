# implementation of a simple FIR filter in Python - moving average

import numpy as np
import matplotlib.pyplot as plt

# this function is use to preform convertion from signed binary to the signed decimal representation
def signed_binary_to_decimal(binary_data,bits):
    if(len(binary_data) <=bits):
        n=int(binary_data,2)
        s=1<< (bits-1) # sign bit
        return (n&s -1) - (n & s) # convert to signed decimal    
    else:
        raise ValueError("Binary data length exceeds specified bits")

#comment for the abpve function:    
"""
        If the sign bit is not set (positive number):
        n & s = 0 → result becomes (-1) - magnitude = -(magnitude + 1)
        → But this is incorrect for positives, so this only works when sign bit is set.

        If the sign bit is set (negative number):
        n & s = 128, s - 1 = 127, and the subtraction undoes the two’s complement
    
"""

#we need to compute a binary representation of the filter coefficients when :
#number of coeff:
tap=8
#for computing first scale, we want to rpresent filter coefficients in 8 bits
N1=8
#this is used to convert the filter inputs to 16 bits signed binary
N2=16
#this is theoutput bit length
N3=32


real_coeff=(1/tap)

#bit rpesentation of the filter coefficients
coeff_bit=np.binary_repr(int(real_coeff * (1 << N1-1)), width=N1) # convert to binary and scale
print(f"Filter coefficients in binary: {coeff_bit}")
#double check , invert , it should be equal to real_coeff
real_coeff_check = signed_binary_to_decimal(coeff_bit, N1) / (1 << N1-1)

print(f"Check coefficients: {real_coeff_check} (should be close to {real_coeff})")

timeVector=np.linspace(0,2*np.pi,100) # time vector for one period

output=np.sin(2*timeVector)+np.sin(3*timeVector)+0.3*np.sin(2*timeVector)+0.3*np.random.randn(len(timeVector))

plt.plot(output, label='Input Signal to Filter')
plt.show()

#convert to integer representation
# this list contains the N2-bt signed binary representation of the sin sequence 
list1=[]
for number in output: 
    list1.append(np.binary_repr(int(number * (1 << N1-1)), width=N2)) # convert to binary and scale

#save the converted sequence to a file
with open('input_signal.txt', 'w') as f:
    for item in list1:
        f.write("%s\n" % item)

#after this lie we need the vivado testbench 

read_results = []
#read the output from the testbench
with open('filtered.txt', 'r') as f:
    for line in f:
        read_results.append(line.strip('\n'))

converted_results = []
#convert the read results to decimal
for item in read_results:
    converted_results.append(signed_binary_to_decimal(item, N3) / (1 << (2*(N1-1))))  # convert to decimal and scale
#plot the results
plt.plot(output,color='blue', linewidth=3 ,label='Input Signal')
plt.plot(converted_results,color='red', linewidth=3 ,label='Filtered Signal')
plt.legend()
plt.savefig('fir_filter_output.png', dpi=600)
plt.show()