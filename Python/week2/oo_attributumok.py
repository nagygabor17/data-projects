class Egyik:
    osztaly_adattag = "alma"
    osztaly_lista = []
    def __init__(self, adattag):
        self.obj_adattag = adattag
        #self.osztaly_lista = []


e1 = Egyik(4)
e2 = Egyik(5)

print(e1.obj_adattag)
print(e2.obj_adattag)
print(e1.osztaly_adattag)
print(e2.osztaly_adattag)
print(Egyik.osztaly_adattag)
#Hibát dob
#print(Egyik.obj_adattag)

e1.osztaly_adattag = "cica"
print("----------")
print(e1.osztaly_adattag)
print(e2.osztaly_adattag)
print(Egyik.osztaly_adattag)

print("-----------")
Egyik.osztaly_adattag = "korte"
print(e1.osztaly_adattag)
print(e2.osztaly_adattag)
print(Egyik.osztaly_adattag)


e1.osztaly_lista.append(1)
e2.osztaly_lista.append(2)

print(e2.osztaly_lista)