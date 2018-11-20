#!/usr/bin/env python3

#<------------------------------------------- 100 characters ------------------------------------->|

import sys
import os
import argparse
import hashlib
import time

# TODO : Make sure works on last string of the file.


DESC = \
"""

  Given given a manifest.txt file, which describes
  a Gutenberg Project dataset, and a MD5 hash
  this script searchs the dataset for a 19 character
  string whose MD5 hash matches the given hash.
"""

class Find_Hash:
    """
    Utility class for finding a hash in a large text dataset.
    """

    STR_LEN = 19
    BUF_LEN = 500

    def __init__(self, manifest_, md5_hash_, all_):
        """
        Args:
            manifest_ (str) : Name of the manifest file
            md5_hash_ (str) : The search hash, Hexidecimal string, 32 chars.
            all_ (bool) : Process whole dataset, or stop at first match
        """
        # Verify argument types
        assert isinstance(manifest_, str)
        assert isinstance(md5_hash_, str)
        assert isinstance(all_, bool)

        # Store in object
        self.manifest = manifest_
        self.md5_hash = md5_hash_
        self.all = all_ 

        # Load the file_list
        self._parseManifest()

    def _parseManifest(self):
        """
        Parse the Manifest file and generate list of all the text files
        """
        self.file_list = []
        with open(self.manifest, 'r') as fp:
            for cnt, line in enumerate(fp):
                if cnt==0:
                    key, value = line.split()
                    self.total_size = int(value)
                elif cnt==1:
                    key, value = line.split()
                    self.num_files = int(value)
                elif cnt>1:
                    size_str, file_path = line.split()
                    self.file_list.append((int(size_str),file_path))

    def process(self, chunk):
        """
        Move characters one at a time from chunk
        into self.buffer_hash. Once buffer_hash has size of STR_LEN
        start md5_hash of buffer_hash.  Returns True if match
        found and should end
        """
        while len(chunk) > 0:
            # Pop char from chunk
            c = chunk[0]
            chunk = chunk[1:]

            # Add character to self.buffer_hash
            if len(self.buffer_hash) < self.STR_LEN:
                # buffer not full yet
                self.buffer_hash = self.buffer_hash + chr(c)
            else:
                # buffer_hash is full, so calc MD5 hash
                self.num_hashes = self.num_hashes + 1
                byte_str = self.buffer_hash.encode()
                md5 = hashlib.md5()
                md5.update(byte_str)
                if md5.hexdigest() == self.md5_hash:
                    print("MATCH: ",byte_str)
                    if not self.all:
                        return True

                # buffer is full, so drop oldest char
                # TODO : On last buffer of file need to
                # process this last hash.
                self.buffer_hash = self.buffer_hash[1:] + chr(c)

        return False

    def run(self):
        """
        Search the dataset for md5_hash
        """
        self.num_hashes = 0
        done = False
        for index, file_info in enumerate(self.file_list):
            if done:
                break
            file_size, file_path = file_info
            self.buffer_hash = ""
            # NOTE : Read file as binary using "rb"
            with open(file_path, mode="rb") as fp:
                print(index, file_path)
                while True:
                    chunk = fp.read(self.BUF_LEN)
                    if  (not chunk):
                        break
                    done = self.process(chunk)
                    if done:
                        break

# Start running here at main
if __name__ == "__main__":

    # parse the command line arguments
    parser = argparse.ArgumentParser(description=DESC)
    parser.add_argument("md5_hash", help="The MD5 hash to search.")
    parser.add_argument("manifest", nargs="?", help="The manifiest.txt file. "
                       "Default is manifest.txt", default="manifest.txt")
    parser.add_argument("-a", "--all", help="Process whole dataset. "
                        "Don't stop at first match.", action="store_true")
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

    fhash = Find_Hash(args.manifest, args.md5_hash, args.all)

    start = time.time()
    fhash.run()
    end = time.time()
    run_time = end - start

    hashes_per_sec = int(fhash.num_hashes / run_time)

    print("num_hashes: ",fhash.num_hashes)
    print("run time in seconds: ",run_time)
    print("hashes_per_sec: ",hashes_per_sec)

    print("DONE")


