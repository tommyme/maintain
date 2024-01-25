__conda="$HOME/.miniconda"
user="/mnt/c/Users/ybw"
desktop="$user/Desktop"
downloads="$user/Downloads"
echo "U are using WSL2! I know."
alias ggg="gaa && gcmsg '..' && /mnt/c/Program\ Files/Git/cmd/git.exe push"
# for shared mouse
alias sm="/mnt/c/Program\ Files\ \(x86\)/ShareMouse/ShareMouse.exe &"
alias sm_restart="taskkill.exe /IM Share\* /F && sm"
alias ida-x64="/mnt/c/pwntools/ida75/75ida64.exe -i"
alias ida-x86="/mnt/c/pwntools/ida75/75ida.exe -i"
export PATH=/mnt/c/Windows/System32:$PATH
win_ip_wlan=$(ipconfig.exe | sed -n '/WLAN/,/IPv4/p' | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
win_ip=$(ip route show | sed -n "1p" | awk -F" " '{print $3}') # 对应win的wsl虚拟网卡的ip
wsl_ip=$(ip add | grep inet | grep eth0 | awk -F" " '{print $2}' | cut -d"/" -f 1)

function pfdwin2wsl(){
    # 同一个wifi下访问win的时候被转发到wsl, 需要先执行wsl hosts, 因为这里使用的方法是转发你的数据到wsl.local
    if [ $1 = "--help" ]; then
        echo "pfdwin2wsl <win_port> <wsl_port>" 
    elif [ $1 = "--reset" ]; then
        netsh.exe interface portproxy reset > /dev/null
    elif [ $1 = "--show" ]; then
        netsh.exe interface portproxy show all
    elif [ "$1" -a "$2" ]; then
        netsh.exe interface portproxy add v4tov4 listenaddress=${win_ip_wlan} listenport=$1 connectaddress=wsl.local connectport=$2 > /dev/null
    elif [ $1 ]; then
        netsh.exe interface portproxy add v4tov4 listenaddress=${win_ip_wlan} listenport=$1 connectaddress=wsl.local connectport=$1 > /dev/null
    fi
}