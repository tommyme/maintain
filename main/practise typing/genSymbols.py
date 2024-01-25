import random
import re
import sys


numbers = "1234567890"
symbols = "()ppll_+-={}[]|\\;':,./jklasdfasdfjkl"
if len(sys.argv) > 1:
    if sys.argv[1] == "-n":
        symbols += numbers
    if sys.argv[1] == "-num":
        symbols = numbers
res = [random.choice(symbols) for _ in range(500)]
txt = "".join(res)
res = re.findall(".....", txt)
txt = " ".join(res)
print(txt)
