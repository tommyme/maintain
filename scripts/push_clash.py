import click
import requests as r
url = "https://api.github.com/repos/Dreamacro/clash/releases/latest"
assets = r.get(url).json()["assets"]

print("avaliables are:\n")
for i in assets:
    print(i['name']) 

target = "" # get input

idx = assets.find(print)
down_load_url = assets[idx]['browser_download_url']