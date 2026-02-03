
import zlib
import struct
import math

def make_png(width, height, draw_func):
    png = b'\x89PNG\r\n\x1a\n'
    ihdr_content = struct.pack('!IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = b'IHDR' + ihdr_content
    png += struct.pack('!I', len(ihdr_content)) + ihdr + struct.pack('!I', zlib.crc32(ihdr) & 0xFFFFFFFF)

    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'
        for x in range(width):
            raw_data += bytes(draw_func(x, y, width, height))
    
    compressor = zlib.compressobj()
    idat_data = compressor.compress(raw_data) + compressor.flush()
    idat = b'IDAT' + idat_data
    png += struct.pack('!I', len(idat_data)) + idat + struct.pack('!I', zlib.crc32(idat) & 0xFFFFFFFF)
    png += struct.pack('!I', 0) + b'IEND' + struct.pack('!I', zlib.crc32(b'IEND') & 0xFFFFFFFF)
    return png

def draw_cup_pen_splash(x, y, w, h):
    cx, cy = w/2, h/2
    dx, dy = x - cx, y - cy
    
    # Scale adjustment for Android 12 safe zone
    scale = 0.5
    nx, ny = dx / (w * scale / 2), dy / (h * scale / 2)
    
    # White color (255, 255, 255, 255)
    # Transparent (0, 0, 0, 0)
    white = (255, 255, 255, 255)
    trans = (0, 0, 0, 0)

    # 1. Cup body (Bowl shape)
    # x^2 + (y/0.8)^2 < 1 and y > -0.2
    if nx*nx + (ny/0.8)**2 < 0.6 and ny > -0.1:
        return white
    
    # 2. Cup handle
    # (x-0.7)^2 + y^2 < 0.1 but not (x-0.7)^2 + y^2 < 0.04
    hdx, hdy = nx - 0.7, ny - 0.2
    if 0.05 < hdx*hdx + hdy*hdy < 0.15:
        if hdx > 0: return white

    # 3. Pen Nib / Steam
    # Stylized triangle on top
    pdx, pdy = nx, ny + 0.6
    if abs(pdx) < 0.15 and -0.4 < pdy < 0.2:
        # Tapered shape
        width_at_y = 0.15 * (1 - (pdy + 0.4) / 0.6)
        if abs(pdx) < width_at_y:
            # Slit in middle
            if abs(pdx) < 0.01 and pdy < 0: return trans
            return white
            
    return trans

with open('/Users/jw/workspace/coffee-note-app/assets/images/splash_logo_new.png', 'wb') as f:
    f.write(make_png(512, 512, draw_cup_pen_splash))
print("Created splash_logo_new.png")
