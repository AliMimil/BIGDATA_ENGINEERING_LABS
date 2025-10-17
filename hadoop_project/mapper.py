#!/usr/bin/env python
import sys
# input comes from standard input STDIN
for line in sys.stdin:
    line = line.strip() #remove leading and trailing whitespaces
    if not line:
        continue
    call = line.split('|') #split the line into words and returns as a list
    if len(call)>=1:
        abo=call[0]
        dure=call[-1]
        print(f"{abo}\t{dure}")
#     for word in call:
# #write the results to standard output STDOUT
#         print('%s\t%s' % (word,1)) #print the results