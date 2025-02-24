from functools import reduce
numbers_eredeti = input("Adjon meg pozitiv egész számokat szóközzel elválasztva: ").split()
print(numbers_eredeti)

numbers=[1,2,3,4,5,6]
osszeg = reduce(lambda a,x: a+x, list(map(lambda z: z**3, filter(lambda i: i%2 !=0,numbers))))
print(osszeg)

converted_numbers = map(int, numbers_eredeti)
osszeg2 = reduce(lambda a,x: a+x, list(map(lambda z: z**3, filter(lambda i: i%2 !=0,converted_numbers))))
print(osszeg2)