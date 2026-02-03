
import zlib
import struct
import math

def make_png(width, height, draw_func):
    # RGBA PNG
    png = b'\x89PNG\r\n\x1a\n'
    ihdr_content = struct.pack('!IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = b'IHDR' + ihdr_content
    png += struct.pack('!I', len(ihdr_content)) + ihdr + struct.pack('!I', zlib.crc32(ihdr) & 0xFFFFFFFF)

    raw_data = b''
    for y in range(height):
        raw_data += b'\x00' # Filter type
        for x in range(width):
            raw_data += bytes(draw_func(x, y, width, height))
    
    compressor = zlib.compressobj()
    idat_data = compressor.compress(raw_data) + compressor.flush()
    idat = b'IDAT' + idat_data
    png += struct.pack('!I', len(idat_data)) + idat + struct.pack('!I', zlib.crc32(idat) & 0xFFFFFFFF)
    png += struct.pack('!I', 0) + b'IEND' + struct.pack('!I', zlib.crc32(b'IEND') & 0xFFFFFFFF)
    return png

def draw_white_bean_transparent(x, y, w, h):
    # Transparent background (0, 0, 0, 0)
    # White bean (255, 255, 255, 255)
    cx, cy = w/2, h/2
    dx, dy = (x - cx), (y - cy)
    
    # Scale to fit safe zone (Android 12: 72dp circle in 108dp square)
    # Reducing scale further to 0.45 to ensure it's well within the 72/108 (~0.66) safe zone.
    scale = 0.45
    nx, ny = dx / (w * scale / 2), dy / (h * scale / 2)
    
    # Bean shape (ellipse-ish)
    dist_sq = nx*nx + (ny/1.5)**2
    if dist_sq < 1.0:
        # S-curve slit
        slit = 0.15 * math.sin(ny * 3)
        if abs(nx - slit) < 0.08:
            return (0, 0, 0, 0) # Transparent slit
        return (255, 255, 255, 255) # White bean
        
    return (0, 0, 0, 0)

with open('/Users/jw/workspace/coffee-note-app/assets/images/app_icon_white_transparent.png', 'wb') as f:
    f.write(make_png(512, 512, draw_white_bean_transparent))
print("Created app_icon_white_transparent.png")
