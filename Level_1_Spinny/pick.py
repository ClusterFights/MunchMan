#!/usr/bin/env python3

#<------------------------------------------- 100 characters ------------------------------------->|

import sys
import os
import random
import hashlib
import argparse

STR_LEN = 19

DESC =  \
"""

 This script reads in a manifest.txt file
 that was created with manifest.py.  It
 then selects a file at random, then
 selects a 19 character string starting
 from a random offset.  It then calculates
 the MD5 hash of the string. It outputs
 the file index into the manifest, the file name,
 the file offset, the selected string, and the
 MD5 hash.
"""

# NOTE : Interesting test cases
# ./pick.py -i 439 -o 90560

# parse the command line arguments
parser = argparse.ArgumentParser(description=DESC)
parser.add_argument("manifest", nargs="?", help="The manifiest.txt file. "
                   "Default is manifest.txt", default="manifest.txt")
parser.add_argument("-i", "--index", type=int, help="Use this book index. "
                    "Instead of random.")
parser.add_argument("-o", "--offset", type=int, help="Use this file offset. "
                    "Instead of random.")
parser.parse_args()
args = parser.parse_args()

# Check the manifest file
manifest = args.manifest
if not os.path.isfile(manifest):
    print("ERROR: Not a file: ",manifest)
    sys.exit()

# Parse the manifest.
file_list = []
with open(manifest, 'r') as fp:
    for cnt, line in enumerate(fp):
        if cnt>1:
            size_str, file_path = line.split()
            file_list.append((int(size_str),file_path))

# Select file from dataset
num_files = len(file_list)
if args.index is None:
    index = random.randrange(num_files)
else:
    index = args.index

# Get info about the file
size = file_list[index][0]
file_path = file_list[index][1]

# Select random substring
max_offset = size - STR_LEN
if args.offset is None:
    str_offset = random.randint(0,max_offset)
else:
    str_offset = args.offset

# Extract the string
# NOTE : Use latin-1 encoding to map byte values directly
# to first 256 Unicode code points.  Generates
# no exceptions, unlike utf-8.
with open(file_path, mode="r", encoding="latin-1") as fp:
    fp.seek(str_offset)
    latin_str = fp.read(STR_LEN)

# Compute the hash of byte_str
byte_str = latin_str.encode()
md5 = hashlib.md5()
md5.update(byte_str)

# Print selection
print("file_index: {} out of {}".format(index,num_files))
print("file_path: ",file_path)
print("str_offset: ",str_offset)
#print('latin_str: "{}"'.format(latin_str))
print('byte_str: {}'.format(byte_str))
print('hash: {}'.format(md5.hexdigest()))

if len(latin_str) != len(byte_str):
    print("WARNING: latin_str and byte_str not the same length")
    print("   len(latin_str): ",len(latin_str))
    print("   len(byte_str): ",len(byte_str))
    print("   latin_str: ",latin_str)


