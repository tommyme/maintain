import os
import sys

command = sys.argv[1]

PATH = os.environ["PATH"]

PATH = PATH.split(os.pathsep)

py_scripts = []

def judge(path):
    try:
        with open(path) as f:
            content = f.read().split('\n')
    except:
        return False
    header = content[0].strip()
    if header.startswith('#!') and (header.endswith('python3') or header.endswith('python')):
        return True
    return False


for p in PATH:
    if os.path.exists(pp:=os.path.join(p, command)):
        print(pp)
        if os.path.isfile(pp):
            print('1')
            if judge(pp):
                break

os.system(" ".join(["python3", pp, *sys.argv[2:]]))