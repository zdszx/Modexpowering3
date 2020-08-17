import sys
def extGCD ( a , b ):
    def extGCD_core ( a , b ):
        if (b == 0):
            return 1 , 0 , a
        else:
            x , y , q=extGCD_core( b , a % b )
            # print x,y,q
            x , y = y,( x - a / b * y )
            return x , y , q

    x, y, q = extGCD_core(a, b)
    if x < 0:
        x = x % b;
        y = -(a*x - 1) / b
    return x , y , q

# print extGCD(11, 16)
# print ""
# print extGCD(16, 11)

if len(sys.argv) != 3:
    print 'usage: python extGCD.py a b'
    sys.exit()

a = int(sys.argv[1])
b = int(sys.argv[2])
x, y, q = extGCD(a, b)
print a, '*', x, '+', b, '*', y, '= 1'

# a = 11
# b = 2**32
# x, y, q = extGCD(a, b)
# print a, '*', x, '+', b, '*', y, '= 1'

