#include "montgomery.h"

/* a[] -= mod */
static void subM(const PublicKey *key, uint32_t *a) {
    int64_t A = 0;
    int i;
    for (i = 0; i < key->len; ++i) {
        A += (uint64_t)a[i] - key->n[i];
        a[i] = (uint32_t)A;
        A >>= 32;
    }
}

/* return a[] >= mod */
static int geM(const PublicKey *key, const uint32_t *a) {
    int i;
    for (i = key->len; i;) {
        --i;
        if (a[i] < key->n[i]) return 0;
        if (a[i] > key->n[i]) return 1;
    }
    return 1;  /* equal */
}

void printnum(const PublicKey *key, const uint32_t *a, char *name){
    int i;
    printf("%s = 0x", name);
    for(i=0; i<key->len; i++){
        printf("%x", a[key->len-1-i]);
    }
    printf("\n");
}

/* montgomery c[] += a * b[] / R % mod */
static void montMulAdd(const PublicKey *key,
                       uint32_t* c,
                       const uint32_t a,
                       const uint32_t* b) {
    uint64_t A = (uint64_t)a * b[0] + c[0];
    uint32_t q0 = (uint32_t)A * key->n0inv;
    uint64_t B = (uint64_t)q0 * key->n[0] + (uint32_t)A;
    int i;

    for (i = 1; i < key->len; ++i) {
        A = (A >> 32) + (uint64_t)a * b[i] + c[i];
        B = (B >> 32) + (uint64_t)q0 * key->n[i] + (uint32_t)A;
        c[i - 1] = (uint32_t)B;
    }

    A = (A >> 32) + (B >> 32);

    c[i - 1] = (uint32_t)A;

    if (A >> 32) {
        subM(key, c);
    }
}

/* montgomery c[] = a[] * b[] / R % mod */
static void montMul(const PublicKey *key,
                    uint32_t* c,
                    const uint32_t* a,
                    const uint32_t* b) {
    int i;
    for (i = 0; i < key->len; ++i) {
        c[i] = 0;
    }
    for (i = 0; i < key->len; ++i) {
        montMulAdd(key, c, a[i], b);
        printnum(key, c, "c");
    }
}

/* In-place public exponentiation.
** Input and output big-endian byte array in inout.
*/
void modpow3(const PublicKey *key,
                    uint8_t* inout) {
    uint32_t a[NUMWORDS];
    uint32_t aR[NUMWORDS];
    uint32_t aaR[NUMWORDS];
    uint32_t *aaa = aR;  /* Re-use location. */
    int i;

    /* Convert from big endian byte array to little endian word array. */
    for (i = 0; i < key->len; ++i) {
        uint32_t tmp =
            (inout[((key->len - 1 - i) * 4) + 0] << 24) |
            (inout[((key->len - 1 - i) * 4) + 1] << 16) |
            (inout[((key->len - 1 - i) * 4) + 2] << 8) |
            (inout[((key->len - 1 - i) * 4) + 3] << 0);
        a[i] = tmp;
    }

    montMul(key, aR, a, key->rr);  /* aR = a * RR / R mod M   */
    montMul(key, aaR, aR, aR);     /* aaR = aR * aR / R mod M */
    montMul(key, aaa, aaR, a);     /* aaa = aaR * a / R mod M */

    /* Make sure aaa < mod; aaa is at most 1x mod too large. */
    if (geM(key, aaa)) {
        subM(key, aaa);
    }

    /* Convert to bigendian byte array */
    for (i = key->len - 1; i >= 0; --i) {
        uint32_t tmp = aaa[i];
        *inout++ = tmp >> 24;
        *inout++ = tmp >> 16;
        *inout++ = tmp >> 8;
        *inout++ = tmp >> 0;
    }
}


int main()
{
    int i;
    uint32_t a[6];
    uint32_t b[6];
    uint32_t c[6];

    PublicKey key;
    key.len = 6;   //192 bit = 6 uint32_t
    
    //N = 0x4278854c26dc920c49de94b5efd7f315fec6a4d6b8ef6e53
    key.n[0] = 0xb8ef6e53;
    key.n[1] = 0xfec6a4d6;
    key.n[2] = 0xefd7f315;
    key.n[3] = 0x49de94b5;
    key.n[4] = 0x26dc920c;
    key.n[5] = 0x4278854c;

    key.rr[0] = 0xac31b1fe;
    key.rr[1] = 0xe1532a2e;
    key.rr[2] = 0xf1095b07;
    key.rr[3] = 0x44b4993c;
    key.rr[4] = 0xa4ce9dc;
    key.rr[5] = 0x2d55ba3b;

    key.n0inv = 0x38b8fa25;

    //A = 0xf884f8e5166842e299137934104962bf7c5b0acd2db8e853
    a[0] = 0x2db8e853;
    a[1] = 0x7c5b0acd;
    a[2] = 0x104962bf;
    a[3] = 0x99137934;
    a[4] = 0x166842e2;
    a[5] = 0xf884f8e5;
    //B = 0x2761113009d5c5186581d33879e957fb96960ae12993d77f
    b[0] = 0x2993d77f;
    b[1] = 0x96960ae1;
    b[2] = 0x79e957fb;
    b[3] = 0x6581d338;
    b[4] = 0x9d5c518;
    b[5] = 0x27611130;

    montMul(&key, c, a, b);  /* aR = a * b / R mod N */

    /* Make sure aaa < mod; aaa is at most 1x mod too large. */
    if (geM(&key, c)) {
        subM(&key, c);
    }

    printnum(&key, a, "a");
    printnum(&key, b, "b");
    printnum(&key, key.n, "n");
    printf("\n");

    printf("r = 2^%d", key.len*32);
    printf("\n");
    printf("\n");
    printf("c = a * b / r mod n\n");
    printnum(&key, c, "c");
}
