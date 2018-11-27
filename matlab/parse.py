import struct



def main():
    with open('W.dat','r') as f:
        data = f.read().strip()

        lines= data.split('\n')
        newdata=[]
        for line in lines:
            newline=[]
            digits = line.strip().split(',')
            for digit in digits:
                newline.append(tobin(float(digit)))
            newdata.append(newline)
    print lines[11][0]
    print newdata[11][0]
    print binary(float(lines[11][0]))
    print bin(lines[11][0])

def tobin(num):
    return ''.join(bin(ord(c)).replace('0b', '') for c in struct.pack('!f', num))

def binary(num):
    # Struct can provide us with the float packed into bytes. The '!' ensures that
    # it's in network byte order (big-endian) and the 'f' says that it should be
    # packed as a float. Alternatively, for double-precision, you could use 'd'.
    packed = struct.pack('!f', num)
    print 'Packed: %s' % repr(packed)

    # For each character in the returned string, we'll turn it into its corresponding
    # integer code point
    # 
    # [62, 163, 215, 10] = [ord(c) for c in '>\xa3\xd7\n']
    integers = [ord(c) for c in packed]
    print 'Integers: %s' % integers

    # For each integer, we'll convert it to its binary representation.
    binaries = [bin(i) for i in integers]
    print 'Binaries: %s' % binaries

    # Now strip off the '0b' from each of these
    stripped_binaries = [s.replace('0b', '') for s in binaries]
    print 'Stripped: %s' % stripped_binaries

    # Pad each byte's binary representation's with 0's to make sure it has all 8 bits:
    #
    # ['00111110', '10100011', '11010111', '00001010']
    padded = [s.rjust(8, '0') for s in stripped_binaries]
    print 'Padded: %s' % padded

    # At this point, we have each of the bytes for the network byte ordered float
    # in an array as binary strings. Now we just concatenate them to get the total
    # representation of the float:
    return ''.join(padded)

if __name__ == "__main__":
    main()
