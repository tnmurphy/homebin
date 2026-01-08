#!/bin/bash

""" Convert input to text with escaped control codes"""
import os
import sys
from string import printable

   
bytes = sys.stdin.read()
output = sys.stdout
for b in bytes:
    if b == '\a':
        output.write(r"\a")
    elif b == '\f':
        output.write(r"\f")
    elif b == '\n':
        output.write(r"\n")
    elif b == '\r':
        output.write(r"\r")
    elif b == '\t':
        output.write(r"\t")
    elif b == '\v':
        output.write(r"\v")
    elif b in printable:
        output.write(b)
    else:
        output.write(r"\{0:03o}".format(ord(b)))
        
