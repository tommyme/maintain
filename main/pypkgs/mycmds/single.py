import os
import sys

from traitlets import default
from mycmds.cli import cli, Command
import click
from mycmds.utils.funcs import returnPrinter, prompt, execute, errorf, infof, tmpd, sizeof, console

@Command(cli, name="len")
@click.option('-h', '--ishex', 'ishex', is_flag=True, help='hex str len to bit len')
@returnPrinter
def length(ishex: bool):
    import pyperclip as ppc
    import binascii
    def is_hexstr(s: str):
        try:
            binascii.unhexlify(s)
            return True
        except binascii.Error:
            return False

    content = ppc.paste()
    if ishex:
        if is_hexstr(content):
            return 8*len(content)//2, "bits"
    return len(content)

@Command(cli)
@click.argument("path")
def pipv(path):
    """
    requirements.txt 版本固化工具.
    """
    try:
        import requirements
    except:
        print("install requirements-parser==0.5.0 first.")

    import subprocess
    import json

    data = subprocess.check_output(["pip", "list", "--format", "json"])
    parsed_results = json.loads(data)
    adict = {element["name"]: element["version"] for element in parsed_results}
    res = []
    with open(path, 'r') as fd:
        for req in requirements.parse(fd):
            # print(req.name, req.specs)
            if req.name not in adict:
                print(req.name, 'not found in pip list, maybe name non-standard')
                res.append(req.name)
            else:
                res.append(f"{req.name}=={adict[req.name]}")

    with open(path, 'w') as f:
        f.write('\n'.join(res))

@Command(cli)
@click.argument("target")
def backup(target):
    target_bk = target + '_backup' if os.path.isdir(target) else target + '.bak'

    if os.path.exists(target_bk):
        if prompt('backup file already exists, delete it?'):
            execute(f'rm -rf {target_bk}')
        else:
            errorf('abort', style='bold red')
            return

    execute(f"cp -r {target} {target_bk}")

@Command(cli)
def clip_listen():
    """
    适用于需要短期拷贝多个东西 然后聚合到一起的场景 比如去调色盘拷贝几个颜色
    """
    # import atexit
    import pyperclip as ppc
    while True:
        res = ppc.waitForNewPaste()
        print(res)

@Command(cli)
@click.argument('a', nargs=-1)
def test(a):
    errorf(a)   # ('fuck!',)

@Command(cli)
def ocr():
    import AppKit
    board = AppKit.NSPasteboard.generalPasteboard()
    types = board.types()
    data = [board.dataForType_(i) for i in types]
    content_view = data[0].bytes()
    pic_raw = content_view.tobytes()
    with open(f"{os.environ['HOME']}/test.png", "wb") as f:
        f.write(pic_raw)

    execute(f"qlmanage -p {os.environ['HOME']}/test.png", IsSafe=True)

@Command(cli)
@click.argument('st')
@click.argument('ed')
def workhard(st, ed):
    import datetime
    import re
    from rich import print as rprint

    hours, mins = map(int, re.findall('..', st))
    start = datetime.timedelta(hours=hours, minutes=mins)
    hours, mins = map(int, re.findall('..', ed))
    end = datetime.timedelta(hours=hours, minutes=mins)
    noon_rest_time = datetime.timedelta(hours=1, minutes=30)
    work_hours = datetime.timedelta(hours=8)
    result = end - start - noon_rest_time
    print(result)
    if result >= work_hours:
        rprint('[bold bright_green]工时达标, 速润')
    else:
        rest_time = start+work_hours+noon_rest_time
        rprint(f'[bold orange_red1]再撑一下, {rest_time}就可以润了')


@Command(cli)
@click.argument('name')
def loc(name):
    import pyperclip as ppc
    # 问题是 只能改变子进程的目录 无法改变父进程的目录
    def process(s: str):
        return s.replace('~', '\~').replace(' ', '\ ')
    mapper = {
        'obsidian': os.path.expanduser('~/Library/Mobile Documents/iCloud~md~obsidian/Documents'),
        'self': os.path.expanduser('~/Library/Mobile Documents/com~apple~CloudDocs/self')
    }
    # valid = ['obsidian', 'self']
    if name not in mapper.keys():
        errorf("avaliable locations are: "+str(mapper.keys()))
    else:
        command = ('cd '+process(mapper[name]))
        ppc.copy(command)
        print('copied.')
        


@Command(cli)
@click.option('--ban', is_flag=True, help='使用PDST.scpt来禁止pd弹窗, 需要你在repos里面有pd-runner项目')
@click.option('--kill', is_flag=True, help='使用pkill杀死PDST进程')
@click.argument('args', nargs=-1)
def pd(ban, kill, args):
    """你可以用脚本编辑器打开scpt文件来查看其内容"""
    """下面是反编译之后的
    set PD to "Parallels Desktop"
    set PDA to application PD
    repeat while true
        if PDA is running then
            if PD is in (get name of every window of PDA) then
                repeat 4 times
                    tell PDA to close (every window whose name is PD)
                    delay 0.1
                end repeat
            end if
        end if
        delay 1
    end repeat
    """
    if ban:
        cmd = f"osascript '{os.environ['HOME']}/repos/PD-Runner/PD Runner/PD Runner/PDST.scpt' &"
        execute(cmd)
        return
    elif kill:
        cmd = "pkill -f 'osascript.*PDST.scpt'"
        execute(cmd)
        return
    def sudo(x): return execute('sudo ' + x, IsSafe=True)
    commands = list(args)

    sudo("date $(date -j -f %s $((`date +%s`-315360000)) +%m%d%H%M%Y.%S) >/dev/null 2>&1;")
    try:
        cmd = f"prlctl {' '.join(commands)}"
        execute(cmd, IsSafe=True)
    except:
        errorf("Error")
    sudo("date $(date -j -f %s $((`date +%s`+315360000)) +%m%d%H%M%Y.%S) >/dev/null 2>&1")
    sudo("sntp -sS time.apple.com >/dev/null 2>&1")

@Command(cli)
def copy():
    import pyperclip as ppc
    ppc.copy(sys.stdin.read())
    infof("copied.")

@Command(cli)
@click.argument('filename')
def vscode(filename: str):
    import json
    import platform

    is_linux = "Linux" in platform.platform()
    is_WSL2 = "WSL2" in platform.platform()
    is_Mac = "mac" in platform.platform()
    _idx = filename.rfind(".")
    snipName, suffix = filename[:_idx], filename[_idx+1:]
    langDict = {'py': 'python',
                'c': 'c',
                'cpp': 'cpp',
                'html': 'html',
                'js': 'javascript',
                'vue': 'vue',
                'css': 'css',
                'json': 'json',
                'sh': 'shellscript',
                'go': 'go'}

    if suffix in langDict.keys():
        lang = langDict[suffix]
    else:
        print('{} is not included in your vscode snippets'.format(suffix))
        exit()

    if is_Mac:
        path = r'{}/Library/Application Support/Code/User/snippets/{}.json'.format(os.environ["HOME"],lang)
    elif is_linux:
        if is_WSL2:
            path = r'/mnt/c/Users/27564/AppData/Roaming/Code/User/snippets/{}.json'.format(lang)
        else:
            path = r"/home/{}/.config/Code - Insiders/User/snippets/{}.json".format(os.getlogin(), lang)
    else:
        path = r'C:\Users\{}\AppData\Roaming\Code\User\snippets\{}.json'.format(os.getlogin(), lang)

    if not os.path.exists(path):
        # create file
        with open(path, 'w') as f:
            f.write('{}')

    try:
        print(path)
        with open(path) as f:
            data = json.load(f)
    except:
        errorf("请删除对应json文件中的注释，json.load(f)不能解析注释内容！")
        exit()

    with open(filename, encoding='utf-8') as f:
        content = f.read()
        new = {}
        new['prefix'] = snipName
        new['body'] = content.split('\n')
        new['description'] = 'template for {}'.format(snipName)

    data[snipName] = new
    if content == 'DEL\n':  # 删除对应snippet就在文件中输入'DEL\n'
        data.pop(snipName)

    with open(path, 'w') as f:
        f.write(json.dumps(data, indent=4))

@Command(cli)
@click.argument('port', nargs=-1)
def lo(port):
    infof(port)
    import webbrowser

    def parsePort(port: str):
        if not port:
            return "80"
        else:
            port = port[0]
            if port.endswith("k"):
                return str(int(port[:-1]) * 1000)
            else:
                return port
    
    port = parsePort(port)
    webbrowser.open(f"http://localhost:{port}")


@Command(cli)
@click.argument('num')
@click.option("--ne", is_flag=True, help="negative num", default=False)
def mdtitle(num, ne):
    """
    无法识别负数 所以搞了个flag    
    """
    from pyperclip import copy, paste
    import re

    num = int(num)
    if ne:
        num *= -1

    content = paste().split('\n')
    # python的注释也是# 开头 所以我们忽略代码块
    InCodeBlock = False
    for id, line in enumerate(content):
        p = re.match("^(#+\ )(.*)", line)    #   一个或者多个 # 和一个 空格开头
        if re.match("^```", line):
            InCodeBlock = not InCodeBlock   # 置反
        if p and not InCodeBlock:
            prefix, line_content = p.groups()
            level = prefix.count("#")
            level += num
            if level <= 0:
                error_type = "negetive level error!"
                error_msg = f"{error_type}\n\t at line: {line}"
                raise Exception(error_msg)
            line = level*"#" + " " + line_content
            content[id] = line

    copy("\n".join(content))


@Command(cli)
@click.argument('src')
@click.argument('dst', nargs=-1)
def tinify(src, dst):
    """
    src 源图片路径
    
    dst 生成图片路径 不指定的话就在当前目录下生成 xxx_tiny.xxx
    """
    from private.tinypng import key
    import sys
    import os
    import tinify

    tinify.key = key
    # console.print(src, dst)
    # return
    source = tinify.from_file(src)
    if len(dst) == 0:
        old_name = src.split("/")[-1]
        pre, suf = old_name.split(".")
        dst = f"{pre}_tiny.{suf}"
    else:
        dst = dst[0]
    console.print(f'tinify picture from ' \
                    f'{src}:[{sizeof(src)}] to ' \
                    f'{dst}:[{sizeof(dst)}]')
    source.to_file(dst)

@Command(cli)
@click.argument('target')
def recover(target):
    if not (target.endswith('.bak') or target.endswith('_backup')):
        errorf("format error!")
        return
    xxx = target.replace('.bak','').replace('_backup','')
    if os.path.exists(xxx):
        infof('delete origin file (cover it next)')
        execute(f'rm -rf {xxx}')
    execute(f'cp -r {target} {xxx}')
    

@Command(cli)
@click.argument('filename')
def run(filename:str):
    """
    py 直接跑
    c 当前目录下编译 跑 删除
    js 使用node执行
    """
    if filename.endswith('.py'):
        execute(f"python3 {filename}", IsSafe=True)
    elif filename.endswith('.c'):
        execute(f"gcc {filename} -o {filename.split('.')[0]} && ./{filename.split('.')[0]} && rm {filename.split('.')[0]}")
    elif filename.endswith('.js'):
        execute(f"node {filename}", IsSafe=True)

@Command(cli)
@click.option('-h', '--host', 'host', default='localhost')
@click.option('-p', '--port', 'port', default=8000, type=int)
@click.option('-d', '--directory', 'directory', default='.')
@click.option('-cp', '--cert-path', 'certp')
def https(host, port, directory, certp):
    import http.server, ssl
    tmp_flag = False
    certfile, keyfile = None, None

    if certp is None:
        prompt('no cert path specified, making temp cert...', plain=True)
        tempdir = tmpd()
        certfile, keyfile = os.path.join(tempdir, 'localhost.crt'), os.path.join(tempdir, 'localhost.key')
        execute(f"""openssl req -x509 -out {certfile} -keyout {keyfile} -newkey rsa:2048 -nodes -sha256 -subj "/CN=localhost" -extensions EXT -config <( printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")""",
        bash=True)
        tmp_flag = True

    else:
        cert_basename, cert_dirname = os.path.basename(certp), os.path.dirname(certp)
        cert_dirname = '.' if not cert_dirname else cert_dirname
        if cert_basename.endswith('pem'):   # pem文件的话 只需要一个
            certfile = certp
        elif cert_basename.endswith('crt'): # crt文件和key文件
            cn = cert_basename.split('.')[0]
            if cn+'.key' in os.listdir(cert_dirname):
                certfile = certp
                keyfile = os.path.join(cert_dirname, cn+'.key')
    

    class Handler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, directory=directory, **kwargs)
    
    with http.server.HTTPServer((host, port), Handler) as httpd:
        httpd.socket = ssl.wrap_socket(
            httpd.socket,
            server_side=True,
            certfile=certfile,
            keyfile=keyfile,
            ssl_version=ssl.PROTOCOL_TLS
        )
        print(f'you can access https://{host}:{port}')

        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            if tmp_flag:
                execute(f'rm -r {tempdir}', IsSafe=True)
            print('shutting down...')
            httpd.socket.close()
            exit()

@Command(cli)
@click.argument('src')
@click.argument('dst')
def trans(src, dst):
    """
    万能文件转换器
    """
    _all = {
        'img': ['pdf'],
        'gif': ['frame'],
        'code': ['img']
    }


@Command(cli)
def requirements():
    packages = [
        'pyperclip',
    ]
    execute(f'python3 -m pip install {" ".join(packages)}')

@Command()
def clean_ram():
    """
    logi options plus 就是vsz比较大 实际上的
    """
    targets = [
        ""
    ]

@Command(cli)
@click.argument('sep', default=' ')
def split(sep):
    content = sys.stdin.read()
    print("\n".join(content.split(sep)))

@Command(cli)
def hold():
    """
    使用 sys.stdin.read() 读 然后打印
    """
    content = sys.stdin.read()
    print(content)

@Command(cli)
def qrcode():
    """
    读取剪贴板里面的string 通过qrcode展示出来
    """
    import pyperclip
    import qrcode
    text = pyperclip.paste()
    print(text)
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(text)
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    img.show()

@Command(cli)
def paste():
    """
    读取剪贴板string 并且粘贴, 用于base64 -d比较实用
    """
    import pyperclip as ppc
    print(ppc.paste())

@Command(cli)
@click.argument('msg')
def ipc(msg):
    pipe_path = '/tmp/mydaemon_pipe'
    if not os.path.exists(pipe_path):
        raise Exception("Daemon process is not running")
    # 打开命名管道进行写入
    pipe_fd = os.open(pipe_path, os.O_WRONLY)
    # 向管道中写入消息
    os.write(pipe_fd, msg.encode())
    # 关闭管道
    os.close(pipe_fd)

@Command(cli)
def c_array():
    import pyperclip as ppc
    content = ppc.paste().strip()
    content = content.split(" ")
    content = [f'0x{i}' for i in content]
    res = f"{{{', '.join(content)}}}"
    ppc.copy(res)

@Command(cli)
@click.argument('dst', default='pasted.png')
def paste_img(dst):
    from PIL import ImageGrab
    img = ImageGrab.grabclipboard()
    img.save(dst, 'PNG')