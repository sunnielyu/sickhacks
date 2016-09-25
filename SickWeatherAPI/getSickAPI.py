import csv
from urllib.request import Request, urlopen

someurl = "https://mobilesvc.sickweather.com/ws/v1.1/getSickScoreByZipcode.php"

with open('zipcodes.csv') as f:
    csvRead = csv.reader(f, delimiter=',')
    for row in csvRead:
        a = str(row[1])
        params = "?api_key=GX3RD5Xx3wJmBSitk9Ee&country=US&zip="+a+"&ids=1,2,4,7,15"
        req = Request(someurl+params)
        response = urlopen(req)
        string = response.read().decode('utf-8')
        with open('output.txt', 'w') as out:
            out.write(string+"\n")
