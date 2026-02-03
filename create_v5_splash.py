
import zlib
import struct
import math

def make_png_v5_pro(width, height, draw_func):
    # Pro RGBA with 4x4 supersampling for maximum smoothness
    ss = 4 
    
    png = b'\x89PNG\r\n\x1a\n'
    ihdr_content = struct.pack('!IIBBBBB', width, height, 8, 6, 0, 0, 0)
    ihdr = b'IHDR' + ihdr_content
    png += struct.pack('!I', len(ihdr_content)) + ihdr + struct.pack('!I', zlib.crc32(ihdr) & 0xFFFFFFFF)

    raw_data = b''
    for y in range(height):
        if y % 200 == 0: print(f"Rendering row {y}...")
        raw_data += b'\x00'
        for x in range(width):
            r_sum, g_sum, b_sum, a_sum = 0, 0, 0, 0
            for sy in range(ss):
                for sx in range(ss):
                    px = x + (sx + 0.5) / ss
                    py = y + (sy + 0.5) / ss
                    cr, cg, cb, ca = draw_func(px, py, width, height)
                    r_sum += cr * (ca / 255.0)
                    g_sum += cg * (ca / 255.0)
                    b_sum += cb * (ca / 255.0)
                    a_sum += ca
            
            samples = ss * ss
            avg_a = int(a_sum / samples)
            if avg_a > 0:
                # Weighted average to preserve color accuracy on semi-transparent edges
                avg_r = int(r_sum / (a_sum / 255.0)) if a_sum > 0 else 0
                avg_g = int(g_sum / (a_sum / 255.0)) if a_sum > 0 else 0
                avg_b = int(b_sum / (a_sum / 255.0)) if a_sum > 0 else 0
                raw_data += bytes([avg_r, avg_g, avg_b, avg_a])
            else:
                raw_data += bytes([255, 255, 255, 0]) # White transparent
    
    compressor = zlib.compressobj(level=9)
    idat_data = compressor.compress(raw_data) + compressor.flush()
    idat = b'IDAT' + idat_data
    png += struct.pack('!I', len(idat_data)) + idat + struct.pack('!I', zlib.crc32(idat) & 0xFFFFFFFF)
    png += struct.pack('!I', 0) + b'IEND' + struct.pack('!I', zlib.crc32(b'IEND') & 0xFFFFFFFF)
    return png

def draw_legendary_coffee_v5(x, y, w, h):
    cx, cy = w/2, h/2 * 1.08
    dx, dy = x - cx, y - cy
    
    # Scale adjustment for Android 12 compliance (keep everything in center 66%)
    s = 0.55
    nx, ny = dx / (w * s / 2), dy / (h * s / 2)
    
    white = (255, 255, 255, 255)
    trans = (0, 0, 0, 0)

    # 1. Cup Body (Solid filled for better visibility)
    # Using a soft corner rectangle/bowl mix
    if ny > -0.1 and ny < 0.4 and abs(nx) < 0.7 - (ny * 0.2):
        # Round bottom
        if ny > 0.3:
            if nx*nx + (ny-0.1)**2 < 0.3: return white
        else:
            return white

    # Refined cup shape using distance field
    bowl_dist = nx*nx + (ny/0.8)**2
    if bowl_dist < 0.45 and ny < 0.4 and ny > -0.1:
        return white
    
    # Cup handle
    hdx, hdy = nx - 0.65, ny - 0.15
    if 0.04 < hdx*hdx + hdy*hdy < 0.12 and hdx > 0:
        return white
        
    # Saucer
    sdx, sdy = nx, ny - 0.55
    if (sdx/1.1)**2 + (sdy/0.2)**2 < 0.4 and 0 < sdy < 0.1:
        return white

    # Steam trail to Pen Nib
    steam_y = ny + 0.5
    if -0.9 < steam_y < 0.1:
        off_x = 0.12 * math.sin(steam_y * 4.5)
        if abs(nx - off_x) < 0.04: # Slightly thicker line (0.04)
            return white
            
    # Pen Nib
    pdx, pdy = nx - 0.12 * math.sin(-0.9 * 4.5), ny + 0.95
    if abs(pdx) < 0.22 and -0.15 < pdy < 0.4:
        w_at_y = 0.22 * (1 - (pdy + 0.1) / 0.5)
        if abs(pdx) < w_at_y:
            # Slit and Hole (Professional details)
            if abs(pdx) < 0.015 and pdy < 0.15: return trans
            if pdx*pdx + (pdy-0.2)**2 < 0.0015: return trans
            return white

    return trans

with open('/Users/jw/workspace/coffee-note-app/assets/images/splash_v5_pro_transparent.png', 'wb') as f:
    f.write(make_png_v5_pro(1024, 1024, draw_legendary_coffee_v5))
print("Created splash_v5_pro_transparent.png")
