from functools import reduce
numbers = input("Adjon meg pozitiv egész számokat szóközzel elválasztva: ").split()
print(numbers)
converted_numbers = map(int, numbers)
#print(bool(1))
odd_numbers = filter(lambda x: x%2 != 0,converted_numbers)
#print(list(odd_numbers))
transformed_numbers = map(lambda x: x**3 ,odd_numbers)
#print(list(transformed_numbers))

sum_transformed = reduce(lambda a,x: a+x, transformed_numbers, 0)
print(sum_transformed)