import os
import sys
import shutil

cwd = f"{os.getenv('HOME')}/maintain/plugins"
root = f"{os.getenv('HOME')}/.oh-my-zsh/plugins"

def install():
    for file in os.listdir(cwd):
        if not file.endswith(".plugin.zsh"):
            continue
        plugin_name = file.split(".")[0]
        src = os.path.join(cwd, file)
        dst_dir = os.path.join(root, plugin_name)
        dst = os.path.join(dst_dir, file)
        if not os.path.isfile(src):
            print(f"skip `{file}`: source not found")
            continue
        if os.path.exists(dst_dir):
            print(f"skip `{plugin_name}`: already exists in oh-my-zsh/plugins")
        else:
            os.mkdir(dst_dir)
            try:
                os.symlink(src, dst)
                print(f"installed `{plugin_name}`")
            except OSError as e:
                print(f"error linking `{plugin_name}`: {e}")

def uninstall():
    for file in os.listdir(cwd):
        if not file.endswith(".plugin.zsh"):
            continue
        plugin_name = file.split(".")[0]
        dst_dir = os.path.join(root, plugin_name)
        if os.path.exists(dst_dir):
            shutil.rmtree(dst_dir)
            print(f"removed `{plugin_name}`")
        else:
            print(f"skip `{plugin_name}`: not installed")

if "--uninstall" in sys.argv:
    uninstall()
else:
    install()
