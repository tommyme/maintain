import os
import click
from mycmds.cli import Command
from mycmds.utils.funcs import errorf

GIT = None

@Command(group=True)
def git():
    pass


@Command(git)
@click.option('-s', '--ssl', is_flag=True)
def init_ssh_config_item(ssl):
    """
    设置一下Host=github.com的item
    """
    from sshconf import read_ssh_config
    from os.path import expanduser
    config_path = expanduser("~/.ssh/config")
    config = read_ssh_config(config_path)
    data = {"Hostname":'github.com', "User":'git', "Identitiesonly":'yes', "IdentityFile":"~/.ssh/id_rsa"}
    if ssl:
        data['Port'] = 443
        data['Hostname'] = "ssh.github.com"
    else:
        config.unset("github.com",'port')
    config.set('github.com', **data)
    config.save()


@Command(git)
@click.option('-f', '--keyfile')
def switch(keyfile):
    """
    展示当前keyfile

    没指定新的keyfile就什么也不做
    """
    # https://github.com/sorend/sshconf
    from sshconf import read_ssh_config
    from os.path import expanduser

    config_path = expanduser("~/.ssh/config")
    if not os.path.exists(config_path):
        errorf(f"please create {config_path}")
        return
    config = read_ssh_config(config_path)

    # 如果没添加过github host 则添加github host

    # if set(config.host('github.com').keys()) != {'hostname', 'user', 'identityfile', 'identitiesonly'}:
    #     if prompt('github.com对应的字段不标准 是否重置'):
    #         config.set('github.com', Hostname='github.com', User='git', Identitiesonly='yes')
    #         config.save()
    #     else:
    #         errorf("canceled.")
    #         return
    
    current = config.host('github.com').get('identityfile')
    print("current key:", current)

    if keyfile:
        if os.path.exists(keyfile):
            if prompt('switch to another key file...'):
                config.set('github.com', IdentityFile=keyfile)
                config.save()
        else:
            errorf('key file not exist: '+str(keyfile))
    else:
        errorf("please provide your keyfile to switch")

@Command(git)
def token():
    import webbrowser
    webbrowser.open('https://github.com/settings/tokens')

@Command(git)
def key():
    import webbrowser
    webbrowser.open("https://github.com/settings/keys")
