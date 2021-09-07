export ZSH="$HOME/.oh-my-zsh"

alias proxyOff="https_proxy='' http_proxy='' all_proxy=''"
alias proxyOn="https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890"
alias google="curl google.com"
alias baidu="curl baidu.com"
bindkey -s '\e\e' '\C-asudo \C-e'


ZSH_THEME="ys"

plugins=(git
zsh-autosuggestions
zsh-syntax-highlighting
)
	
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"

[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && source $HOME/.autojump/etc/profile.d/autojump.sh

autoload -U compinit && compinit -u
source $ZSH/oh-my-zsh.sh


