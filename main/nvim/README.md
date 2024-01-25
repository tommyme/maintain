# use nvim everywhere

maybe you want to use nvim on your server, and your server is in your company, you don't have sudo privilge, you don't have access to the github and google.
that's very awful, so the ways below can help you get rid of that kind of things.

COPY your nvim_config and nvim_data to server can solve the problem

On macos and linux nvim_config locates in `~/.config/nvim`
nvim_data locates in `~/.local/share/nvim`

prepare the zip file:
```shell
# on your computer, please update your tarf to latest version
cd ~/Downloads
tarf ~/.local/share/nvim
mv nvim.tgz nvim-data.tgz
tarf ~/.config/nvim 
```


```shell
# on your server, consume you're in the home dir, and the zipped files are uploaded
rm -rf ~/.local/share/nvim
rm -rf ~/.config/nvim

x nvim.tgz && mv nvim ~/.config
x nvim-data.tgz && mv nvim ~/.local/share/
```
