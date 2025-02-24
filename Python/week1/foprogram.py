x = (1,2,3) #Tuple
y = [4,5,6] #Ez a lista

print(x[0], y[0])
print(len(x), len(y))

z="cica"
w= 5

print( "Ez a " + z +" " + str(w) + " éves." )
print("Ez a %s %d éves" % (z, w))
print("Ez a {} {} éves.".format(z,w) )
print(f"Ez a {z} {w} éves")

print("------")
def foo():
    return (2,3,4)

(x,y) = foo()
print(x,y)