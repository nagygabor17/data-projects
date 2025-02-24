'''
Egy listában szavak vannak, keressük meg azt a szót,
amiben a legtöbb, általunk megadott betű szerepel
'''


def max_betukereso(bemenet, betu):
    if len(betu) != 1:
        return None

    eredmeny = None
    max_elofordulas = None
    for x in bemenet:
        #elofordulas_szama = x.count(betu)
        elofordulas_szama = my_count(x, betu)
        if elofordulas_szama == 0:
            continue
        if eredmeny is None:
            eredmeny = x
            max_elofordulas = elofordulas_szama
        elif elofordulas_szama >= max_elofordulas:
            eredmeny = x
            max_elofordulas = elofordulas_szama

    return eredmeny


def my_count(szo, betu):
    eredmeny = 0
    for y in szo:
        if y == betu:
            eredmeny += 1
    return eredmeny

szo_lista = ["alma", "korte", "ananasz", "barackmag"]
print(max_betukereso(szo_lista, "o"))
print(max_betukereso(szo_lista, "a"))
print(max_betukereso(szo_lista, "x"))
print(max_betukereso(szo_lista, "cica"))