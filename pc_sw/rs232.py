#!/usr/bin/env python
from __future__ import print_function
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv

assert len(argv) == 4
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)
fp_key = open('key.bin', 'rb')
fp_enc = open(argv[2], 'rb')
fp_dec = open(argv[3], 'wb')

key = fp_key.read(64)
enc = fp_enc.read()
#assert len(enc) % 32 == 0
s.write(key)
for i in range(0, len(enc), 32):
    s.write(enc[i:i+32])
    dec = s.read(31)
    fp_dec.write(dec)

fp_key.close()
fp_enc.close()
fp_dec.close()
