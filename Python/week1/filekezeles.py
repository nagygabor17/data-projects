def myopen_for_read(filenev):
    return open(filenev, "r", encoding="UTF-8")

my_file = open("valami.txt", encoding="UTF-8")
for sor in my_file:
    print(sor, end="")
my_file.close()

my_file2 = open("fileok/xyz.txt", "r", encoding="UTF-8")
tartalom = my_file2.readlines()
print(tartalom)
my_file2.close()


my_file3 = open("valami3.txt", "w")
my_file3.write("cica")
my_file3.close()


my_file3 = open("valami3.txt", "w")
for x in range(0,10):
    my_file3.write(str(x)+ "\n")
my_file3.close()



my_file4 = open("valami4.txt", "a", encoding="UTF-8")
x = ['alma','korte', 'cica', 'kutya','körte']
my_file4.writelines(x)
my_file4.close()

