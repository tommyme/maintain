install: theme zsh_plugins work

ipython:
	./main/ipython_profile_ybw/install.sh
vim:
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	ln -sf ~/maintain/.vimrc ~/.vimrc
tmux:
	./main/tmux/install.sh
ghostty:
	./main/ghostty/install.sh
gdb:
	./main/gdb/install.sh
vscode:
# 使用仓库的vscode配置
ifeq ($(OS),Windows_NT)
	@echo "Detected Windows, please use the following command to install manually:"
	@echo sudo New-Item -ItemType SymbolicLink -Force -Path "$env:USERPROFILE\AppData\Roaming\Code\User\settings.json" -Target "$env:USERPROFILE\maintain\main\vscode\settings.json"
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Darwin)
		mkdir -p ~/Library/Application\ Support/Code/User
		ln -sf ~/maintain/main/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
		ln -sf ~/maintain/main/vscode/mac/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
		@echo "VS Code settings and keybindings linked on macOS"
	else ifeq ($(UNAME_S),Linux)
		@echo "Detected Linux"
	else
		@echo "Unknown OS: $(UNAME_S)"
	endif
endif

nvim:
	git clone -b main https://github.com/tommyme/nvim.git ~/.config/nvim
	@echo "NVIM cloned to ~/.config/nvim"

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
	git config --global alias.reset-upstream 'reset @{u}'
