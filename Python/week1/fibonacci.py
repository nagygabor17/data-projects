def fibonacci_rekurziv(n):
    print("Meghívva {}".format(n))
    if n <= 1:
        print("\tKilépési", n)
        return n
    print("\tEgyik {}".format(n-1))
    egyik = fibonacci_rekurziv(n-1)
    print("\tMasik {}".format(n-2))
    masik = fibonacci_rekurziv(n-2)
    print("Visszater ", egyik+masik)
    return egyik + masik

print(fibonacci_rekurziv(5))