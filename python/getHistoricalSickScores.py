from urllib.request import Request, urlopen
import json
import csv

someurl = "https://mobilesvc.sickweather.com/ws/v1.1/getSickScoreHistorical.php"
data = ""
with open('zipcodes.csv') as f:
    csvRead = csv.reader(f, delimiter=',')
    for row in csvRead:
        a = str(row[1])
        params = "?api_key=GX3RD5Xx3wJmBSitk9Ee&pretty=false&country=US&zip="+a+"&ids=1,2,4,7,15&debug=false"
        req = Request(someurl+params)
        response = urlopen(req)
        string = response.read().decode('utf-8')
        data += string+"\n"

arrData = data.split('\n')
zipcode = ""
a1,a2,a3,a4,a5 = "0", "0", "0", "0", "0"
with open("historicalSickScores.csv", 'w') as out:
    out.write('zip,flu,bronchitis,cold,strep,pneumonia\n')
    for u in arrData:
        if(u != '' and u[0]!= '['):
            x = json.loads(u)
            for a in x.keys():
                if "historical" in x[a]:
                    y = x[a]["historical"]
                    zipcode = y["zip"]
                    dataJSON = y["data"][0]
                    if(dataJSON['illness']=="1"):
                        a1 = dataJSON['sick_score']
                    elif(dataJSON['illness']=="2"):
                        a2 = dataJSON['sick_score']
                    elif(dataJSON['illness']=="4"):
                        a3 = dataJSON['sick_score']
                    elif(dataJSON['illness']=="7"):
                        a4 = dataJSON['sick_score']
                    elif(dataJSON['illness']=="15"):
                        a5 = dataJSON['sick_score']
            out.write(zipcode+','+str(a1)+','+str(a2)+','+str(a3)+','+str(a4)+','+str(a5)+'\n')
