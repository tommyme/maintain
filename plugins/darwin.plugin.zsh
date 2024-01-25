echo "U are using Mac! I know."
__conda="/opt/homebrew/Caskroom/miniconda/base"
# use gnu cmds in your mac.
# add a "gnubin" directory to your PATH from your bashrc like:
# PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
alias kara='/Library/Application\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli'
# use gsed if exist
gsed_fail=$(which gsed | grep "found")
if [ $gsed_fail ];then sed=sed;else sed=gsed;fi

alias draft="code ~/test/test.md"
alias jd="j down"
alias taskmgr="open \"/System/Applications/Utilities/Activity Monitor.app\""
alias down="cd ~/Downloads/"
alias service="brew services"
alias mysql="/Applications/phpstudy/Extensions/MySQL5.7.28/bin/mysql"
alias burp="cd '/Applications/Burp Suite Professional.app/Contents/Resources/app' && \
    nohup java -noverify -javaagent:BurpSuiteCnV2.0.jar -javaagent:BurpSuiteLoader.jar -Xmx2048m -jar burpsuite_pro.jar > /dev/null & \
    popd"
# mac burpsuite crack https://www.bilibili.com/read/cv17723175
alias sed="gsed"
alias shareproxy='ip=$(ipconfig getifaddr en0); proxy="http://$ip:7890"; echo "export http_proxy=$proxy; export https_proxy=$proxy; export all_proxy=$proxy;" | pbcopy'
alias wifi='/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport'
alias code-wsl-pwn="code --remote ssh-remote+wsl /home/ybw/pwn"
alias sm="killall ShareMouse; open ShareMouse"
alias qq="ka QQ; open QQ"
alias clash="ka ClashX; open -a ClashX" # already `alias open="open -a" in .zshrc`
alias trending="~/apps_docker/github_trending/run.sh"
alias disable_sleep="sudo pmset -b sleep 0; sudo pmset -b disablesleep 1"
alias enable_sleep="sudo pmset -b sleep 1; sudo pmset -b disablesleep 0"
alias disable_screen_sleep="sudo pmset -a displaysleep 0"
alias enable_screen_sleep="sudo pmset -a displaysleep 10"
alias dbsa="disable_sleep && disable_screen_sleep"
alias ebsa="enable_sleep && enable_screen_sleep"
alias md="open Typora"
alias txt="open TextEdit.app"
alias rm="trash"
alias binwalk='docker run --rm -v "$PWD":"/root" binwalk'
alias ql='quick-look'
alias self="cd '$HOME/Library/Mobile Documents/com~apple~CloudDocs/self'"
# check sleep status
a=$(sudo pmset -g custom | egrep -c '^\ sleep.*0$')
if [ $a = 2 ]; then
    echo "warning: you are keeping sleep disabled, which is dangerous!"
    echo "use 'disable_sleep' to stop it."
fi
function cpu_host_update(){
    # set host for {cpu}(my windows)
    if [ $1 -a $1 = "--help" ]; then
        echo "useage: cpu_host_update <hostname>"
        echo "you can use \`cpu_host_update \$(sudo find_cpu)\` to update automatically."
        elif [ $1 ]; then
        sudo gsed -i "s/.*cpu/$1 cpu/g" /etc/hosts
    else
        default_host="42.192.46.157"
        sudo gsed -i "s/.*cpu/${default_host} cpu/g" /etc/hosts
    fi
}
function push-wsl(){
    if [[ $1 ]]; then new_file=$1; else new_file=$HOME'/Downloads/'$(ls -t ~/Downloads | sed -n "1p"); fi
    scp -P 22222 $new_file ybw@cpu:~/pwn/.target
}
