# env-setup.plugin.zsh - Environment setup for bun, miniconda, nvm, etc.

# >>> conda initialize >>>
__conda="$HOME/.miniconda"
function conda_init(){
    # mac上我是使用brew安装的miniconda
    # 这里的代码针对于 linux上的miniconda
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    if [ -d "$__conda" ] && [ -n "$__conda" ]; then
        __conda_setup="$('$__conda/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "$__conda/etc/profile.d/conda.sh" ]; then
                . "$__conda/etc/profile.d/conda.sh"
            else
                export PATH="$__conda/bin:$PATH"
            fi
        fi
    fi
    unset __conda_setup
    conda_init_complete=1
    # <<< conda initialize <<<
}
# <<< conda initialize <<<

# >>> nvm initialize >>>
function nvm_init(){
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    fi
    # <<< nvm initialize <<<
}

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# acme.sh
if [ -d "$HOME/.acme.sh/acme.sh.env" ]; then
    . "$HOME/.acme.sh/acme.sh.env"
fi

# JetBrains
___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"
if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then
    . "${___MY_VMOPTIONS_SHELL_FILE}"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zoxide
if command -v zoxide > /dev/null; then
    eval "$(zoxide init zsh)"
fi
alias j=z

# thefuck
if command -v thefuck > /dev/null; then
    eval $(thefuck --alias)
fi

# fzf
if command -v fzf > /dev/null; then
    source <(fzf --zsh)
fi
