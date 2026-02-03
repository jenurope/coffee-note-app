
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

def draw_option1_refined(x, y, w, h):
    cx, cy = w/2, h/2 * 1.1 # Lower a bit for steam
    dx, dy = x - cx, y - cy
    
    # Scale for safe zone
    scale = 0.55
    nx, ny = dx / (w * scale / 2), dy / (h * scale / 2)
    
    white = (255, 255, 255, 255)
    trans = (0, 0, 0, 0)

    # 1. Cup (Clean line art bowl)
    dist_bowl = nx*nx + (ny/0.7)**2
    if 0.5 < dist_bowl < 0.65 and ny > -0.1:
        return white
    if ny > 0.4 and abs(nx) < 0.45 and ny < 0.5: # Bottom line
        return white

    # 2. Handle
    hdx, hdy = nx - 0.72, ny - 0.15
    if 0.08 < hdx*hdx + hdy*hdy < 0.16 and hdx > 0:
        return white

    # 3. Steam Line with Pen Nib
    # Curved line
    sdx = nx - 0.15 * math.sin((ny + 0.5) * 4)
    if -0.9 < ny < -0.1:
        if abs(sdx) < 0.04: return white
    
    # Pen Nib at the top
    ndx, ndy = nx - 0.15 * math.sin((-0.9 + 0.5) * 4), ny + 0.95
    if abs(ndx) < 0.2 and -0.1 < ndy < 0.3:
        # Nib triangle
        width_at_y = 0.18 * (1 - (ndy + 0.1) / 0.45)
        if abs(ndx) < width_at_y:
            # Slit
            if abs(ndx) < 0.01 and ndy < 0.1: return trans
            # Small circle hole
            if ndx*ndx + (ndy-0.12)**2 < 0.001: return trans
            return white

    return trans

with open('/Users/jw/workspace/coffee-note-app/assets/images/splash_logo_final.png', 'wb') as f:
    f.write(make_png(512, 512, draw_option1_refined))
print("Created splash_logo_final.png")
