#! /usr/bin/env python

"""
Go through a .tex file, identifying file dependencies from \input and
\includegraphics commands.
"""

import re
from StringIO import StringIO
import sys, glob, fileinput

# regexp for grabbing figure files from \includegraphics[]{}:
fig_re = re.compile(r'.*\includegraphics\S*{(?P<fig>[\w,\-,+,.]*)}')
    
# regexp for grabbing figure files from \includegraphics[]{}:
input_re = re.compile(r'.*\input{(?P<name>[\w,\-,+,.]*)}')
    

def find_files(lines):
    """
    Find figure and input file names in a list of lines.
    """
    nl = 0
    figs = []
    inputs = []
    for line in lines:
        nl += 1
        # Skip entirely commented lines.
        if line[0] == '%':
            continue
    
        # Find figures.
        results = fig_re.findall(line)
        c = line.count('includegraphics')
        if c > 1:
            print '*** Multiple figures on a line! ***'
        for result in results:
            figs.append(result)
    
        # Find input files.
        results = input_re.findall(line)
        c = line.count('\\input')
        if c > 1:
            print '*** Multiple inputs on a line! ***'
        for result in results:
            inputs.append(result)
    return nl, figs, inputs

# Parse the arguments.
# For multiple args, treat as a file list; otherwise as a glob.
if len(sys.argv) > 2:
    lines = fileinput.input()
elif len(sys.argv) == 2:
    lines = fileinput.input(glob.glob(sys.argv[1]))
else:
    lines = StringIO(sample)

# Find files in the files provided as arguments.
nl, figs, inputs = find_files(lines)

# Find files in the input files.
for fname in inputs:
    lines = fileinput.input(fname+'.tex')
    n, f, ins = find_files(lines)
    nl += n
    figs.extend(f)
    inputs.extend(ins)

print 'Results presume simple names, 1/line, may include comments.'
print '[%d lines read, %d figures found, %d inputs found]\n' % (nl, len(figs), len(inputs))


if figs:
    s = figs[0]
    for fig in figs[1:]:
        s += ' ' + fig
    print 'Figure files:'
    print s
else:
    print 'No figure files found.'

print

if inputs:
    s = inputs[0] + '.tex'
    for name in inputs[1:]:
        s += ' ' + name + '.tex'
    print 'Input files:'
    print s
else:
    print 'No input files found.'

