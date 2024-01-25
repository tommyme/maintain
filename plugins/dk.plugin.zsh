# here is shortcut commands for docker 
alias dk="docker"
alias dk-r="docker run"
alias dk-b="docker build"
alias dk-p="docker pull"
alias dk-bt="docker build -t"
alias dk-rmit="docker run --rm -it"
alias dk-rmit-cache="docker run --rm -it -v ~/misc/apt-cache-cqupt:/var/lib/apt/lists"
alias dk-c="docker-compose"
alias dk-show-net="docker inspect --format='{{.Name}} - {{.HostConfig.NetworkMode}} - {{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \$(docker ps -aq)"
function dk-c-build-up(){ docker-compose -f $1 build && docker-compose -f $1 up }