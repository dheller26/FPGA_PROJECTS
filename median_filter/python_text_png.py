import numpy as np
from PIL import Image

# Step 1: Load the text file
filename = 'house_color_filtered.txt'  # Replace with your text file
with open(filename, 'r') as file:
    data = file.readlines()

# Step 2: Parse the text file into a 2D array
# Assuming the text file contains rows of space-separated pixel values
pixels = [list(map(int, line.split())) for line in data]

# Convert the list to a NumPy array
array = np.array(pixels, dtype=np.uint16)  # dtype=np.uint16 for 0-65535 range
                 #np.uint8)  # dtype=np.uint8 for 0-255 range


# Step 3: Create the image
image = Image.fromarray(array)

# Step 4: Save the image as PNG
output_filename = 'house_color_filtered_v2.png'
image.save(output_filename)

print(f"Image saved as {output_filename}")
