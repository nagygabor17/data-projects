import csv
adatok=[]
with open("input.csv","r") as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    header = next(csv_reader)
    print(header)
    for sor in csv_reader:
        adatok.append(sor)

print(adatok)

with open("output.csv","w",newline="") as outfile:
    csv_writer=csv.writer(outfile, delimiter="#")
    for x in adatok:
        csv_writer.writerow(x)