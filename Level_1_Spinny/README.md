# Level 1 : Spinny

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

## Notes

The following command copies all the Project Gutenberg txt files
(and only the text files) to your local computer. **Warning, 
there are almost 100,000 files that take up almost 42GB!**

```
rsync -av --include='*.txt' --include='*/' --exclude='*' aleph.gutenberg.org::gutenberg .
```
The text files are encoded as utf-8.  This means a character can
have variable width character encoding.  **The question is how do
we handle characters with multiple bytes?**  For now I will avoid
picking strings that have multi-byte characters.


