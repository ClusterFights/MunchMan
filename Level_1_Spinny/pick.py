#!/usr/bin/env python3

#<------------------------------------------- 100 characters ------------------------------------->|

import sys
import os
import random
import hashlib

STR_LEN = 19

USAGE =  \
"""
Usage: pick.py <manifest.txt>

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

# Print USAGE if not one argument
if len(sys.argv) == 2:
    manifest = sys.argv[1]
    if not os.path.isfile(manifest):
        print("ERROR: Not a file: ",manifest)
        sys.exit()
else:
    print(USAGE)
    sys.exit()

# Parse the manifest.
file_list = []
with open(manifest, 'r') as fp:
    for cnt, line in enumerate(fp):
        if cnt>1:
            size_str, file_path = line.split()
            file_list.append((int(size_str),file_path))

# Select a random file
num_files = len(file_list)
index = random.randrange(num_files)
#index = 10 # test file with multibye encodings.
size = file_list[index][0]
file_path = file_list[index][1]

# Select random substring
max_offset = size - STR_LEN
str_offset = random.randint(0,max_offset)
#str_offset = 169076 # known error spot

# NOTE : Multi-byte characters in file 10, 
# around line 3000 - 4036.

# Extract the string
done = False
# NOTE : Use latin-1 encoding to map byte values directly
# to first 256 Unicode code points.  Generates
# no exceptions, unlike utf-8.
with open(file_path, mode="r", encoding="latin-1") as fp:
    while not done:
        fp.seek(str_offset)
        # May have to try a couple times if
        # utf-8 multi-byte characters get split.
        try:
            utf8_str = fp.read(STR_LEN)
            done = True
        except UnicodeDecodeError as e:
            #print("READ ERROR: {}, str_offset={}".format(e,str_offset))
            str_offset = random.randint(0,max_offset)

# Compute the hash of byte_str
byte_str = utf8_str.encode()
md5 = hashlib.md5()
md5.update(byte_str)

# Print selection
print("file_index: {} out of {}".format(index,num_files))
print("file_path: ",file_path)
print("str_offset: ",str_offset)
print('utf8_str: "{}"'.format(utf8_str))
print('byte_str: {}'.format(byte_str))
print('hash: {}'.format(md5.hexdigest()))

if len(utf8_str) != len(byte_str):
    print("WARNING: utf8_str and byte_str not the same length")
    print("   utf8_str: ",len(utf8_str))
    print("   byte_str: ",len(byte_str))



