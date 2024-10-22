alias proxyoff="export https_proxy='' http_proxy='' all_proxy=''"
alias proxyon="export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890"
alias 0px="export https_proxy='' http_proxy='' all_proxy=''"
alias pon="proxyon"
alias poff="proxyoff"
alias syspoff="networksetup -setwebproxystate wi-fi off;networksetup -setsecurewebproxystate wi-fi off;networksetup -setsocksfirewallproxystate wi-fi off"
alias pchain="proxychains4"
# alias conn="curl google.com && curl baidu.com"
alias ipip='echo "public IP addr: $(curl -s http://myip.ipip.net)"'
alias pong="pon && google"
alias check_proxy="echo \$http_proxy \$https_proxy \$all_proxy"
alias gitpoff="git config --global --unset http.proxy;git config --global --unset https.proxy"
function 3px(){
    # only one arg -> 127.0.0.1
    poff
    if [ -z $2 ]; then
        export https_proxy=http://127.0.0.1:$1
    else
        export https_proxy=http://$1:$2
    fi
    export http_proxy=$https_proxy all_proxy=$https_proxy
}
function 2px(){
    poff
    # only one arg -> 127.0.0.1
    if [ -z $2 ]; then
        export https_proxy=http://127.0.0.1:$1
    else
        export https_proxy=http://$1:$2
    fi
    export http_proxy=$https_proxy
}
