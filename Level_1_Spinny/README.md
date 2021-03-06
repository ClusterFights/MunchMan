# Level 1 : Spinny
![level1_spinny](../images/level1_spinny.png)

## Description

This is a reference implementation of the
[Project Gutenberg MD5
Search](http://clusterfights.com/wiki/index.php?title=Project_Gutenberg_MD5_Search) challange. 
It is a single node, un-optimized, implementation.
It's purposed is to get benchmark data on individual nodes and to 
compare against future cluster implementations.

The basic measure of interest is how many hashes a second over
the Project Gutenberg dataset can be achieved.  This code should
be able to run on any Linux machine (i.e. laptop, Raspberry Pi 3
Model B+, Raspberry Pi Zero etc).

## Usage

There are four steps.

1. Grab a copy of the [MD5 Challenge dataset](http://clusterfights.com/wiki/index.php?title=Datasets)
This dataset looks like it is from 2003.  It has 595 text files and is ~500MB.
2. Generate a manifest.txt file of the Project Gutenberg dataset.
   This basically generates a list of all the text files and their
   paths. Once this file is generated you don't have to regenerate it
   unless the dataset is updated.
3. Randomly pick a 19-character string out of the dataset and compute
   the hash.
4. Search the dataset and try to find the string that matches the
   hash from step 2.

Here are the commands for steps 2 through 4:

```
$ ./manifest.py ../../dataset/iso_extracted/ > manifest.txt

$ ./pick.py
file_index: 36 out of 595
file_path:  ../../dataset/iso_extracted/etext05/panic10.txt
str_offset:  77641
byte_str: b'chants betook thems'
hash: 859143f74d9d245c097c03023899f35a

$./find.py 859143f74d9d245c097c03023899f35a
...
35 ../../dataset/iso_extracted/etext05/8hsrs10.txt
36 ../../dataset/iso_extracted/etext05/panic10.txt
MATCH:  b'chants betook thems'
num_hashes:  21941741
run time in seconds:  29.06871509552002
hashes_per_sec:  754823
DONE
```

## Notes

The following command copies all the Project Gutenberg txt files
(and only the text files) to your local computer. **Warning, 
there are almost 100,000 files that take up almost 42GB!**

```
rsync -av --include='*.txt' --include='*/' --exclude='*' aleph.gutenberg.org::gutenberg .
```
The text files are encoded as utf-8.  This means a character can
have variable width character encoding.  **The question is how do
we handle characters with multiple bytes?**  If we are reporting
offset, should those be byte offsets or character offsets? 

The solution I have found for now is to use 'latin-1' encoding which
maps all 256 bytes directly to the first 256 Unicode code points.
So basically the string to hash is 19-bytes (not 19-characters).
[Ref](http://python-notes.curiousefficiency.org/en/latest/python3/text_file_processing.html#files-in-an-ascii-compatible-encoding-best-effort-is-acceptable) 



