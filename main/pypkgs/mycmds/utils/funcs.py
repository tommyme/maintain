
import functools
import os
from rich.console import Console
from functools import partial, wraps
console = Console()

def returnPrinter(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        return_values = func(*args, **kwargs)
        print(return_values)
    return wrapper

def execute(cmd, IsSafe=False, content=False, bash=False):
    """
    如果是安全命令 可以指定IsSafe为false 否则会提示用户 是否执行内容
    content 是否需要回显
    """
    if not IsSafe:
        console.print('executing: ',
        f'[bold cyan]{raw_str(cmd)}[/bold cyan]', 
        '[bold yellow]\ncontinue? [Y/n][/bold yellow]')

        res = input()   # input 函数是去掉了\n的
        if res not in ['', 'y', 'Y']:
            return      # 终止流程
    if bash:
        command = f'xxx=\'{raw_str(cmd)}\' && /bin/bash -c "$xxx"'
    else:
        command = raw_str(cmd)
    if content:
        # TODO 显示不出来
        return os.popen(command).read().strip()
    else:
        return os.system(command)

safeExec = partial(execute, IsSafe=True)
execContent = partial(execute, content=True)
safeExecContent = partial(execute, IsSafe=True, content=True)

def prompt(msg, plain=False) -> bool:
    """
    plain模式只是告诉用户一下接下来要干啥，plain为false就需要确认一下

    msg会追加Y/n
    return True if user confirmed.
    """
    if plain:
        input(msg + '(press any key to continue)')
        return True
    res = input(msg + ' [Y/n]').strip()       # input 函数是去掉了\n的
    if res not in ['', 'y', 'Y']:
        return False    # 终止流程
    return True

sizeof = lambda x: execute(f'du -sh {x}', IsSafe=True, content=True).split('\t')[0]
tmpd = lambda : execute('mktemp -d', IsSafe=True, content=True).strip()
errorf = lambda x: console.print(x, style='bold red')
infof = lambda x: console.print(x, style='bold green')
raw_str = lambda x: x.encode('unicode_escape').decode()