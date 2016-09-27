import csv
import json
from urllib.request import Request, urlopen

sickScoreAPI = "https://mobilesvc.sickweather.com/ws/v1.1/getSickScoreByZipcode.php"
data = ""
dataJSON = ""

with open('zipcodes.csv') as f:
    csvRead = csv.reader(f, delimiter=',')
        for row in csvRead:
            zipMD = str(row[1])
            params = "?api_key=GX3RD5Xx3wJmBSitk9Ee&country=US&zip="+zipMD+"&ids=1,2,4,7,15"
            req = Request(sickScoreAPI+params)
            response = urlopen(req)
            response = response.read().decode('utf-8')
            data += response + '\n'


arrData = data.split('\n')

with open('currentSickScores.csv', 'w') as out:
    out.write('zip,flu,bronchitis,cold,strep,pneumonia\n')
    for u in arrData:
        if(u! = "" and u[0] != '['):
            dataJSON = json.loads(u)
            a1,a2,a3,a4,a5 = "0", "0", "0", "0", "0"
            for a in dataJSON:
                if(a!="0"):
                    zipcode = dataJSON[a]['zip']
                    if(dataJSON[a]['illness']=="1"):
                        a1 = dataJSON[a]['sick_score']
                    elif(dataJSON[a]['illness']=="2"):
                        a2 = dataJSON[a]['sick_score']
                    elif(dataJSON[a]['illness']=="4"):
                        a3 = dataJSON[a]['sick_score']
                    elif(dataJSON[a]['illness']=="7"):
                        a4 = dataJSON[a]['sick_score']
                    elif(dataJSON[a]['illness']=="15"):
                        a5 = dataJSON[a]['sick_score']
            out.write(zipcode+','+str(a1)+','+str(a2)+','+str(a3)+','+str(a4)+','+str(a5)+'\n')
