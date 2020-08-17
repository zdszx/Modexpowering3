#include <stdio.h>
/*
Name:  
Copyright: 
Author: @dujianjian
Date: 01/11/12 11:26
Description: 递归 
*/

//三元组gcd(a,b) == ax +by == d; 
struct gcdstruct{  
    int d;
    int x;
    int y;
};

gcdstruct EXTENDED_EUCLID(int a,int b)
{
    gcdstruct aa,bb;
    if(b==0){
        aa.d = a;
        aa.x = 1;
        aa.y = 0;
        return aa;
    }
    else{
        bb = EXTENDED_EUCLID(b,a%b); 
        aa.d = bb.d;
        aa.x = bb.y;
        aa.y = bb.x - bb.y * (a/b);
    }
    return aa;
} 

/*
Name: 
Copyright: 
Author: @dujianjian
Date: 01/11/12 20:33
Description: 
ax == 1 (mod m),求x 
*/


long inverse(long a,long m)
{
    long x;
    gcdstruct aa;
    aa = EXTENDED_EUCLID(a,m);
    return aa.x;

}   

int main(){
    int a,m;
    a = 3;
    m = 11;
    printf("a = %d,m = %d,x = %d\n",a,m,inverse(a,m));
    return 0;
}  

