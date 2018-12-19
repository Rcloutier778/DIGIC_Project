filestr='test1'
Qn=4
Qm=4

u=""
with open(filestr+'.txt','r') as f:
    lines = f.readlines()
    print(len(lines))
    for line in lines:
        for dig in line.split("\t"):
            if int(dig) > 0:
                u+='0'
            else:
                print("WARNING: An input was negative. I don't account for this")

            tempu = "{0:b}".format(int(dig))
            if len(tempu) < 8:
                tempu = "0"*(8-len(tempu)) + tempu
            u += tempu
            u += "\n"
u = u[:-1]

with open('conv_'+filestr+'.txt','w+') as f:
    f.write(u)
