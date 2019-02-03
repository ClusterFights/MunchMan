#!/usr/bin/env python3

#<------------------------------------------- 100 characters ------------------------------------->|

import sys
import os
import random
import hashlib
import argparse

DESC =  \
"""

 This script reads in a manifest.txt file
 that was created with manifest.py.  It
 then selects a file at random, then
 selects a 19 character string starting
 from a random byte offset.  It then calculates
 the MD5 hash of the string. It outputs
 the file index into the manifest, the file name,
 the file offset, the selected string, and the
 MD5 hash.
"""

# NOTE : Interesting test cases
# ./pick.py -i 439 -o 90560
# ./pick.py -i 198 -o 55481

# parse the command line arguments
parser = argparse.ArgumentParser(description=DESC)
parser.add_argument("manifest", nargs="?", help="The manifiest.txt file. "
                   "Default is manifest.txt", default="manifest.txt")
parser.add_argument("-i", "--index", type=int, help="Use this book index. "
                    "Instead of random.")
parser.add_argument("-o", "--offset", type=int, help="Use this file byte offset. "
                    "Instead of random.")
parser.add_argument("-s", "--str_len", type=int, help="Sets the str_len to search. "
                    "Default is 19.", default=19)
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
max_offset = size - args.str_len -1
print("max_offset: {}".format(max_offset))
if args.offset is None:
    byte_offset = random.randint(0,max_offset)
else:
    byte_offset = args.offset

# Extract the string
# NOTE : Read file as binary using "rb"
with open(file_path, mode="rb") as fp:
    fp.seek(byte_offset)
    byte_str = fp.read(args.str_len)

# Compute the hash of byte_str
md5 = hashlib.md5()
md5.update(byte_str)

# Print selection
print("file_index: {} out of {}".format(index,num_files))
print("file_path: ",file_path)
print("byte_offset: ",byte_offset)
print('str_len: {}'.format(args.str_len))
print('byte_str: {}'.format(byte_str))
print('hash: {}'.format(md5.hexdigest()))

