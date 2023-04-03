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

def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val

def main():

    parser = argparse.ArgumentParser(description="Generate memory contents (W, X, R) of ExtMem", formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-b", "--bitwidth", type=int, default=0, help="Element Bitwidth")
    parser.add_argument("-f", "--actfun", type=int, default=0, help="Activation Function")
    parser.add_argument("-a", type=int, default=1, help="Subword selection")
    parser.add_argument("-k", type=int, default=1, help="Arrangement of W and X in memory")
    parser.add_argument("-M", type=int, default=2, help="Dimension M")
    parser.add_argument("-N", type=int, default=2, help="Dimension N")
    args = parser.parse_args()

    if args.bitwidth != 0 and args.bitwidth != 1:
        logging.error("Invalid value for b. Must be 0 (8 bit elements) or 1 (16 bit elements).")
        sys.exit(1)

    if args.actfun != 0 and args.actfun != 1 and args.actfun !=2:
        logging.error("Invalid value for f. Must be 0 (SWS), 1 (ReLu) or 2 (tanh)")
        sys.exit(1)

    if args.bitwidth:
        if args.a < 0 or args.a > 32:
            logging.error("Invalid value for a. Must be an integer between 0 and 32.")
            sys.exit(1)

        if args.k < 0 or args.k > 3:
            logging.error("Invalid value for k. Must be an integer between 0 and 3.")
            sys.exit(1)
    else:
        if args.a < 0 or args.a > 24:
            logging.error("Invalid value for a. Must be an integer between 0 and 24.")
            sys.exit(1)

        if args.k < 0 or args.k > 7:
            logging.error("Invalid value for k. Must be an integer between 0 and 7.")
            sys.exit(1)

    if args.M < 1 or args.M > 64 or args.N < 1 or args.N > 64:
        logging.error("Invalid value for M or N. Must be integers between 1 and 64.")
        sys.exit(1)

    b = 16 if args.bitwidth else 8
    twos_comp_v = numpy.vectorize(twos_comp)

    W = numpy.random.randint(0, 2**b, (args.M, args.N))
    X = numpy.random.randint(0, 2**b, (args.N, 1))
    R = numpy.matmul(twos_comp_v(W, b), twos_comp_v(X, b))

    k = args.k if args.k else XLEN//b

    with open("ExtMem.bin", 'w') as mem:
        for index in range((args.M*args.N) // k):
            line = ''
            for w in numpy.ndarray.flatten(W)[index*k:(index+1)*k]:
                line = str(int(bin(w)[2:])).zfill(b) + line

            mem.write(line.zfill(XLEN) + "\n")

        if (args.M*args.N % k):
            line = ''
            for w in numpy.ndarray.flatten(W)[((args.M*args.N) // k) * k : ((args.M*args.N) // k) * k + args.M*args.N % k]:
                line = str(int(bin(w)[2:])).zfill(b) + line
            mem.write(line.zfill(XLEN) + "\n")

        for index in range(int(args.N/k)):
            line = ''
            for x in numpy.ndarray.flatten(X)[index*k:(index+1)*k]:
                line = str(int(bin(x)[2:])).zfill(b) + line

            mem.write(line.zfill(XLEN) + "\n")

        if (args.N % k):
            line = ''
            for x in numpy.ndarray.flatten(X)[(args.N // k) * k : (args.N // k) * k + args.N % k]:
                line = str(int(bin(x)[2:])).zfill(b) + line
            mem.write(line.zfill(XLEN) + "\n")

    with open("R.bin", 'w') as f:
        for r in numpy.nditer(R):
            f.write(str(int(bin(r if r > 0 else 2**(48 if Grad else 32) - abs(r))[2:])).zfill(XLEN)+"\n")

    with open("W.mat", 'w') as f:
        for w in numpy.nditer(W):
            f.write(str(twos_comp(w, b))+"\n")
 
    with open("X.mat", 'w') as f:
        for x in numpy.nditer(X):
            f.write(str(twos_comp(x, b))+"\n")

    with open("R.mat", 'w') as f:
        for r in numpy.nditer(R):
            f.write(str(r)+"\n")

if __name__ == "__main__":
    main()
