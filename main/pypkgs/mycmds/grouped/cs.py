import os
import sys
import click
from mycmds.cli import Command, cli
from mycmds.utils.funcs import execContent, prompt


class SourceManager:
    def __init__(self, name, data, get_curr, set_curr, init_hook = None) -> None:
        self.get_curr = get_curr
        self.set_curr = set_curr
        self.data = data
        self.name = name
        if init_hook:
            init_hook()

    def show_curr(self):
        click.secho(
            f"[{self.name}] current registry: {self.get_curr()}", fg="green")

    def ask_switch(self):
        click.secho('switch registry? [Y/n] ', bold=True)
        if click.getchar() in ['\r', 'y', 'Y']:
            new_registry = self.data[1-self.data.index(self.get_curr())]
            self.set_curr(new_registry)
            click.secho(
                f"[{self.name}] current registry changed to: {self.get_curr()}", fg="green")
        else:
            click.secho("did not switched.")

# def execContent(x): return os.popen(x).read().strip()

# @Command(cli, group=True)
@Command(group=True)
def cs():
    """
    换源小工具
    """
    pass


@Command(cs)
@click.argument("arch", default="amd")
@click.option("--sudo", is_flag=True, help="use sudo")
def apt(arch, sudo):
    path = "/etc/apt/sources.list"
    targetSource = "mirrors.tuna.tsinghua.edu.cn"
    prefix = "sudo" if sudo else ""
    def add_prefix(x): return f"{prefix} {x}"
    data = {
        "arm": f'sed -i "s/ports.ubuntu.com/{targetSource}/g" {path}',
        "amd": f'sed -i -r "s/[a-z]+.ubuntu.com/{targetSource}/g" {path}'
    }
    if arch not in ['arm', 'amd']:
        click.secho("arch not known")
    commands = [
        f"cp {path} {path}.bak",
        f"{data[arch]}"
    ]
    commands = [*map(add_prefix, commands)]
    toBeCopied = "\n".join(commands)

    try: 
        import pyperclip
        pyperclip.copy(toBeCopied)
        click.secho(f"command copied: \n{toBeCopied}", fg="green")
    except:
        print("pyperclip not installed. copy yourself.")
        print(toBeCopied)

@Command(cs)
@click.option('-p', '--pnpm', is_flag=True, help="use pnpm")
def npm(pnpm):
    manager = SourceManager(
        name="pnpm" if pnpm else "npm",
        data=[
            "https://registry.npmmirror.com/",
            "https://registry.npmjs.org/"
        ],
        get_curr=lambda: execContent(f"{manager} config get registry"),
        set_curr=lambda x: execContent(f"{manager} config set registry {x}"),
    )
    manager.show_curr()
    manager.ask_switch()

@Command(cs)
@click.option('-t','--temp', is_flag=True, help="temporary useage")
def pip(temp):
    def init_hook():
        # 如果没换过源 这个list是空的
        if not execContent("pip3 config list"):
            execContent("pip3 config set global.index-url https://pypi.org/simple/")
    data = [
        "https://pypi.org/simple/",
        "https://pypi.tuna.tsinghua.edu.cn/simple/"
    ]
    if temp:
        click.secho("for temporary useage:")
        click.secho("\n".join([f"... -i {url}" for url in data]))
    else:
        manager = SourceManager(
            name="pip",
            data=data,
            get_curr=lambda: execContent("pip3 config get global.index-url"),
            set_curr=lambda x: execContent(f"pip3 config set global.index-url {x}"),
            init_hook=init_hook
        )
        manager.show_curr()
        manager.ask_switch()

@Command(cs)
def docker():
    import json
    #TODO
    reset_content = """{
"builder": {
"gc": {
"enabled": true,
"defaultKeepStorage": "20GB"
}
},
"features": {
"buildkit": true
},
"experimental": false
}"""
    # macos ~/.docker/daemon.json
    path = "~/.docker/daemon.json"
    path = os.path.expanduser(path)
    mirrors = [
        "https://hub-mirror.c.163.com",
        # "https://ustc-edu-cn.mirror.aliyuncs.com",
        "https://ghcr.io",
        "https://mirror.baidubce.com",
        "https://docker.mirrors.ustc.edu.cn/"
    ]
    if os.path.exists(path):
        with open(path, 'r') as f:
            conf:dict = json.load(f)
        if regs:=conf.get("registry-mirrors"):
            if prompt("current regitstry: " + regs + "reset it?"):
                data = json.loads(reset_content)
                data = json.dumps(data, indent=2)
                prompt(data)
                with open(path, 'w') as f:
                    f.write(data)
        else:
            if prompt("empty registry, change it?"):
                conf['registry-mirrors'] = mirrors
                with open(path, 'w') as f:
                    f.write(json.dumps(conf, indent=2))
        print('please restart docker')
