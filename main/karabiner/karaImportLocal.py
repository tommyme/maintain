import os
import sys
import webbrowser
import subprocess
import time
import json
import socket
from contextlib import closing

def find_free_port():
    with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
        s.bind(('', 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return str(s.getsockname()[1])


if __name__ == "__main__":

    # 由于karabiner加载相同url的时候会缓存, 导致我们对json文件的更改不会生效, 所以我们就生成随机文件名
    tmstp = str(int(time.time()))[-6:]  # 时间随机后缀, 用于生成随机文件名

    json_path = sys.argv[1]

    with open(json_path, 'r') as f:
        try:  
            parsed_json = json.load(f)
        except:
            raise Exception('parse json file FAILED. Please check the grammar')

    # 找到dirname
    dirname, basename = os.path.dirname(json_path), os.path.basename(json_path)
    if not dirname:
        dirname = "."
    tmp_file = f"{basename.split('.')[0]}_{tmstp}.json"

    # copy target json file to current work dir
    os.system(f"cp {json_path} {tmp_file}")
    port = find_free_port()
    proc = subprocess.Popen(["python3", "-m", "http.server", port])

    prefix = "karabiner://karabiner/assets/complex_modifications/import?url="
    url = f"{prefix}http://127.0.0.1:{port}/{tmp_file}"
    print(url)
    webbrowser.open(url)

    input("\nwaiting for import json file. press anykey to shutdown http server.\n")
    proc.kill()
    os.remove(tmp_file)
