import zlib
import struct
import math

def make_png(width, height, draw_func, is_rgba=False):
    png = b'\x89PNG\r\n\x1a\n'
    color_type = 6 if is_rgba else 2
    ihdr_content = struct.pack('!IIBBBBB', width, height, 8, color_type, 0, 0, 0)
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

# V15: Bean + Pen Nib (Coffee + Logging)
def draw_v15_solid(x, y, w, h):
    bg, fg = (43, 27, 23), (212, 175, 55)
    cx, cy = w/2, h/2
    dx, dy = (x - cx)/0.8, (y - cy)/1.2
    
    if dx*dx + dy*dy < 280**2:
        slit_w = 12
        if abs(dx) < slit_w and dy < 100: return bg
        if dx*dx + (dy-120)**2 < 30**2: return bg
        return fg
    return bg

def draw_v15_transparent(x, y, w, h):
    fg = (212, 175, 55, 255)
    cx, cy = w/2, h/2
    # Scale down for adaptive safe zone (approx 0.6 of 1024)
    dx, dy = (x - cx)/0.6, (y - cy)/0.8
    
    if dx*dx + dy*dy < 250**2:
        slit_w = 15
        if abs(dx) < slit_w and dy < 80: return (0,0,0,0)
        if dx*dx + (dy-100)**2 < 25**2: return (0,0,0,0)
        return fg
    return (0, 0, 0, 0)

with open('assets/images/app_icon.png', 'wb') as f:
    f.write(make_png(1024, 1024, draw_v15_solid))

with open('assets/images/app_icon_foreground.png', 'wb') as f:
    f.write(make_png(1024, 1024, draw_v15_transparent, is_rgba=True))

print("V15 Final Icons Generated.")
