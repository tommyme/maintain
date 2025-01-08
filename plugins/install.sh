#!/bin/zsh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
root="${HOME}/.oh-my-zsh/plugins"

for file in $SCRIPT_DIR/*; do
    if [[ ! "$file" == *.plugin.zsh ]]; then
        continue
    fi

    plugin_name="$(basename $file .plugin.zsh)"

    if [[ -d "${root}/${plugin_name}" ]]; then
        echo "${plugin_name} exists"
    else
        mkdir "${root}/${plugin_name}"
        ln -s "${file}" "${root}/${plugin_name}/${file:t}"
    fi
done
