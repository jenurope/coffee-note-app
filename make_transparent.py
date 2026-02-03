
import zlib
import struct
from PIL import Image

def make_transparent(input_path, output_path):
    img = Image.open(input_path).convert("RGBA")
    datas = img.getdata()

    new_data = []
    # The target color is #5D4037 (93, 64, 55)
    # But let's be flexible and make anything "dark brown-ish" transparent
    # while keeping "white-ish" parts.
    for item in datas:
        # If it's bright (white line art), keep it
        if item[0] > 200 and item[1] > 200 and item[2] > 200:
            new_data.append(item)
        else:
            # Make the brown background fully transparent
            new_data.append((0, 0, 0, 0))

    img.putdata(new_data)
    img.save(output_path, "PNG")
    print(f"Transparency applied: {output_path}")

try:
    make_transparent('/Users/jw/workspace/coffee-note-app/assets/images/splash_v3_premium.png', 
                     '/Users/jw/workspace/coffee-note-app/assets/images/splash_v4_transparent.png')
except Exception as e:
    print(f"Error: {e}")
