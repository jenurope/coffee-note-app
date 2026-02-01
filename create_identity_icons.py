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
def draw_v15(x, y, w, h):
    # Background: Dark Coffee #2B1B17
    # Foreground: Gold #D4AF37
    bg, fg = (43, 27, 23), (212, 175, 55)
    cx, cy = w/2, h/2
    dx, dy = (x - cx)/0.8, (y - cy)/1.2
    
    if dx*dx + dy*dy < 280**2:
        # Pen nib slit + hole
        slit_w = 12
        if abs(dx) < slit_w and dy < 100: return bg
        if dx*dx + (dy-120)**2 < 30**2: return bg # Nib hole
        return fg
    return bg

# V16: Top-down Cup with Log Lines
def draw_v16(x, y, w, h):
    # Background: Matte Black #1A1A1A
    # Foreground: Cream #F5F5DC
    bg, fg = (26, 26, 26), (245, 245, 220)
    cx, cy = w/2, h/2
    dx, dy = x - cx, y - cy
    dist = math.sqrt(dx*dx + dy*dy)
    
    # Outer Cup
    if 240 < dist < 260: return fg
    # Handle
    if 240 < dx < 320 and -60 < dy < 60:
        if (dx-250)**2 + dy*dy < 70**2 and (dx-250)**2 + dy*dy > 40**2: return fg
    # "Log" lines inside cup
    if dist < 200:
        if abs(dy) % 60 < 10 and -120 < dx < 120: return fg
    return bg

# V17: Modern Checkbox (Box + Bean)
def draw_v17(x, y, w, h):
    # Background: Terracotta #A0522D
    # Foreground: White #FFFFFF
    bg, fg = (160, 82, 45), (255, 255, 255)
    
    # Rounded Box
    if 250 < x < 774 and 250 < y < 774:
        # Checkmark as a stylized bean slit
        cx, cy = 512, 512
        dx, dy = (x - cx)/0.5, (y - cy)/0.7
        if dx*dx + dy*dy < 150**2:
            if abs(dx - 30*math.sin(dy/50)) < 10: return bg
            return fg
        # Outline only
        if not (270 < x < 754 and 270 < y < 754): return fg
    return bg

for i, func in enumerate([draw_v15, draw_v16, draw_v17], 15):
    filename = f'/Users/jw/.gemini/antigravity/brain/c836824c-eb45-4c64-9de3-8eaf3e492b38/app_icon_v{i}.png'
    with open(filename, 'wb') as f:
        f.write(make_png(1024, 1024, func))
    print(f"Created {filename}")
