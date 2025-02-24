class Harmadik:
    def kiir(x):
        print(x)

    @classmethod
    def kiir2(x):
        print(x)

    @staticmethod
    def kiir3(x):
        print(x)


class Negyedik(Harmadik):
    #def __init__(self):
    #    valtozo = 2
    def kiir3(x):
    #    print(x.valtozo)
        print("Negyedik")

harmadik = Harmadik()
harmadik.kiir()

Harmadik.kiir2()

Harmadik.kiir3("cica")

Negyedik.kiir3(6)