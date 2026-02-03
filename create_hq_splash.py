
import zlib
import struct
import math

def make_png_high_quality(width, height, draw_func):
    # RGBA PNG with quality anti-aliasing via supersampling
    supersample = 2 # 2x2 samples per pixel
    
    png = b'\x89PNG\r\n\x1a\n'
    ihdr_content = struct.pack('!IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = b'IHDR' + ihdr_content
    png += struct.pack('!I', len(ihdr_content)) + ihdr + struct.pack('!I', zlib.crc32(ihdr) & 0xFFFFFFFF)

    raw_data = b''
    for y in range(height):
        if y % 100 == 0: print(f"Processing row {y}...")
        raw_data += b'\x00' # Filter type
        for x in range(width):
            # Supersampling
            r, g, b_val, a = 0, 0, 0, 0
            for sy in range(supersample):
                for sx in range(supersample):
                    px = x + sx/supersample
                    py = y + sy/supersample
                    cr, cg, cb, ca = draw_func(px, py, width, height)
                    # Blend based on alpha
                    r += cr * (ca/255)
                    g += cg * (ca/255)
                    b_val += cb * (ca/255)
                    a += ca
            
            samples = supersample * supersample
            avg_a = int(a / samples)
            if avg_a > 0:
                avg_r = int(r / (a/255)) if a > 0 else 0
                avg_g = int(g / (a/255)) if a > 0 else 0
                avg_b = int(b_val / (a/255)) if a > 0 else 0
                raw_data += bytes([avg_r, avg_g, avg_b, avg_a])
            else:
                raw_data += bytes([0, 0, 0, 0])
    
    compressor = zlib.compressobj()
    idat_data = compressor.compress(raw_data) + compressor.flush()
    idat = b'IDAT' + idat_data
    png += struct.pack('!I', len(idat_data)) + idat + struct.pack('!I', zlib.crc32(idat) & 0xFFFFFFFF)
    png += struct.pack('!I', 0) + b'IEND' + struct.pack('!I', zlib.crc32(b'IEND') & 0xFFFFFFFF)
    return png

def draw_premium_cup_v4(x, y, w, h):
    cx, cy = w/2, h/2 * 1.12
    dx, dy = x - cx, y - cy
    
    scale = 0.52
    nx, ny = dx / (w * scale / 2), dy / (h * scale / 2)
    
    white = (255, 255, 255, 255)
    trans = (0, 0, 0, 0)

    # Clean Line Art Cup
    dist_bowl = nx*nx + (ny/0.75)**2
    # Outer edge
    if 0.58 < dist_bowl < 0.65 and ny > -0.15:
        return white
    # Bottom circle join
    if ny > 0.4 and abs(nx) < 0.45 and ny < 0.48:
        return white
    # Handle (more refined)
    hdx, hdy = nx - 0.75, ny - 0.1
    if 0.08 < (hdx/1.2)**2 + hdy*hdy < 0.15 and hdx > 0:
        return white
        
    # Saucer
    sdx, sdy = nx, ny - 0.55
    if 0.4 < (sdx/1.2)**2 + (sdy/0.2)**2 < 0.5 and sdy > 0:
        return white

    # Steam / Pen Nib
    # S-curve steam
    steam_y = ny + 0.55
    if -0.8 < steam_y < 0:
        # Offset x based on sine
        off_x = 0.15 * math.sin(steam_y * 5)
        if abs(nx - off_x) < 0.03: # Thinner line for elegance
            return white
            
    # Professional Pen Nib at top
    pdx, pdy = nx - 0.15 * math.sin(-0.8 * 5), ny + 0.95
    if abs(pdx) < 0.2 and -0.15 < pdy < 0.35:
        # Nib shape
        width_at_y = 0.2 * (1 - (pdy + 0.15) / 0.5)
        if abs(pdx) < width_at_y:
            # Slit
            if abs(pdx) < 0.012 and pdy < 0.12: return trans
            # Eyelet hole
            if pdx*pdx + (pdy-0.15)**2 < 0.0012: return trans
            return white

    return trans

with open('/Users/jw/workspace/coffee-note-app/assets/images/splash_v4_final_premium.png', 'wb') as f:
    f.write(make_png_high_quality(1024, 1024, draw_premium_cup_v4))
print("Created splash_v4_final_premium.png")
