//在数论，对正整数n，欧拉函数是小于或等于n的正整数中与n互质的数的数目（因此φ(1)=1）
#include<stdio.h>
#include<stdlib.h>
int eular(int n)
{
    int ret=1,i;
    for(i=2;i*i<=n;i++)
    {
        if(n%i==0)
        {
            n/=i,ret*=i-1;
            while(n%i==0) n/=i,ret*=i;
        }
    }
    if(n>1) ret*=n-1;
    return ret;
}
int main ()
{
      int n,s;
      scanf("%d",&n);
      s=eular(n);
      printf("%d",s);
      return 0;
}
