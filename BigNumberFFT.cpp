//实际就是信号系统中时域卷积频域相乘的方法，信号的卷积与多项式（两数字）的相乘是一个意思 
#include<iostream>
#include<cstdio>
#include<cmath>
#include<cstring>> 
#define Pi acos(-1.0)//定义Pi的值
#define N 200000
using namespace std;
struct complex //定义复数结构体
{
  double re,im;
  complex(double r=0.0,double i=0.0)
  {  re=r,im=i; }  //初始化
   //定义三种运算 
  complex operator +(complex o)
  { return complex(re+o.re,im+o.im);}
  complex operator -(complex o)
  { return complex(re-o.re,im-o.im);}
  complex operator *(complex o)
  { return complex(re*o.re-im*o.im,re*o.im+im*o.re);}
}x1[N],x2[N];
char a[N/2],b[N/2];
int sum[N];    //存储最后的结果

void BRC(complex *y,int len)//二进制反转倒置
{
  int i,j,k;
  for(i=1,j=len/2;i<len-1;i++)
  {
     if(i<j)swap(y[i],y[j]);//i<j保证只交换一次
     k=len/2;
     while(j>=k)
     {
       j-=k;k=k/2;
     }
   if(j<k)j+=k;
  }
}
void FFT(complex *y,int len ,double on)//on=1表示顺，-1表示逆
{
  int i,j,k,h;
  complex u,t;
  BRC(y,len);
  for(h=2;h<=len;h<<=1)//控制层数
  {
      //初始化单位复根
    complex wn(cos(on*2*Pi/h),sin(on*2*Pi/h));
    for(j=0;j<len;j+=h)//控制起始下标
    {
      //初始化螺旋因子
        complex w(1,0);
        for(k=j;k<j+h/2;k++)
        {
            u=y[k];
            t=w*y[k+h/2];
            y[k]=u+t;
            y[k+h/2]=u-t;
            w=w*wn;//更新螺旋因子
        }    
    }
  }
if(on==-1)
   for(i=0;i<len;i++) //逆FFT(IDFT)
       y[i].re/=len;

}
int main()
{
    int len1,len2,len,i;
  while(scanf("%s%s",a,b)!=EOF)
  { 
     len1=strlen(a);
     len2=strlen(b);
     len=1;
//扩充次数界至2*n
     while(len<2*len1||len<2*len2)len<<=1;//右移相当于len=len*2
//倒置存储
     for(i=0;i<len1;i++)
     { x1[i].re=a[len1-1-i]-'0';x1[i].im=0.0;}
     for(;i<len1;i++)  //多余次数界初始化为0
     {x1[i].re=x1[i].im=0.0;}
     for(i=0;i<len2;i++)
     { x2[i].re=b[len2-1-i]-'0';x2[i].im=0.0;}
     for(;i<len2;i++)  //多余次数界初始化为0
     {x2[i].re=x2[i].im=0.0;}
//FFT求值
     FFT(x1,len,1);//FFT(a) 1表示顺 -1表示逆
     FFT(x2,len,1);//FFT(b)
//点乘，结果存入x1
     for(i=0;i<len;i++)
         x1[i]=x1[i]*x2[i];
//插值，逆FFT（IDTF）
     FFT(x1,len,-1);

//细节处理
     for(i=0;i<len;i++)
         sum[i]=x1[i].re+0.5;//四舍五入
     for(i=0;i<len;i++)     //进位
     {
       sum[i+1]+=sum[i]/10;
       sum[i]%=10;
     }
//输出
     len=len1+len2-1;
     while(sum[len]<=0&&len>0)len--;//检索最高位
     for(i=len;i>=0;i--)   //倒序输出
      cout<<sum[i];
      cout<<endl;
  }
return 0;
}
