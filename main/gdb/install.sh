SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
ln -sf $SCRIPT_DIR/.gdbinit ~/
ln -sf $SCRIPT_DIR/.gdb_cmd ~/