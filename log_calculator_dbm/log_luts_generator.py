import math

# Generate the first LUT file
def generate_first_rom(filename="lut1.txt"):
    with open(filename, "w") as f:
        for row in range(32):
            value = 3.010 * row
            #fixed value for the keeping precision
            value =value *4096
            
            #f.write(f"{int(value):.6f}\n")  # Writing value with six decimal precision
            # f.write(f"{int(value)}\n")  # Writing decimal
            f.write(f"{int(value):08X}\n")  # Writing decimal but need hex
# Generate the second LUT file
def generate_second_rom(filename="lut2.txt"):
    with open(filename, "w") as f:
        for row in range(16):
            value = 10 * math.log10(1 + row / 16)
            #fixed value for the keeping precision
            value =value *4096
            #f.write(f"{int(value):.6f}\n")  # Writing value with six decimal precision
            # f.write(f"{int(value)}\n")  # Writing decimal
            f.write(f"{int(value):08X}\n")  # Writing decimal but need hex
# Generate both ROM files
generate_first_rom("integer_lut_no_square.txt")
generate_second_rom("precision_lut_no_square.txt")

print("LUT files generated: lut1.txt and lut2.txt")
