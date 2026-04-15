# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# Mar 2013 Yad Smood
# Modified to add OS Nerd Font Icons and Hostname

# VCS
YS_VCS_PROMPT_PREFIX1=" %{$reset_color%}on%{$fg[blue]%} "
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}x"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}o"

# Git info
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# SVN info
local svn_info='$(svn_prompt_info)'
ZSH_THEME_SVN_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}svn${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_SVN_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_SVN_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_SVN_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"

# HG info
local hg_info='$(ys_hg_prompt_info)'
ys_hg_prompt_info() {
	# make sure this is a hg dir
	if [ -d '.hg' ]; then
		echo -n "${YS_VCS_PROMPT_PREFIX1}hg${YS_VCS_PROMPT_PREFIX2}"
		echo -n $(hg branch 2>/dev/null)
		if [[ "$(hg config oh-my-zsh.hide-dirty 2>/dev/null)" != "1" ]]; then
			if [ -n "$(hg status 2>/dev/null)" ]; then
				echo -n "$YS_VCS_PROMPT_DIRTY"
			else
				echo -n "$YS_VCS_PROMPT_CLEAN"
			fi
		fi
		echo -n "$YS_VCS_PROMPT_SUFFIX"
	fi
}

# Virtualenv
local venv_info='$(virtenv_prompt)'
YS_THEME_VIRTUALENV_PROMPT_PREFIX=" %{$fg[green]%}"
YS_THEME_VIRTUALENV_PROMPT_SUFFIX=" %{$reset_color%}%"
virtenv_prompt() {
	[[ -n "${VIRTUAL_ENV:-}" ]] || return
	echo "${YS_THEME_VIRTUALENV_PROMPT_PREFIX}${VIRTUAL_ENV:t}${YS_THEME_VIRTUALENV_PROMPT_SUFFIX}"
}

# OS Icon Detection (Requires Nerd Fonts)
os_icon_prompt() {
    local os_icon=""
    if [[ "$OSTYPE" == darwin* ]]; then
        os_icon="%{$fg[white]%}" # macOS (Apple)
    elif [[ "$OSTYPE" == linux-gnu* ]]; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            if [[ "$ID" == "ubuntu" ]]; then
                os_icon="%{$fg[yellow]%}" # Ubuntu
            elif [[ "$ID" == "arch" ]]; then
                os_icon="%{$fg[cyan]%}" # Arch Linux
            else
                os_icon="%{$fg[white]%}" # Generic Linux (Tux)
            fi
        else
            os_icon="%{$fg[white]%}" # Generic Linux
        fi
    elif [[ "$OSTYPE" == cygwin || "$OSTYPE" == msys || "$OSTYPE" == win32 ]]; then
        os_icon="%{$fg[blue]%}" # Windows
    else
        os_icon="%{$fg[white]%}" # Generic Terminal
    fi
    echo "%{$terminfo[bold]%}${os_icon}%{$reset_color%}"
}
local os_info='$(os_icon_prompt)'

local exit_code="%(?,,C:%{$fg[red]%}%?%{$reset_color%})"

gitcmt_prompt() {
	msg=$(timeout 0.02 git --no-pager log --oneline -1 --format="%H" 2>/dev/null | cut -c 1-12)
	echo "%{$terminfo[bold]$fg[green]%}${msg} %{$reset_color%}";
}
local gitcmt_info='$(gitcmt_prompt)'

conda_prompt() {
	if [ -n "$conda_init_complete" ] && command -v conda &> /dev/null; then
		env_name=$(conda info --envs | grep '*' | awk '{print $1}')
		echo " %{$terminfo[bold]$fg[green]%}:${env_name}:%{$reset_color%}";
	fi
}
local conda_info='$(conda_prompt)'

local proxy_info='$(proxy_prompt)'
proxy_prompt() {
    declare -i local cnt=0
    if [ "$http_proxy" != "" ]; then cnt+=1; fi
    if [ "$https_proxy" != "" ]; then cnt+=1; fi
    if [ "$all_proxy" != "" ]; then cnt+=1; fi
    if [ $cnt -gt 0 ]; then 
        echo " %{$terminfo[bold]$fg[green]%}[${cnt}px]%{$reset_color%}"; 
    else 
        echo " %{$terminfo[bold]$fg[red]%}[${cnt}px]%{$reset_color%}";
    fi
}

# Prompt format:
#
#  # PRIVILEGES USER @ MACHINE GIT_COMMIT in DIRECTORY on git:BRANCH STATE [TIME] C:LAST_EXIT_CODE
# $ COMMAND
#
PROMPT="
${os_info} %{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%(#,%{$bg[yellow]%}%{$fg[black]%}%n%{$reset_color%},%{$fg[cyan]%}%n)\
%{$reset_color%}@\
%{$fg[green]%}%m%{$reset_color%} \
${gitcmt_info}\
%{$reset_color%}in \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${hg_info}\
${git_info}\
${svn_info}\
${venv_info}\
${conda_info}\
${proxy_info}\
 $exit_code
%{$terminfo[bold]$fg[red]%}$ %{$reset_color%}"
