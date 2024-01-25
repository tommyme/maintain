import json

with open("IT.json", "r") as f:
    content = f.read()
    data = json.loads(content)

words = [i["name"] for i in data]

print(len(words))

def compile2finger(words):
    return "|".join(words)


print(compile2finger(words))