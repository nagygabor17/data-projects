szamok = [1,2,3,4,5,6]

def negyzetre_emel(x):
    return x*x;
eredmeny = []
for a in szamok:
    eredmeny.append(negyzetre_emel(a))
print(eredmeny)

negyzetre_emelt_szamok = map(negyzetre_emel, szamok)
print(negyzetre_emelt_szamok)
for b in negyzetre_emelt_szamok:
    print(b)
print("----")
for c in negyzetre_emelt_szamok:
    print(c)

negyzetre_emelt_szamok = map(negyzetre_emel, szamok)
szamlista = list(negyzetre_emelt_szamok)
print(szamlista)

negyzetre_emelt_szamok = map(negyzetre_emel, szamok)
negyedikre_emelt_szamok = map(negyzetre_emel, negyzetre_emelt_szamok)

print(list(negyedikre_emelt_szamok))

negyedikre_emelt_szamok = map(negyzetre_emel, map(negyzetre_emel, szamok))
print(list(negyedikre_emelt_szamok))


szamok2 = [1,1,1,1,1,1,1,1,1,2,3,4,5,6,7,8,9,10]
def paros_e(x):
    return x % 2 == 0

paros_szamok = filter(paros_e, szamok2)
print(list(paros_szamok))
negyzetre_emelt_paros_szamok = map(negyzetre_emel, filter(paros_e, szamok2))
print(list(negyzetre_emelt_paros_szamok))

def osszead(x,y):
    return x + y

def szorzas(x,y):
    return x *y

from functools import reduce
negyzetre_emelt_paros_szamok_osszege = reduce(osszead, map(negyzetre_emel, filter(paros_e, szamok2)))

print(negyzetre_emelt_paros_szamok_osszege)

negyzetre_emelt_paros_szamok_szorzata = reduce(szorzas, map(negyzetre_emel, filter(paros_e, szamok2)))
print(negyzetre_emelt_paros_szamok_szorzata)


