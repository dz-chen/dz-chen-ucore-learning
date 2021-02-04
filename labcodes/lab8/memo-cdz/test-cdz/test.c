#include<stdio.h>



int find_order(int size)
{
	int order = 0;
	for ( ; size > 4096 ; size >>=1)  // >>= 表示右移并赋值
		order++;
	return order;
}

int main(){
    int order=find_order(1);
    printf("find_order(1)==%d\n",order);

    order=find_order(999);
    printf("find_order(999)==%d\n",order);

    order=find_order(4090);
    printf("find_order(4090)==%d\n",order);

    order=find_order(4100);
    printf("find_order(4100)==%d\n",order);


    order=find_order(8195);
    printf("find_order(8195)==%d\n",order);

    order=find_order(100086);
    printf("find_order(100086)==%d\n",order);

    return 0;
}