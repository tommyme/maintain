install: theme zsh_plugins work

ipython:
	./main/ipython_profile_ybw/install.sh
vim:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	ln -sf ~/maintain/.vimrc ~/.vimrc
tmux:
	./main/tmux/install.sh
vscode:
# 使用仓库的vscode配置
ifeq ($(OS),Windows_NT)
	@echo "Detected Windows, please use the following command to install manually:"
	@echo sudo New-Item -ItemType SymbolicLink -Force -Path "$env:USERPROFILE\AppData\Roaming\Code\User\settings.json" -Target "$env:USERPROFILE\maintain\main\vscode\settings.json"
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		@echo "Detected Linux"
	else ifeq ($(UNAME_S),Darwin)
		@echo "Detected macOS"
	else
		@echo "Unknown OS: $(UNAME_S)"
	endif
endif

# covered by install
theme:
	ln -sf ~/maintain/misc/*.zsh-theme ~/.oh-my-zsh/themes
zsh_plugins:
	python3 scripts/install_plugins.py
work:
	echo "insecure" > ~/.curlrc
	echo "defscrollback 50000" > ~/.screenrc
	echo "check_certificate = off" > ~/.wgetrc
	sudo ln -sf ~/maintain/main/unix_bin/sscp /usr/local/bin/
