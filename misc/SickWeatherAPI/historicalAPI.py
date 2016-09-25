from urllib.request import Request, urlopen
import json
import csv

someurl = "https://mobilesvc.sickweather.com/ws/v1.1/getSickScoreHistorical.php"

with open('zipcodes.csv') as f:
    csvRead = csv.reader(f, delimiter=',')
    for row in csvRead:
        a = str(row[1])
        params = "?api_key=GX3RD5Xx3wJmBSitk9Ee&pretty=false&country=US&zip="+a+"&ids=1,2,4,7,15&debug=false"
        req = Request(someurl+params)
        response = urlopen(req)
        string = response.read().decode('utf-8')
        print(string)
        with open('output.txt', 'w') as out:
            out.write(string+"\n")

#j = json.loads(string)
#print(j[3]["historical"])
