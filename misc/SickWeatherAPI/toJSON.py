import json
import re

with open("output.txt") as f:
    string = f.readlines()[0]
    j = json.loads(string)
    p = re.compile('historical')
    m = p.match(string)
    print(string)
    print(m.group(0))

#: \S+ \[(.+)\].+'zip': '(\d+)
