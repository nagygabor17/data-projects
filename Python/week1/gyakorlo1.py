def paros_szamok(kezdet, veg):
    if kezdet % 2  == 1:
        kezdet += 1
    eredmeny = []
    for i in range(kezdet,veg,2):
        eredmeny.append(str(i) + "\n")
    return eredmeny

with open("gyakorlo1.txt", "w", encoding="UTF-8") as file_amibe_irok:
    file_amibe_irok.writelines(paros_szamok(1,101))
