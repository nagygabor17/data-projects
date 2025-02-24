szamok = [1,2,3,4,5]

print(list(map(lambda x: x**4 ,szamok) ))

print(list(map(lambda x: x**4 , filter(lambda z: z%2 == 0, szamok)) ))


y = [x**2 for x in szamok]
print(y)

from functools import reduce
osszeg = reduce(lambda a,x: a+x, szamok)
print(osszeg)

szorzat = reduce(lambda a,x: a*x, szamok)
print(szorzat)
