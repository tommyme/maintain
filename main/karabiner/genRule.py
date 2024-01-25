import json
import time

timestamp = str(int(time.time()))[-4:]
afile = {
    'title': timestamp,
    'rules': []
}
rule = {"description": f'test_{timestamp}', "manipulators": []}
data = {
    "type": "basic",
    "from": {
        "key_code": "h",
        "modifiers": {
            "mandatory": ["control"],
            "optional": ["any"]
        }
    },
    "to": [
        {
            "key_code": "left_arrow"
        }
    ]
}


rule["manipulators"].append(data)
afile["rules"].append(rule)

with open('test.json', 'w') as f:
    json.dump(afile, f, indent=2)
