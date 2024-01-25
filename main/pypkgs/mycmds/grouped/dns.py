from mycmds.cli import Command
import click
from mycmds.utils.funcs import execute

@Command(group=True)
def dns():
    """
    dns 快速切换
    """
    pass

@Command(dns)
def clash():
    execute("networksetup -setdnsservers Wi-Fi 198.18.0.2", content=True, IsSafe=True)

@Command(dns)
def clear():
    execute("networksetup -setdnsservers Wi-Fi Empty", content=True, IsSafe=True)

@Command(dns)
def show():
    execute("networksetup -getdnsservers Wi-Fi", IsSafe=True)

@Command(dns)
def dx():
    execute("networksetup -setdnsservers Wi-Fi 132.126.190.12 132.121.218.166", IsSafe=True)