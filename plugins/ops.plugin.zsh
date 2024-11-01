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