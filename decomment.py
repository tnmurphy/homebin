#!/bin/python

"""
Remove comments from a C/C++ file
"""

import sys

comment_state = False
for line in sys.stdin:
    left_cut = ""
    right_cut = ""
    if not comment_state:
        pos = line.find("/*")
        if pos != -1:
            comment_state = True
            left_cut = line[:pos]

    if comment_state:
        pos = line.find("*/")
        if pos != -1:
            comment_state = False
            right_cut = line[pos + 2:]
    else:
        poscpp = line.find("//")
        if poscpp != -1:
            left_cut = line[:poscpp]
    # lets hope /* */ and // never appear on the same line

    if not comment_state:
        if left_cut == "" and right_cut == "":
            sys.stdout.write(line)
        else:
            output = left_cut + right_cut
            if len(output) > 0 and output[0] != "\n":
                sys.stdout.write(output)
    else:
        # sys.stdout.write("\n")
        pass
