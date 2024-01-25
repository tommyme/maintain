import sys
import IPython
c.InteractiveShell.banner1 = \
    '  Python\t:  ' + sys.version.split('\n')[0] + '\n' + \
    '  IPython\t:  ' + IPython.__version__ + '\n' \
    '  Interpreter\t:  ' + sys.executable + '\n'

c.InteractiveShell.autocall = 1 # call func like `f 1, 2`
c.InteractiveShell.show_rewritten_input = False
c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.extra_open_editor_shortcuts = True
c.TerminalInteractiveShell.editor = 'vim'   # 输入`%ed`来打开vim编辑
