'''
Keressük meg egy listában a legnagyobb 3-mal osztható számot!
'''

def legnagyobb_harommal_oszthato(bemenet : list):
    eredmeny = None
    for x in bemenet:
        if x % 3 != 0:
            continue
        #print("Végre 3-mal osztható!", x)
        if eredmeny is None:
            eredmeny = x
        elif x > eredmeny:
            eredmeny = x

    return eredmeny

#Nincs benne
lista = [1,2,4,7,8]
print(legnagyobb_harommal_oszthato(lista))
#Csak 1 van benne
lista = [1,2,4,6,7,8]
print(legnagyobb_harommal_oszthato(lista))
#Több van benne
lista = [1,2,4,6,7,9,8]
print(legnagyobb_harommal_oszthato(lista))

#Üres a lista
lista = []
print(legnagyobb_harommal_oszthato(lista))

