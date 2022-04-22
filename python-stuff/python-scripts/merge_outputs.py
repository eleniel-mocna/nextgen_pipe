"""
This script just takes pairs of arguments <file0> <n_lines0> <file1> <n_lines1> ...
and interlaces them together, so that for each file:
 - First line is omitted (config)
 - Then always <n_lines> lines are copyied together

If some files have fewer samples then other, all files are shortened so that 
all files have the same number of samples.
"""

import sys
files = []
lines=[]
n_lines = []
for i in range(len(sys.argv)//2):
    file = open(sys.argv[i*2+1],"r")
    file.readline()
    files.append(file.__iter__())
    n_lines.append(int(sys.argv[i*2+2]))

are_we_done_yet=False
while not are_we_done_yet:
    for i in range(len(files)):
        for n_line in range(n_lines[i]):
            line = files[i].readline()
            if len(line)==0:
                are_we_done_yet=True
            else:
                print(line.rstrip('\n'))

for file in files:
    file.close()
