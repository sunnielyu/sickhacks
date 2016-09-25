import json

with open('sickapi.json') as f:
    x = f.read()
    a = json.loads(x)
    print(a)
