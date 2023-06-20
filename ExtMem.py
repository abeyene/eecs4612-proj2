#!/usr/bin/env python

# EECS 4612 Digital VLSI
# York University

# ExtMem.py

# Description:
#
# Python script to generate the contents of the
# external memory module (W, X, R) for the ASIC 
# test harness. The randomly generated arrays
# are also stored in separate files (.mat) in
# row major order for viewing.

import random
import numpy 
import argparse
import os
import sys
import logging

Grad = False
XLEN = 64
csize = 1025
rsize = 12818

def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val

def main():

    parser = argparse.ArgumentParser(description="Generate memory contents (W, X, R) of ExtMem", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-b", "--bitwidth", type=int, default=1, help="Element Bitwidth")
    args = parser.parse_args()

    if args.bitwidth != 0 and args.bitwidth != 1:
        logging.error("Invalid value for b. Must be 0 (8 bit elements) or 1 (16 bit elements).")
        sys.exit(1)

    b = 16 if args.bitwidth else 8
    twos_comp_v = numpy.vectorize(twos_comp)

    logpost = numpy.random.randint(0, 2**b, (csize, rsize))

    #k = XLEN//b
    k = 1

    with open("ExtMem.bin", 'w') as mem:
        for index in range((csize*rsize) // k):
            line = ''
            for w in numpy.ndarray.flatten(logpost)[index*k:(index+1)*k]:
                line = str(int(bin(w)[2:])).zfill(b) + line

            mem.write(line.zfill(XLEN) + "\n")

        if ((csize*rsize) % k):
            line = ''
            for w in numpy.ndarray.flatten(logpost)[((csize*rsize) // k) * k : ((csize*rsize) // k) * k + (csize*rsize) % k]:
                line = str(int(bin(w)[2:])).zfill(b) + line
            mem.write(line.zfill(XLEN) + "\n")

    with open("logpost.dat", 'w') as f:
        for lp in numpy.nditer(logpost):
            f.write(str(twos_comp(lp, b))+"\n")
 
if __name__ == "__main__":
    main()
