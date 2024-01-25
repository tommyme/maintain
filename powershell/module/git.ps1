# 在 PowerShell 的配置文件中定义你想要的别名

function gcmsg {
    # 执行 git commit -m 命令
    git commit -m $args
}

function gco {
    # 执行 git checkout 命令
    git checkout $args
}

function gcb {
    # 执行 git checkout -b 命令
    git checkout -b $args
}

function grv {
    # 执行 git remote -v 命令
    git remote -v $args
}

function gba {
    # 执行 git branch -a 命令
    git branch -a $args
}

function gb {
    # 执行 git branch 命令
    git branch $args
}

function gp {
    # 执行 git push 命令
    git push $args
}

function gaa {
    # 执行 git add --all 命令
    git add --all $args
}
