from mycmds.cli import Command
import os
from mycmds.utils.funcs import safeExecContent, execute, errorf

@Command(group=True)
def toggle():
    """
    toggle state of xxx
    """
    pass

@Command(toggle)
def kara():
    cmd = "jq '.profiles[0].simple_modifications[0].to[0].key_code' ~/.config/karabiner/karabiner.json"
    res = safeExecContent(cmd)
    keyCode = 'left_control' if 'caps_lock' in res else 'caps_lock'
    cmd = f"""jq '.profiles[0].simple_modifications[0].to[0].key_code="{keyCode}"' ~/.config/karabiner/karabiner.json | sponge ~/.config/karabiner/karabiner.json"""
    execute(cmd)

@Command(toggle)
def wsj():
    """vscode workspace json file status toggle for frontend dev, make your workspace cleaner"""
    import json
    path = '.vscode/settings.json'
    if not os.path.exists(path):
        errorf(f"please create {path}")
        return
    with open(path, 'r') as f:
        data = json.load(f)
    
    target = [
        "**/.gitignore",
        "**/env.d.ts",
        "**/package.json",
        "**/pnpm-lock.yaml",
        "**/tsconfig.config.json",
        "**/tsconfig.node.json",
        "**/tsconfig.json",
        "**/.prettierrc.json",
        "**/.eslintrc.cjs",
        "**/node_modules",
        "**/.vscode",
        "**/vite-env.d.ts",
        "**/vite.config.ts"
    ]
    clean = ("**/tsconfig.json" in data['files.exclude'].keys() and data['files.exclude']["**/tsconfig.json"] == True)
    value = False if clean else True # 如果 clean 就 toggle 成 dirty
    for k in target: data['files.exclude'][k] = value

    with open(path, 'w') as f:
        json.dump(data, f, indent=4)

@Command(toggle)
def speech():
    item = 'com.apple.speech.recognition.AppleSpeechRecognition.prefs DictationIMNetworkBasedLocaleIdentifier'
    cmd=f"defaults read {item}"
    
    res = execute(cmd, content=True, IsSafe=True).strip()
    valid = ['en_US','zh_CN']
    if res in valid:
        cmd = f'defaults write {item} {1-valid.index(res)}'
    else:
        errorf(f'invalid output: {res}')

@Command(toggle)
def fnkey():
    item = "com.apple.keyboard.fnState"
    cmd = f'defaults read -g {item}'
    value = 'false' if execute(cmd, IsSafe=True, content=True).strip() == '1' else 'true'
    cmd = f"defaults write -g {item} -boolean {value}"
    execute(cmd)