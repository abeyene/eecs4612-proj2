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
# column major order for viewing.
#
# Usage:
#
# python ExtMem.py [-M m] [-N n]

import random
import numpy 
import argparse
import os
import sys
import logging

Bits = 8
XLEN = 64
MemSize= 2**16

def main():

    parser = argparse.ArgumentParser(description="Generate memory contents (W, X, R) of ExtMem", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-M", type=int, default=2, help="Dimension M")
    parser.add_argument("-N", type=int, default=2, help="Dimension N")
    parser.add_argument("-f", "--force", action="store_true", default=False, help="Override existing memory")
    args = parser.parse_args()

    if args.M < 1 or args.M > 64 or args.N < 1 or args.N > 64:
        logging.error("Invalid value or M or N (must be between 1 and 64)")
        sys.exit(RET_FAIL)

    if not args.force:
        if(os.path.isfile("ExtMem.bin")):
            logging.error("ExtMem.bin already exists. Re-run with -f/--force to override it.")

    W = numpy.random.randint(0, 2**Bits - 1, (args.M, args.N))
    X = numpy.random.randint(0, 2**Bits - 1, (args.N, 1))
    R = numpy.matmul(W, X)

    with open("ExtMem.bin", 'w') as mem:
        for w in numpy.nditer(W.T.copy(order='C')):
            mem.write(str(int(bin(w)[2:])).zfill(XLEN)+"\n")
        
        for x in numpy.nditer(X.T.copy(order='C')):
            mem.write(str(int(bin(x)[2:])).zfill(XLEN)+"\n")

    with open("R.bin", 'w') as f:
        for r in numpy.nditer(R.T.copy(order='C')):
            f.write(str(int(bin(r)[2:])).zfill(XLEN)+"\n")

    with open("W.mat", 'w') as f:
        for w in numpy.nditer(W.T.copy(order='C')):
            f.write(str(w)+"\n")
 
    with open("X.mat", 'w') as f:
        for x in numpy.nditer(X.T.copy(order='C')):
            f.write(str(x)+"\n")

    with open("R.mat", 'w') as f:
        for r in numpy.nditer(R.T.copy(order='C')):
            f.write(str(r)+"\n")

if __name__ == "__main__":
    main()
