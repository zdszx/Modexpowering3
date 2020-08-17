#!python
#code:utf-8

import random
import time

def genBigRam(bits):
    ret = 0
    mul = 1
    for i in range(bits):
        ran = random.randint(0, 1)
        #ran = 1
        ret = ret + ran * mul
        mul = mul * 2
    
    return ret

def extGCD ( a , b ):
    if (b == 0):
        return 1 , 0 , a
    else:
        x, y, q = extGCD(b , a % b)
        # print x,y,q
        x, y = y, (x - a / b * y)
        return x, y, q

def printnum(n, n_len, r_len):
    s = ''
    for i in range(n_len/r_len):
        n0 = n % (2**r_len)
        s += '0x%0x, ' % n0
        print 'data[%d] = 0x%0x;' % (i,n0)
        n = n / (2**r_len)
    # print s[:-2]

import sys

R_len = 192
r_len = 32
seed = 0

if len(sys.argv) == 3:
    R_len = int(sys.argv[1])
    r_len = int(sys.argv[2])
elif len(sys.argv) == 4:
    R_len = int(sys.argv[1])
    r_len = int(sys.argv[2])
    seed = int(sys.argv[3])
else:
    print 'usage: python gen_mm_param.py R_bits n0_bits [seed]'
    sys.exit()


random.seed(seed)

N = genBigRam(R_len)
n = N % (2**r_len)

print "N = 0x%x" % N
printnum(N, R_len, r_len)
print ''

R = 1
for i in range(R_len):
    R = R * 2
rr = (R*R) % N
print "R^2  = 0x%x" % rr
printnum(rr, R_len, r_len)
print ''


r = 1
for i in range(r_len):
    r = r * 2

[r_inverse, n_inverse, gcd] = extGCD(r, n)
# print (r, n), extGCD(r, n)
# print str(r_inverse * r + n_inverse * n)

if r_inverse < 0:
    r_inverse = r_inverse % n;
    n_inverse = (r*r_inverse - 1) / n
else:
    n_inverse = -n_inverse


print "r*r^-1 - n*n' = 1"
print (r, n), '*', (r_inverse, -n_inverse), '= 1'
print ""
print "n0         = 0x%x" % n
print "r0         = 0x%x" % r
print "n0_inverse = 0x%0x" % n_inverse
print ''

print 'gen A B'
A = genBigRam(R_len)
print "A = 0x%x" % A
printnum(A, R_len, r_len)

B = genBigRam(R_len)
print "B = 0x%x" % B
printnum(B, R_len, r_len)


[R_inverse, N_inverse, gcd] = extGCD(R, N)
# print (r, n), extGCD(r, n)
# print str(r_inverse * r + n_inverse * n)

if R_inverse < 0:
    R_inverse = R_inverse % N;
    N_inverse = (R*R_inverse - 1) / N
else:
    N_inverse = -N_inverse

# print "0x%x * 0x%x - 0x%x * 0x%x = 0x%x" % (R,R_inverse,N,N_inverse, R*R_inverse-N*N_inverse)
print "R^-1 = 0x%x" % R_inverse

print 'A*B*R^-1 mod N = 0x%x' % ((A*B*R_inverse) % N)


def monPro2(a_bar, b_bar, N, R_len):
    a_bar_str = str(bin(a_bar))
    a_bar_str = a_bar_str[2:]
    len_a_bar_str = len(a_bar_str)   

    res = 0     
    for i in reversed(range(len_a_bar_str)):
        if(a_bar_str[i] == "1"):
            res = res + b_bar
        if(res % 2 == 1):
            res = res + N
        res = res >> 1   
        
    for i in range(R_len - len_a_bar_str):
        if(res % 2 == 1):
            res = res + N
        res = res >> 1
    
    if(res >= N):
        res = res - N
        
    return res

def monProHighr(a_bar, b_bar, N, n0, r_len, R_len):
    r = 2**r_len
    a_bar_str = str(bin(a_bar))
    a_bar_str = a_bar_str[2:]
    len_a_bar_str = len(a_bar_str)   

    S = 0
    for i in range(R_len/r_len):
        s0 = S % r;
        ai = a_bar % r;
        a_bar = a_bar / r;
        b0 = b_bar % r;

        qi = ((s0 + ai*b0)*n0) % r
        S = (S + ai*B + qi*N) / r
        # print i, "%x"%S
    
    if(S >= N):
        S = S - N
        
    return S

print "monPro2()      = 0x%x" % monPro2(A, B, N, R_len)
print "monProHighr()  = 0x%x" % monProHighr(A, B, N, n_inverse, r_len, R_len)

