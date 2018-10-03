#!/usr/bin/env python3

#<------------------------------------------- 100 characters ------------------------------------->|

import sys
import os

usage =  \
"""
Usage: manifest.py <dataset_dir>

 This script outputs a manifest of your
 Project Gutenberg dataset directory.
 The manifest includes total number of text files,
 the total size of all the text files in bytes,
 and a list of all the text files with their sizes.
 This output can be redirected to a file such as
 as "manifest.txt"
"""

# Print usage if any command line options specified
if len(sys.argv) == 2:
    dataset_dir = sys.argv[1]
    if not os.path.isdir(dataset_dir):
        print("ERROR: Not a directory: ",dataset_dir)
        sys.exit()
else:
    print(usage)
    sys.exit()


# Walk the directory structure looking for txt files.
total_size = 0
num_files = 0
file_list = []
for root ,dirs ,files in os.walk(dataset_dir):
    if root != dataset_dir:
        for file in files:
            if file.endswith(".txt"):
                num_files = num_files + 1
                file_path = os.path.join(root,file)
                file_size = os.path.getsize(file_path)
                total_size = total_size + file_size
                print(file_size, file_path)

print("num_files: ",num_files)
print("total_size: ",total_size)

