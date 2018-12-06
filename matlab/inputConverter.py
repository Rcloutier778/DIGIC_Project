filestr='test1'
Qn=4
Qm=4

u=""
with open(filestr+'.txt','r') as f:
    lines = f.readlines()
    for line in lines:
        for dig in line.split("\t"):
            if int(dig) > 0:
                u+='0'
            else:
                print("WARNING: An input was negative. I don't account for this")

            u += "{0:b}".format(int(dig))
            u += "\n"
u = u[:-2]

with open('conv_'+filestr+'.txt','w+') as f:
    f.write(u)
