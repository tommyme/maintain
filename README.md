# maintain -- repo maintained frequently
## quick start
- clone repo
- iu.sh
- make install
- make ...

## nvim
[check releases here](https://github.com/neovim/neovim/releases)

## fzf
use `C-t` or `**` to complete.
```shell
# x86-64
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/bin/nvim
```

## 写的一些小技巧

- wsl git
    在wsl下面git push比较烦, 可以先 gaa && gcmsg, 中间进行一个alias 再进行push
    ```shell
    alias git="/mnt/c/Program\ Files/Git/cmd/git.exe"
    ```
- zsh
    粘贴的时候非常的慢
    vim ~/.oh-my-zsh/lib/misc.zsh 并加入`DISABLE_MAGIC_FUNCTIONS=true`

    

## 一些主旨

- 全局脚本
    全局脚本有的使用的Python3.10的语法，所以推荐使用Python3.10
    全局脚本都是使用`/usr/local/bin/python3`这个一般是没有创建的，可以自己链接一下


