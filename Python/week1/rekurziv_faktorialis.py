def faktorialis_rekurziv(n):
    print("Meghívva", n)
    if n <= 1:
        return 1
    kisebb_faktorialis = faktorialis_rekurziv(n-1)
    ertek = n * kisebb_faktorialis
    print("\tVisszatér {} * {} = {}".format(n, kisebb_faktorialis, ertek))
    return ertek


print(faktorialis_rekurziv(1))
print(faktorialis_rekurziv(3))