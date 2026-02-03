
import struct
import zlib

def check_transparency(filename):
    try:
        with open(filename, 'rb') as f:
            signature = f.read(8)
            if signature != b'\x89PNG\r\n\x1a\n':
                print(f"{filename} is not a valid PNG")
                return

            while True:
                chunk_header = f.read(8)
                if not chunk_header:
                    break
                length, chunk_type = struct.unpack('!I4s', chunk_header)
                
                if chunk_type == b'IHDR':
                    data = f.read(length)
                    width, height, bit_depth, color_type, _, _, _ = struct.unpack('!IIBBBBB', data)
                    print(f"Dimensions: {width}x{height}, Color Type: {color_type}")
                    if color_type != 6:
                        print("Not an RGBA PNG.")
                        return
                    f.read(4) # CRC
                elif chunk_type == b'IDAT':
                    compressed_data = f.read(length)
                    data = zlib.decompress(compressed_data)
                    # Check first few pixels' alpha
                    # Each row has a filter byte (1 byte)
                    # RGBA = 4 bytes per pixel
                    has_transparency = False
                    for i in range(0, len(data), 4 * 100 + 1): # sample
                        row = data[i+1:i+1+4*10]
                        for j in range(3, len(row), 4):
                            if row[j] < 255:
                                has_transparency = True
                                break
                        if has_transparency: break
                    
                    if has_transparency:
                        print("Transparent pixels found.")
                    else:
                        print("No transparent pixels found in sample.")
                    f.read(4) # CRC
                elif chunk_type == b'IEND':
                    break
                else:
                    f.seek(length + 4, 1)
    except Exception as e:
        print(f"Error: {e}")

check_transparency('/Users/jw/workspace/coffee-note-app/assets/images/app_icon_v9_python.png')
