import click
from mycmds.utils.funcs import returnPrinter

@click.group()
def cli():
    pass

def Command(parent=cli, group=False, name=None):
    """
    融合两条命令click.Command , xxx.add_command
    """
    trans = click.group if group == True else click.command
    def decorator(func):
        f = trans()(func)
        parent.add_command(f, name)
        return f
    return decorator

# 注册命令
import mycmds.grouped
from mycmds.single import *

