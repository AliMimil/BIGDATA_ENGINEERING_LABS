
from operator import itemgetter
import sys
current_abo = None
current_count = 0
abo = None
for line in sys.stdin: 
    line = line.strip() # remove leading and trailing whitespace
    # splitting the data on the basis of tab provided in mapper.py
    abo, dure = line.split('\t')
    # convert count (currently a string) to int
    try:
        m, s = dure.split(':')
        dure = int(m)*60+int(s)
    except ValueError:# ignore/discard this line if count is not a number
        continue
    # Hadoop sorts map output by key (word) before it is passed to the reducer
    if current_abo == abo:
        current_count += dure
    else:
        if current_abo:
    # write result to STDOUT
            h=current_count//3600
            current_count=current_count-h*3600
            m=current_count//60
            s=current_count%60
            current_count=f"{h}:{m}:{s}"
            print('%s \t %s' % (current_abo, current_count))
        current_count = dure
        current_abo = abo
# output the last word
if current_abo == abo:
    print('%s\t%s' % (current_abo, current_count))