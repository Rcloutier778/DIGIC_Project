with open("test1Output.txt", 'r') as f:
    con=f.readlines()
    nc=''
    for c in con:
        for cc in c:
            nc+=cc.strip()
            nc+='\t'
        nc+='\n'
nc=nc[:-1]
with open("test1Output.txt","w+") as f:
    f.write(nc)
