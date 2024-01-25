install: theme zsh_plugins

theme:
	ln -sf ~/maintain/misc/*.zsh-theme ~/.oh-my-zsh/themes
zsh_plugins:
	python3 scripts/install_plugins.py
ipython:
	./main/ipython_profile_ybw/install.sh