import os
import sys
import binascii
 
INPUT = "data"
OUTPUT = "data.bin"
 
s = open(INPUT)
lines = s.readlines()
with open(OUTPUT, 'w') as f:
    for line in lines:
        newline = line[6:8] + line[4:6] + line[2:4] + line[0:2]
        b = bin(int(newline, 16))
        num = int(b[2:])
        f.write('%032d'%num)
        f.write('\n')