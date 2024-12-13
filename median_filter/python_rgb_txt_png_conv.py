import numpy as np
from PIL import Image

# Function to convert RGB444 to RGB888
def rgb444_to_rgb888(rgb444):
    r4 = (rgb444 >> 8) & 0xF
    g4 = (rgb444 >> 4) & 0xF
    b4 = rgb444 & 0xF
    r8 = (r4 << 4) | r4  # Scale 4-bit to 8-bit
    g8 = (g4 << 4) | g4  # Scale 4-bit to 8-bit
    b8 = (b4 << 4) | b4  # Scale 4-bit to 8-bit
    # return r4, g4, b4
    return b8, g8, r8

# Step 1: Load the text file
filename = 'house_color_filtered.txt'  # Replace with your text file
with open(filename, 'r') as file:
    data = file.readlines()

# Step 2: Parse the text file into a 3D array
# Assuming the text file contains rows of space-separated RGB444 values
height = len(data)
width = len(data[0].split())
rgb_array = np.zeros((height, width, 3), dtype=np.uint8)

for y, line in enumerate(data):
    rgb444_values = list(map(int, line.split()))
    for x, rgb444 in enumerate(rgb444_values):
        rgb_array[y, x] = rgb444_to_rgb888(rgb444)

# Step 3: Create the image
image = Image.fromarray(rgb_array)

# Step 4: Save the image as PNG
output_filename = 'house_color_filtered_v2.png'
image.save(output_filename)

print(f"Image saved as {output_filename}")
