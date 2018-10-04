#!/usr/bin/env python3

#<------------------------------------------- 100 characters ------------------------------------->|

import sys
import os
import argparse
import hashlib

STR_LEN = 19

DESC = \
"""

  Given given a manifest.txt file, which describes
  a Gutenberg Project dataset, and a MD5 hash
  this script searchs the dataset for a 19 character
  string whose MD5 hash matches the given hash.
"""


# Start running here at main
if __name__ == "__main__":

    # parse the command line arguments
    parser = argparse.ArgumentParser(description=DESC)
    parser.add_argument("manifest", help="The manifiest.txt file")
    parser.add_argument("md5_hash", help="The MD5 hash to search for")
    parser.parse_args()
    args = parser.parse_args()

    # Verify the arguments
    if not os.path.isfile(args.manifest):
        print("ERROR: Not a file: ",args.manifest)
        sys.exit()

    if not len(args.md5_hash)==32:
        print("ERROR: md5_hash is not 16 bytes")
        sys.exit()

    try:
        md5_num = int(args.md5_hash,16)
    except ValueError:
        print("ERROR: md5_hash is not hexidecimal")
        sys.exit()


    print("manifest: ",args.manifest)
    print("md5_hash: ",args.md5_hash)


