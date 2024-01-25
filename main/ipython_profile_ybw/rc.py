import sys
import os
import ctypes as c
import binascii as ba
import IPython
import base64
import requests as r
import collections
import functools
import itertools
import math
import re
j = os.path.join
py = IPython.get_ipython()
py.Completer.use_jedi = False

def c_mn(m, n):
    """calc c(m, n) value

    Args:
        m (int): big num
        n (int): small num
    """
    if m-n < n: n = m-n
    molecule, denominator = 1, 1
    for i in range(m, m-n, -1): molecule *= i
    for i in range(2, n+1): denominator *= i
    return molecule//denominator    