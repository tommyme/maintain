# 运维
alias pmod="sudo chmod a+x *" # power mod
alias gg="gaa && gcmsg '..'"
alias ggg="gaa && gcmsg '..' && gp"
unalias gss
function gss() {
    cd $1 && git status && popd
}
function will {
    dive-link $(which $1)
}
function dive-link {
    # 递归寻找symbol link
    # 暂时不支持相对路径的symbol link dive
    if [ -L "$1" ]; then
        echo -e "\e[1;35m$1 is a symbolic link\e[0m"  # 紫色字体
        target=$(readlink "$1")
        echo -e "\e[1;33mThe symbolic link points to: $target\e[0m"  # 黄色字体
        dive-link "$target"  # 递归调用 will 函数，继续向下寻找
    else
        echo -e "\e[1;32m$1 is not a symbolic link\e[0m"  # 绿色字体
    fi
}
alias gitback="git reset . && git checkout . && git clean -df" # git back (to origin)
alias ca="conda activate"
alias cda="conda deactivate"
alias sizeof="du -sh"
alias t="tmux"
alias pg="pgrep"
alias ...="cd ../.."
alias k9="sudo kill -9"
alias ka="sudo killall"
alias history_fix="mv ~/.zsh_history ~/.zsh_history_bad && strings ~/.zsh_history_bad > ~/.zsh_history && fc -R ~/.zsh_history"
alias lt="ls -t"
alias grvv="grv | sed -E 's|ssh://git@([^:]+):[0-9]+/(.+)|https://\1/\2|'"
alias gamj="git am --reject"

function gcbr() {
    local remote_br=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
    gcb $1 $remote_br
}

function tarf(){
    local src="$(basename $1).tgz"
    local dst="$1"
    tar cfzv $src $dst
    echo "zipped to $src"
}
# 一键创建仓库，进行初始化，需要指定仓库名
function grepo(){
    git init
    git add .
    git commit -m'..'
    git branch -M main
    git remote add origin https://github.com/$GITHUB_USER/$1.git
    git push -u origin main
}


function code--(){
    code --remote ssh-remote+$1 $2 
}
function ssl_cert_install(){
    acme.sh --install-cert -d $1 \
    --cert-file      $2/cert.pem  \
    --key-file       $2/key.pem  \
    --fullchain-file $2/fullchain.pem \
}
function killport(){ 
    lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9 
}


function create_tslog() {
    local base_filename="$1"
    local timestamp=$(date +"%y%m%d_%H%M%S")
    local new_filename="${base_filename}_${timestamp}.log"
    touch "$new_filename"
    echo "$new_filename"
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

LONGTERM_VAR_STORAGE_PATH="$(cd "$(dirname "$0")" && pwd)/store.zsh"

function push_lvar() {
    # push longterm var to storage
    local name=$1
    local value=$2

    if grep -q "export $name=" "$LONGTERM_VAR_STORAGE_PATH"; then
        sed -i "/export $name=/d" "$LONGTERM_VAR_STORAGE_PATH"
    fi
    value_escaped=$(echo "$value" | sed 's/"/\\"/g')
    echo "export $name=\"$value_escaped\"" >> "$LONGTERM_VAR_STORAGE_PATH"
}


if [ -e $LONGTERM_VAR_STORAGE_PATH ]; then
    source $LONGTERM_VAR_STORAGE_PATH
else
    touch $LONGTERM_VAR_STORAGE_PATH
fi

function install-zoxide() {
    local arch=$(uname -m)
    if [ "$arch" = "x86_64" ]; then
        curl -LO https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.6/zoxide-0.9.6-x86_64-unknown-linux-musl.tar.gz
    else
        curl -LO https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.6/zoxide-0.9.6-aarch64-unknown-linux-musl.tar.gz
    fi
    x zoxide*
    mv zoxide*/zoxide $HOME/.local/bin
    echo "you can use command to import history: zoxide import --from=autojump $HOME/.local/share/autojump/autojump.txt"
}

function install-fzf() {
    local arch=$(uname -m)
    if [ "$arch" = "x86_64" ]; then
        curl -LO https://github.com/junegunn/fzf/releases/download/v0.57.0/fzf-0.57.0-linux_amd64.tar.gz
    else
        curl -LO https://github.com/junegunn/fzf/releases/download/v0.57.0/fzf-0.57.0-linux_arm64.tar.gz
    fi
    x fzf*
    curl -LO https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/bin/fzf-preview.sh
    curl -LO https://raw.githubusercontent.com/junegunn/fzf/refs/heads/master/bin/fzf-tmux
    chmod a+x fzf-preview.sh fzf-tmux
    mv fzf fzf-preview.sh fzf-tmux $HOME/.local/bin
}

# 增强版 cd：支持直接 cd 到文件所在的目录
cd() {
  # 检查是否只有一个参数，并且该参数是一个存在的文件 (绝对路径或相对路径均可)
  if [[ $# -eq 1 && -f "$1" ]]; then
    # ${1:h} 是 zsh 的内置修饰符 (head)，作用等同于 dirname "$1"
    # 使用 builtin 确保调用的是原生 cd，防止无限递归死循环
    builtin cd "${1:h}"
  else
    # 其他情况（如无参数、正常目录、多参数等）保持默认行为
    builtin cd "$@"
  fi
}