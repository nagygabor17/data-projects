class Masik:
    oszt_attr = 5
    @classmethod
    def osztaly_metodus(cls):
        print(cls.oszt_attr)

    @classmethod
    def build_masik(cls, ertek):
        if type(ertek) != int:
            raise ValueError
        return Masik(ertek)

    def __init__(self, ertek):
        self.ertek = ertek

Masik.osztaly_metodus()

masik = Masik(6)
masik.osztaly_metodus()

masik2 = Masik.build_masik(8)
print(masik2.ertek)

print(Masik.__dict__)