'''
Python code for ModExp project      RSA4096

This file initializes and outputs all variable files needed for ModExp FPGA code.
It also has three complete MonPro implementations and ModExp implementations to help verify FPGA code.

@author: Qin Zhou   (fatestudio@gmail.com)
'''
import random
random.seed(0)
BYTES = 512    # How many bytes in a number: since we use 2048 bits, should be 512 bytes.
LEN = 32     #   If we want output to be 128-bit in word size, here should be 128/4 = 32
WORDN = BYTES // LEN
OUTPUTPATH = "E:\\ms project\\!Clean Folder\\ModExpBlinding\\"     # the directory we want to output the files
OUTPUTSIMULATIONPATH = OUTPUTPATH + "\\simulation\\modelsim\\"

def numTo8BytesStr(n): # Extend not long enough string to 8 bytes
    s = str(hex(n))[2:]
    if(len(s) < 8):
        zeros = ""
        for i in range(8 - len(s)):
            zeros = zeros + "0"
        s = zeros + s
    return s
    
def numToBYTESByteStr(n):      # Extend not long enough string to BYTES bytes
    s = str(hex(n))[2:]
    if(s[len(s) - 1] == 'L'):
        s = s[:-1]
    if(len(s) < BYTES):
        zeros = ""
        for i in range(BYTES - len(s)):
            zeros = zeros + "0"
        s = zeros + s
    return s

def numToBinaryStr(e):      # convert a number to binary string
    estr = str(bin(e))[2:]
    if(estr[len(estr) - 1] == 'L'):
        estr = estr[:-1]
    return estr
    
def out2memhfile(n, filename):  # output for readmemh txt file 
    n_file = open(filename, 'w')
    s = numToBYTESByteStr(n)
    print(len(s))

    for i in range(WORDN):
        n_file.write(s[(WORDN - i - 1) * LEN : (WORDN - i - 1) * LEN + LEN])
        n_file.write("\t")
    n_file.close()

def out2memhfile0(n0, filename):    # output for readmemh txt file and only output one word     Must guarantee n0 is one word in length
    n_file = open(filename, 'w')
    s = numToBYTESByteStr(n0)
    
    n_file.write(s[(WORDN - 1) * LEN : (WORDN - 1) * LEN + LEN])
    n_file.close()
    
def out2tbfile(headstr, n, filename):    # generate output for testbench input (tb file)
    n_file = open(filename, 'w')
    s = numToBYTESByteStr(n)
    for i in range(WORDN):
        n_file.write("#10\t" + headstr + " = " + str(LEN * 4) + "'h" + s[(WORDN - i - 1) * LEN: (WORDN - i - 1) * LEN + LEN] + ";")
        n_file.write("\n")
    n_file.close()

def mod_inverse(a, b):  # get the inverse
    r = -1
    B = b
    A = a
    eq_set = []
    full_set = []
    mod_set = []

    #euclid's algorithm
    while r!=1 and r!=0:
        r = b%a
        q = b//a
        eq_set = [r, b, a, q*-1]
        b = a
        a = r
        full_set.append(eq_set)

    for i in range(0, 4):
        mod_set.append(full_set[-1][i])

    mod_set.insert(2, 1)
    counter = 0

    #extended euclid's algorithm
    for i in range(1, len(full_set)):
        if counter%2 == 0:
            mod_set[2] = full_set[-1*(i+1)][3]*mod_set[4]+mod_set[2]
            mod_set[3] = full_set[-1*(i+1)][1]

        elif counter%2 != 0:
            mod_set[4] = full_set[-1*(i+1)][3]*mod_set[2]+mod_set[4]
            mod_set[1] = full_set[-1*(i+1)][1]

        counter += 1

    if mod_set[3] == B:
        return mod_set[2]%B
    return mod_set[4]%B



def monProBitShift(a_bar, b_bar, n, r_len): # normal one bit version, r_len is total bits.
    a_bar_str = str(bin(a_bar))
    a_bar_str = a_bar_str[2:]
    len_a_bar_str = len(a_bar_str)   

    res = 0     
    for i in reversed(range(len_a_bar_str)):
        if(a_bar_str[i] == "1"):
            res = res + b_bar
        if(res % 2 == 1):
            res = res + n
        res = res >> 1   
        
    for i in range(r_len - len_a_bar_str):
        if(res % 2 == 1):
            res = res + n
        res = res >> 1
    
    while(res >= n):
        res = res - n
        
    return res

def num2list(num, WORDN, divisor):    # WORDN: word number, number of bytes   divisor: base number...   
    ret = []
    for i in range(WORDN):
        ret.append(num % divisor)        #int(s[(WORDN - i - 1) * WORDL: (WORDN - i - 1) * WORDL + WORDL], 16)
        num = num // divisor
        
    return ret

def list2num(list, WORDN, divisor):    # WORDN: word number, number of bytes   divisor: base number...   
    ret = 0
    exp = 1
    for i in range(WORDN):
        ret = ret + list[i] * exp
        exp = exp * divisor
        
    return ret
    
def printNumList(v, WORDN):     # print number list value
    print("printNumList:")
    for i in range(WORDN):
        print(hex(v[i]))

def genN0prime(n, WORDN, WORDL):
    r0 = 2 ** (4 * WORDL)
    nlist = num2list(n, WORDN, r0)
    n0 = nlist[0]
    n0inv = mod_inverse(n0,r0)
    n0prime = r0 - n0inv
    return n0prime
    
def monProWordShift(a_bar, b_bar, n, WORDN, WORDL): # normal LEN * 4 bit version       Following ICD document 2.2        WORDN: word length
# WORDN: word number, number of bytes   WORDL: word length   in bytes
    # exactly the same as genN0prime but we want to use intermediate variables in this MonPro function
    r0 = 2 ** (4 * WORDL)
    nlist = num2list(n, WORDN, r0)
    n0 = nlist[0]
    n0inv = mod_inverse(n0,r0)
    n0prime = r0 - n0inv
    
    alist = num2list(a_bar, WORDN, r0)
    blist = num2list(b_bar, WORDN, r0)
    
    v = []
    for i in range(WORDN + 1):
        v.append(0)
    
    for i in range(WORDN):
            
        # step 1
        for j in range(WORDN):
            v[j] = alist[i] * blist[j] + v[j]
            v[j + 1] = v[j + 1] + v[j] // r0   # integer division!!
            v[j] = v[j] % r0
        
        # step 2
        m = n0prime * v[0] % r0
        
        # step 3
        for j in range(WORDN):
            v[j] = m * nlist[j] + v[j]
            v[j + 1] = v[j + 1] + v[j] // r0
            v[j] = v[j] % r0
        
        
        # step 4
        for j in range(WORDN):
            v[j] = v[j + 1]
        v[WORDN] = 0
        
    ret = 0 * 2 ** (WORDN * WORDL * 4)
    exp = 1
    for i in range(WORDN):
        ret = ret + v[i] * exp
        exp = exp * r0

    if(ret >= n):
        ret = ret - n
    
    return ret

def monProWikiVersion(a_bar, b_bar, n, BYTES):   # wiki version
    sum = a_bar * b_bar 
    r = 2 ** (BYTES * 4)
    nprime = (-mod_inverse(n, r)) % r
    c_bar = (sum + (sum * nprime % r) * n) // r
    if(c_bar >= n):
        c_bar -= n
    return c_bar

def modExpBitShift(m, e, n):
    estr = numToBinaryStr(e)

    r = (2 ** (BYTES * 4)) % n
    t = 2 ** ((BYTES * 4) * 2) % n
    m_bar = monProBitShift(m, t, n, BYTES * 4)
    c_bar = r
    for i in range(len(estr)):
        c_bar = monProBitShift(c_bar, c_bar, n, BYTES * 4)
        if(estr[i] == '1'):
            c_bar = monProBitShift(c_bar, m_bar, n, BYTES * 4)
    c = monProBitShift(c_bar, 1, n, BYTES * 4)
    
    return c
            
def modExpWordShift(m, e, n):
    n_file = open("runtime_log.txt", 'w')
    estr = numToBinaryStr(e)
    
    r = (2 ** (BYTES * 4)) % n
    t = 2 ** ((BYTES * 4) * 2) % n
    m_bar = monProBitShift(m, t, n, BYTES * 4)
    c_bar = r
    for i in range(len(estr)):
        n_file.write(str(i) + "\n")
        n_file.write(str(hex(c_bar)) + "\n")
        
        c_bar = monProWordShift(c_bar, c_bar, n, WORDN, LEN)
        
        if(estr[i] == '1'):
            c_bar = monProWordShift(c_bar, m_bar, n, WORDN, LEN)
        
    c = monProWordShift(c_bar, 1, n, WORDN, LEN)
    
    n_file.close()
    return c
    
def modExpWikiVersion(m, e, n):
    estr = numToBinaryStr(e)
    
    r = (2 ** (BYTES * 4)) % n
    t = 2 ** ((BYTES * 4) * 2) % n
    m_bar = monProWikiVersion(m, t, n, BYTES)
    c_bar = r
    for i in range(len(estr)):
        c_bar = monProWikiVersion(c_bar, c_bar, n, BYTES)
        if(estr[i] == '1'):
            c_bar = monProWikiVersion(c_bar, m_bar, n, BYTES)
    c = monProWikiVersion(c_bar, 1, n, BYTES)
    
    return c

    


# initialize numbers and output them to files
n = 0x89cf8be62cbef276f08e4ab924ca82cd2b9047aaac427714afb6d2cc2cd44e174c6b50cc5026565d691e864f3a63840b1751269d08e81364d656f675aaf01c5e8e8d4df2c347c12613ee998bbac8b4becca7a0bbcee286689e9ae806129ac9aa7879e7738f16dcb79a9fb179c309e5a1eca6ca2536ff59d9235cc0c498f31016cd62d101df08ac2947c9b8127154d4bb69be40af8804b460222175439447a3108262d304395fb5345ce83ba14b6e0702745082f3aed92770ca1dc514005950cd97c8b9dd5f209571a65d9d5c00b23e85f7b57572c75a6dfacc830396973794bea38acfd8bee53c5ffed87cae3543c34618e742687b14a326dc28001b0d29fb182a576fb4cceae2008abdb7a55a51f36d08ac0baa02fa8cbd26a1c0c7db44284e5cb6858cf231d05fa3dec31efcb62665674b6bd0c99234725b15833fb39da0c03d1129a043e4db49f7432b0876c37d9167f534418c832031c7e08db017d45836166b52794bdcc34432ff3226c07ab0d20af80a9c2c5d6c11e65911a9e75a92afc3f10c1b5a1312506be4f63a5c9c221b89db32c6461922694b042192411b717b2184f1393111aac48c61c581ebe780f5ccefc09d66cb06919b73fc2dd2c497c5505b1a6037d540464b8bc9db81d4d368c6cd82bd9553cd4d595b62dde5caebf0e4ac5cb55393eca29874a1cd280d78b4218509770414de1125d4db98a62532dd
print("n:")
print(hex(n))
out2memhfile(n, OUTPUTPATH + "n.txt")
out2memhfile(n, OUTPUTSIMULATIONPATH + "n.txt")


r = (2 ** (BYTES * 4)) % n
print("r:")
print(hex(r))
out2memhfile(r, OUTPUTPATH + "r.txt")
out2memhfile(r, OUTPUTSIMULATIONPATH + "r.txt")

m = 0x444d9850809f292387a1798fe6addd9e61d9fe398147a8f45f0ef320f7f60e7f75f2bc20a7f5195cde62d43f261908b9ccf719ab2922fbd8dca5b35354a1d50572d6bc20d80d6a1cc2472fd603e9ba024cea2df00a66dc4e21681081399f8a8f10fc9eee0a1727f7ea5f24b6de6fec4b843b2a7d15ab2c21ccc93ff710fce97d786e30efce9b2e70b4d4dfccb7d779cc4b5ca436953c178e61067a8cd7a3283c27e969e2c8bf23fb9a431f7a41c30359dfde228125fb5f3d866d7002091472ad52631db9d17034ce51797350e6256403bf3df0bbf66ac168b4a1ca795718ada2027c013f38018399ee6a8e2f9c19ed348af5890333b5b3cedfec4623ab899605a2939b3b7fa74d8aff88ec827f99d273d5627386528cc241e345ac72eac39204ade7cef37ed2ec2f856f3d95e0ae1a1b6c596216ae0fdbc8a36bcb0167e98363905c053b25fdacbe7ce71b48fba52e5998a33736fd1ac7ce1ad0a6f226bdd974d3b564b08be04c3e5c94938160c6b3ed755a3ac132ae2a201ac902ee25777cf09f9821883744da64cc249558f2ad985fff3e0ba10ac728b4a41865bf350d278d41a8a6e165e049937f411fed1e70e79933a1d1c2ad4ab155c09fcd8f739cd488869bdbd2e72bb5b707120911b3b68b57da54f267dd138266d26d53961058fe8c1d7173e55bc7fdeb31234efe6e6480432aa50f4ec6f0093395d1805142cb6d1d
print("m:")
print(hex(m))
out2tbfile("inp", m, "m.tb.txt")    # changed the output file name for FPGA code...     # Don't need to output to destination folder
t = 2 ** ((BYTES * 4) * 2) % n
print("t:")
print(hex(t))
out2tbfile("inp", t, "t.tb.txt")
out2memhfile(t, OUTPUTPATH + "t.txt")
out2memhfile(t, OUTPUTSIMULATIONPATH + "t.txt")
e1 = 0xd
out2memhfile(e1, "d.txt")           # changed the output file name for FPGA code...

# Some useful values
n0prime = genN0prime(n, WORDN, LEN)
print("n0prime:")
print(hex(n0prime))
out2memhfile0(n0prime, OUTPUTPATH + "nprime0.txt")
out2memhfile0(n0prime, OUTPUTSIMULATIONPATH + "nprime0.txt")

def verifyMonPro():
    # Test case for MonPro module in Verilog
    x = 0x85c6fbd7a14b29e9a0c43b9079af1efdfedb388703440439995f5b743a03a3457ec12aea82e70a564e024d4f1ae1fd7ea7f98bc2834875efcac4af23fddf6b7cf03cef093bb59568d6aa35231d3f4adf3c10f85cb37ec67966dd0b72ed415dd00cb7a6bec02707b89d883d7e5421f79f5d87ae8b2745d936ec9abebfae1785aae7a23ff2dbc958e111752fbd04264989780e18376106d3e46053144617a22635c373d15b0fae83fbe1630a5ecb66d31cd5ad24b9cb505666ae9ecc4db7ab7977d734fa473f8388d4f018e8c63e294854b79f1aa3658f233a759358b1252f1a3e5c0002d13fd8abc9c2f362b170ab1acff0f6e90cffd0736c886fe1375961aaeb7d41d8075d90786a79c0bee236b3a471e07926434e4f301466aa8c97c71aedcfe58200bfaa73734a36d9f210f2bcc548f153f810cefa9a24b3d26358901bd9694f46b2f303e37f54413aa9b4a749c786aad871a7e7f86f12f410267865e5dbdeb4c849ed3b86200718e6090c2e39edd6506f02396c32f363766926ca5fc8469d83aba1f64882b78746c2b474b3ec44387ef207b99ae0e650b737deb3a1a409642c1707cf1603eecfdcbbff34ed19385923bcdfd51de18a49cf6a12b7a7ba6cb079a90603846c4ce9791151127f410afb56711527a2aa1be854d22f3ffede86f21aff4fa292cfa3eec6260f329eda29d89ec25c0c7c03478ebe9824fc1b36fd9c

    y = x
    print("result:")
    print(hex(monProBitShift(x, y, n, BYTES * 4)))
    print(hex(monProWordShift(x, y, n, WORDN, LEN)))

    # VERIFY MONPRO
    print("Verify three kinds of MonPro:")
    print("monpro result:")
    rinv = mod_inverse(r % n, n)
    # SHOW the correct multiplication result 
    print("m * rinv * t * rinv * r % n = ")
    print(hex(m * rinv * t * rinv * r % n))
    print("monProBitShift:")
    print(hex(monProBitShift(m, t, n, BYTES * 4)))
    print("monProWordShift:")
    print(hex(monProWordShift(m, t, n, WORDN, LEN)))  # word number is WORDN, length is LEN       2   1
    print("monProWikiVersion:")
    print(hex(monProWikiVersion(m, t, n, BYTES)))


    print("Result of r monpro r:")
    print(hex(monProBitShift(r, r, n, BYTES * 4)))
    print(hex(monProWordShift(r, r, n, WORDN, LEN)))
    print(hex(monProWikiVersion(r, r, n, BYTES)))

    print("See more results to confirm MonPro is correct:")
    m_bar = monProBitShift(m, t, n, BYTES * 4)      
    print("m_bar:")
    print(hex(m_bar))
    c_bar = monProBitShift(r, m_bar, n, BYTES * 4)      # FIRST 1 bit   finished
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, c_bar, n, BYTES * 4)      
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, m_bar, n, BYTES * 4)  # SECOND 1 bit  finished
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, c_bar, n, BYTES * 4)      
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, m_bar, n, BYTES * 4)  # THIRD 1 bit   finished
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, c_bar, n, BYTES * 4)      
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, m_bar, n, BYTES * 4)  # FOURTH 1 bit   finished
    print(hex(c_bar))
    c_bar = monProBitShift(c_bar, 1, n, BYTES * 4)      
    print(hex(c_bar))
    #c_bar = monProBitShift(c_bar, m_bar, n, BYTES * 4)  # SECOND 1 bit
    #print(hex(c_bar))


def verifyModExp():
    '''
    print("Show results of ModExp(m, e1, n) of different methods")
    c = m ** 0xd % n
    e1 = 0x1ffffffffffffffffffffffffffffffff
    print("e1:")
    print(hex(e1))
    #print("m ^ e1 % n")
    #print(hex(m ** e1 % n))
    print("modExpBitShift:")
    print(hex(modExpBitShift(c, e1, n)))
    print("modExpWordShift:")
    print(hex(modExpWordShift(c, e1, n)))
    print("modExpWikiVersion:")
    print(hex(modExpWikiVersion(c, e1, n)))

    # Verify ModExp
    print("Show results of ModExp(m, e1, n) of different methods")
    print("e1:")
    print(hex(e1))
    print("m ^ e1 % n")
    print(hex(m ** e1 % n))
    print("modExpBitShift:")
    print(hex(modExpBitShift(m, e1, n)))
    print("modExpWordShift:")
    print(hex(modExpWordShift(m, e1, n)))
    print("modExpWikiVersion:")
    print(hex(modExpWikiVersion(m, e1, n)))

    e2 = 0x80
    print("Show results of ModExp(m, e2, n) of different methods")
    print("e2:")
    print(hex(e2))
    print("m ^ e2 % n")
    print(hex(m ** e2 % n))
    print("modExpBitShift:")
    print(hex(modExpBitShift(m, e2, n)))
    print("modExpWordShift:")
    print(hex(modExpWordShift(m, e2, n)))
    print("modExpWikiVersion:")
    print(hex(modExpWikiVersion(m, e2, n)))

    e3 = 0x8000
    print("Show results of ModExp(m, e3, n) of different methods")
    print("e3:")
    print(hex(e3))
    #print("m ^ e3 % n")        Impossible...
    #print(hex(m ** e3 % n))
    print("modExpBitShift:")
    print(hex(modExpBitShift(m, e3, n)))
    print("modExpWordShift:")
    print(hex(modExpWordShift(m, e3, n)))
    print("modExpWikiVersion:")
    print(hex(modExpWikiVersion(m, e3, n)))
    '''
    # test case for ModExp module in Verilog
    e4 = 0x7f35bc36ee3a1ae3f1be6c5c21f6029600d3f362779fd061dd464c6db33a20b30b76c0bc98c0ed42886af221bfbe5280644ae890f487745d149f0ae2c52c68f4d25b0ce016b863859c3eb51e8508094da9384599ab4740fe1c4038a324dda675f90e10b97063df6e6758550def1cd3f7ee23ce49bc9cf079aa7d00b5797de7778282998b92ccedaff37f20110626ebc0b060d93f913f6b6c6e4644dbeb55d19915e5118dbece7fe190d65e6d80b4553d57acc7a5dc79ae40ba91a239d8effbd1786a842ecdf6b155371b562d8a7d2605823158b8b804b449f7db65c6156e61eb0d1dac2a88d39a313a02e93e588d51ca8d243d4cc061d1adb787628f1fd7fb7769c5c22a8e74013472afa1910af8130830329c6ef04674886b3dd7f0de6b68d01e9aab82e29eb85a763a640f52bd42049baa1b92c3bac1c51d16879a0752b20f8fb356088b8d45ab3133da7d0fd94db891bde963b1f140ff87aa710c711666c3e6c5fb61d6bacbadacff72dcacfc63aef9fcf271b35e91169e0eefb63ce7105b4df3ca564dce6edf0cd8f67cdbb5892791375bc2bbc5f39dc500161269800483bc63c5d078725c7c7bb9e296bbad8fc13c5c69b020e8d6f5f610c96c43425579d22602bedaa769279125eb4209ae2c5c6e2bd5a9be69267322d17f27ea039e862c9a7154c0e67aa70950bdc0b546872d0b2aa4a40a176d5cb7fa6b9ab5f00255
    out2memhfile(e4, OUTPUTPATH + "d.txt") 
    out2memhfile(e4, OUTPUTSIMULATIONPATH + "d.txt") 
    print("Show results of ModExp(m, e4, n) of different methods")
    print("e4:")
    print(hex(e4))
    c1 = modExpBitShift(m, e1, n)
    out2tbfile("inp", c1, OUTPUTPATH + "c.tb.txt")
    out2tbfile("inp", c1, OUTPUTSIMULATIONPATH + "c.tb.txt")
    #print("m ^ e4 % n")        Impossible...
    #print(hex(m ** e4 % n))
    print("modExpBitShift:")
    print(hex(modExpBitShift(c1, e4, n)))
    print("modExpWordShift:")
    print(hex(modExpWordShift(c1, e4, n)))
    print("modExpWikiVersion:")
    print(hex(modExpWikiVersion(c1, e4, n)))

def blinding():
    # Blinding related, same other variables as above
    R = 0x34c5b4763fe31d0347fc816ac16e2284c10faa4003ba33db73f7ba8e0445d656de3a5db5154ed51212093d26ac512b01f18dd1eed77c96c0084f3dd6415af341ee52bdb6d1020a15d9ed17e3cc0e95ee8d103ed3cc667e971773308cdc6b13ab2e47dc0e959f3a518cfe5cd12d5db79ba2a7ae1f3ac7652ccdf8440407295e4299901c0475491bc354c56c9a9cc9af4ec9546b439f9d01298a449ebe89d9bf020067dba8589890086a17b9af5b569643d037cdff7c240d4969d495dd81355c53f0e642f43328ad088ded3c9691eb79fa5d5f576cdeb8fc4c7b297d0b0e5e18baf320cd576d14475b349aae908fb5262cc703806984c8199921167d8fcf23cae883333218bd91a1b7f03edca7e2dcaa37f463b337d20b5d59db610487c89da11b62397bc701762741bab9f87ff50592859be3cecb8c497c68a8c24d4244ef7febe8e5b4617589a82b5a702cfa93ea5c4ed8f33418f3d4e7115804f92283868a29678a5aa33b6fe5078c5fe8f8dc3bf364eb8ac8ce8a245e6b33138131c541013d0326324dfb695ffb3a1890c78092b4d42b28fef02b9c014ea5ac06d864c2f2e39403560d97dae38d9d643c25fbb230bbd92a4aa2b410d93c4efbc8d60b21fbac78255d62e72bb5b707120911b3b68b57da54f267dd138266d26d53961058fe8c1d7173e55bc7fdeb31234efe6e6480432aa50f4ec6f0093395d1805142cb6d1d
    print("R:")
    print(hex(R))
    
    # for blinding...!
    e = 0xd
    print("e:")
    print(hex(e))
    
    d = 0x7f35bc36ee3a1ae3f1be6c5c21f6029600d3f362779fd061dd464c6db33a20b30b76c0bc98c0ed42886af221bfbe5280644ae890f487745d149f0ae2c52c68f4d25b0ce016b863859c3eb51e8508094da9384599ab4740fe1c4038a324dda675f90e10b97063df6e6758550def1cd3f7ee23ce49bc9cf079aa7d00b5797de7778282998b92ccedaff37f20110626ebc0b060d93f913f6b6c6e4644dbeb55d19915e5118dbece7fe190d65e6d80b4553d57acc7a5dc79ae40ba91a239d8effbd1786a842ecdf6b155371b562d8a7d2605823158b8b804b449f7db65c6156e61eb0d1dac2a88d39a313a02e93e588d51ca8d243d4cc061d1adb787628f1fd7fb7769c5c22a8e74013472afa1910af8130830329c6ef04674886b3dd7f0de6b68d01e9aab82e29eb85a763a640f52bd42049baa1b92c3bac1c51d16879a0752b20f8fb356088b8d45ab3133da7d0fd94db891bde963b1f140ff87aa710c711666c3e6c5fb61d6bacbadacff72dcacfc63aef9fcf271b35e91169e0eefb63ce7105b4df3ca564dce6edf0cd8f67cdbb5892791375bc2bbc5f39dc500161269800483bc63c5d078725c7c7bb9e296bbad8fc13c5c69b020e8d6f5f610c96c43425579d22602bedaa769279125eb4209ae2c5c6e2bd5a9be69267322d17f27ea039e862c9a7154c0e67aa70950bdc0b546872d0b2aa4a40a176d5cb7fa6b9ab5f00255
    print("d:")
    print(hex(d))

    print("m:")
    m = 0x444d9850809f292387a1798fe6addd9e61d9fe398147a8f45f0ef320f7f60e7f75f2bc20a7f5195cde62d43f261908b9ccf719ab2922fbd8dca5b35354a1d50572d6bc20d80d6a1cc2472fd603e9ba024cea2df00a66dc4e21681081399f8a8f10fc9eee0a1727f7ea5f24b6de6fec4b843b2a7d15ab2c21ccc93ff710fce97d786e30efce9b2e70b4d4dfccb7d779cc4b5ca436953c178e61067a8cd7a3283c27e969e2c8bf23fb9a431f7a41c30359dfde228125fb5f3d866d7002091472ad52631db9d17034ce51797350e6256403bf3df0bbf66ac168b4a1ca795718ada2027c013f38018399ee6a8e2f9c19ed348af5890333b5b3cedfec4623ab899605a2939b3b7fa74d8aff88ec827f99d273d5627386528cc241e345ac72eac39204ade7cef37ed2ec2f856f3d95e0ae1a1b6c596216ae0fdbc8a36bcb0167e98363905c053b25fdacbe7ce71b48fba52e5998a33736fd1ac7ce1ad0a6f226bdd974d3b564b08be04c3e5c94938160c6b3ed755a3ac132ae2a201ac902ee25777cf09f9821883744da64cc249558f2ad985fff3e0ba10ac728b4a41865bf350d278d41a8a6e165e049937f411fed1e70e79933a1d1c2ad4ab155c09fcd8f739cd488869bdbd2e72bb5b707120911b3b68b57da54f267dd138266d26d53961058fe8c1d7173e55bc7fdeb31234efe6e6480432aa50f4ec6f0093395d1805142cb6d1d
    print(hex(m))

    print("c:")
    c = m ** e % n
    print(hex(c))
    
    RINV = mod_inverse(R, n)
    print("R^-1:")
    print(hex(RINV))
    out2memhfile(RINV, OUTPUTPATH + "RINV.txt")
    out2memhfile(RINV, OUTPUTSIMULATIONPATH + "RINV.txt")

    RE = modExpWordShift(R, e, n)
    print("R^e % n:")
    print(hex(RE))
    out2memhfile(RE, OUTPUTPATH + "RE.txt")
    out2memhfile(RE, OUTPUTSIMULATIONPATH + "RE.txt")
    
    cprime = monProWordShift(c, RE, n, WORDN, LEN)
    cprime = monProWordShift(cprime, t, n, WORDN, LEN)
    print("cprime:")
    print(hex(cprime))
    
    mprime = modExpWordShift(cprime, d, n)
    print("mprime:")
    print(hex(mprime))
    
    m = monProWordShift(mprime, RINV, n, WORDN, LEN)
    m = monProWordShift(m, t, n, WORDN, LEN)
    print("m:")
    print(hex(m))


#verifyModExp()
blinding()