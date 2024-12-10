import math
import string
f = open("sine.mem","w")
for i in range(65536): # 256 steps
    v = int(math.cos(2*3.1416*i/256)*127+127) # 255 is 1 (max, high), 127 is 0, 0 is -1 (min, low) 
    # Format it such that 16 numbers a row
    if (i+1)%16 == 0:
        s = "{hex:2X}\n"
    else:
        s = "{hex:2X} "
    f.write(s.format(hex=v))

f.close()