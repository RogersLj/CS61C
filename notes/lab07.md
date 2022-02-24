```assembly
# Rewriten by Stephan Kaminsky in RISC-V on 7/30/2018
# This program accesses an array in ways that provide data about the cache parameters.
# Coupled with the Data Cache Simulator and Memory Reference Visualization to help students
#    understand how the cache parameters affect cache performance.
#
# PSEUDOCODE:
#    int array[];                           //Assume sizeof(int) == 4
#    for (k = 0; k < repcount; k++) {		重复次数    // repeat repcount times
#      /* Step through the selected array segment with the given step size. */
#      for (index = 0; index < arraysize; index += stepsize) {
#        if(option==0)
#          array[index] = 0;	只写	          // Option 0: One cache access - write
#        else
#          array[index] = array[index] + 1;	读写// Option 1: Two cache accesses - read AND write
#      }
#    }

.data
array:	.word	2048	                     # max array size specified in BYTES (DO NOT CHANGE)2048字节	数组每一个元素int大小4个字节 - 512个int元素 

.text
##################################################################################################
# You MAY change the code below this section
main:	li	a0, 256		# array size in BYTES (power of 2 < array size) - 256字节 大小为64
	li	a1, 2		# step size  (power of 2 > 0) 
	li	a2, 1		# rep count  (int > 0)
	li	a3, 1		# 0 - option 0, 1 - option 1
# You MAY change the code above this section
##################################################################################################

	jal	accessWords	# lw/sw

	li	a0,10		                              # exit
	ecall

# SUMMARY OF REGISTER USE:
#  a0 = array size in bytes
#  a1 = step size
#  a2 = number of times to repeat
#  a3 = 0 (W) / 1 (RW)
#  s0 = moving array ptr
#  s1 = array limit (ptr)

accessWords:
	la	s0, array		                          # ptr to array - s0存遍历到array的地址
	add	s1, s0, a0		                        # hardcode array limit (ptr) s1 - array最大元素的地址，不可以超过（>=）此地址
	slli	t1, a1, 2		                        # multiply stepsize by 4 because WORDS 乘4 变为字节 t1为每次指针的增加量，指向下一个地址
wordLoop:
	beq	a3, zero,  wordZero   #写0 或 读写1

	lw	t0, 0(s0)    #读写		                          # array[index/4]++
	addi	t0, t0, 1
	sw	t0, 0(s0)
	j	wordCheck

wordZero:     # 写
	sw	zero,  0(s0)		                      # array[index/4] = 0

wordCheck:
	add	s0, s0, t1		                        # increment ptr
	blt	s0, s1, wordLoop	                    # inner loop done? 还没到数组最后

	addi	a2, a2, -1		#每层循环结束，到数组末尾，循环次数减一
	bgtz	a2, accessWords	                    # outer loop done?
	jr	ra   


accessBytes:
	la	s0, array		                          # ptr to array
	add	s1, s0, a0		                        # hardcode array limit (ptr)
byteLoop:
	beq	a3, zero,  byteZero

	lbu	t0, 0(s0)		                          # array[index]++
	addi	t0, t0, 1
	sb	t0, 0(s0)
	j	byteCheck

byteZero:
	sb	zero,  0(s0)		                      # array[index] = 0

byteCheck:
	add	s0, s0, a1		                        # increment ptr
	blt	s0, s1, byteLoop	                    # inner loop done?

	addi	a2, a2, -1
	bgtz	a2, accessBytes	                    # outer loop done?
	jr	ra

```



最开始的这个程序，a3 = 1， 会发生读写操作，写操作发生在读之后，当第一次读操作时会发生cache miss，然后进行写操作，然后就会cache hit。数组大小为64，步幅大小为2，因此一共对32个地址发生了读写操作。因为block size = 4， 且只有1个block，所以cache就刚好每次只能存下一个int，所以每读写一次都会发生cache miss，读写。

因此hit count = 32， 每次读写都会访问2次cache，读一次写一次，所以一共access 64

hit rate = 0.5

![image-20211211094804085](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211094804085.png)





---

### Scenario 1

![image-20211210211205567](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211210211205567.png)



32个元素

一次循环会访问4个元素 0 8 16 24 

循环4次，而且每次只需要读操作 - 所以cache access = 16

只会发生读操作



但是block size=8， 有4个block，因此整个cache size=32 bytes， 能放下8个int数据

但是每次步幅刚好是8，因此每次访问都会重新更新cache

![image-20211211101758811](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211101758811.png)



虽然处理器发起cache访问，访问失效hit miss之后，会从内存里读取，并更新cache block的数据，但是这其实算还是算一次cache访问。而写操作首先是需要读cache里的数据，这里同样可能会发生hit miss，然后再对数据进行运算后，这里就可能会有write through和write back两种写操作，因此还会再次访问cache。

反正记住读操作访问一次，读写操作访问两次





#### Tasks

1. hit rate = 0，因为step size = cache size
2. 增加Rep Count，hit rate还是为0，因为和上面分析的和结果一样
3. 我们可以将step size改为1，其他参数不变的情况下

每次循环会访问64个元素，每次发生hit miss的时候，会存入2个int，因此相邻两个元素的访问，第一个会发生hit miss，但是第二个会hit

因此access变为32*4=128

hit count = 64

hit rate = 0.5

最后结果和计算的一样



![image-20211211105017623](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211105017623.png)

---

### Scenario 2

![image-20211211105115056](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211105115056.png)

数组大小64个元素

步幅为2

一次循环 - 一共访问32个元素

读写操作 - access 64 次



block size - 4个int

因此每次会加载相邻的四个int元素，步幅为2，所以第一次读元素hit miss之后，会将4个元素同时写入cache，写操作时会cache hit，会发现，下一个需要访问的数据以及存在cache中，因此读写两次操作都会cache hit。

所以每一个cache block的hit rate = 0.75

因为循环一次，需要加载所有元素，因此总的hit rate = 0.75



![image-20211211111119910](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211111119910.png)

#### Tasks

1. memory access会发生，一是cache miss的时候会从内存读取数据，而是写操作时，因为是write through。所以对一个block，一次cache miss，两次write through，会发生3次。我们需要载入16个block，因此会访问48次。
2. **repeating hit/miss pattern** - m h h h m h h h 
3. 第一次循环，对于一个block会发生1次miss和3次hit，第一次循环之后，所有需要访问的元素都保存到了cache中，因此之后的循环会全部hit，随着循环次数的增加，hit rate会趋于1； 3/4 -> (3+4) /(4+4) 
4. we should try to access **256 bytes** of the array at a time and apply all of the **function** to that **certain amount of array** so we can be completely done with it before moving on,thereby keeping that **certain data of array** hot in the cache and not having to circle back to it later on!



---

### Scenario 3

![image-20211211113248028](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211113248028.png)

32个元素 - 步幅1 - 遍历所有元素

所以不会重复访问，第一次访问都需要加载内存到cache里

一个block可以同时加载两个元素，所以每个block，hit rate = 0.5， 总的hit rate也=0.5



### L1 一个block2个元素 可保存16个元素

![image-20211211113333260](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211113333260.png)



### L2 - 一个block2个元素 可保存32个元素

![image-20211211113409744](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211113409744.png)



#### Tasks

1. The hit rate of L1 is 50%. The hit rate of L2 is 0%. Overall the hit rate is 50%.
2. 32 access total. 16 of them miss.
3. 16 access total. Every time L1 miss, we access L2.

4. increase the block size of L2 （L1和L2 block size相同，相当于每次L1 miss之后去找L2， L2没有，会找内存，因为block size都一样，所以L1会有L2的copy，当L1 miss的时候，L1没有的再L2也没有，如果要增加L2的hit rate，可以增加L2的block size，让miss之后，L2比L1保存更多的数据）
5.  increase the number of blocks in L1 -  L1 and L2 hit rates stay the same (=), 

As we slowly increase the number of blocks in L1, the hit rates for L1 and L2 remain the same. As for L1 block size, the hit rate for L1 increase but for L2 remain the same.



## Exercise 2

![image-20211211115540556](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211115540556.png)

![image-20211211121202463](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211121202463.png)

1. jki perform the best. Because the average step size of C, A, B is smallest, which make full use of spatial locality and leads to highest hit rate.
2. ikj and kij perform the worst. Because the average step size of C, A, B is largest.
3. We should stride as small size as we can.



```assembly
void multMat1( int n, float *A, float *B, float *C ) {
    int i,j,k;
    /* This is ijk loop order. */
    for( i = 0; i < n; i++ )
        for( j = 0; j < n; j++ )
            for( k = 0; k < n; k++ )
                C[i+j*n] += A[i+k*n]*B[k+j*n];
}
moves through B with stride 1
moves through A with stride n
moves through C with stride 0


void multMat2( int n, float *A, float *B, float *C ) {
    int i,j,k;
    /* This is ikj loop order. */
    for( i = 0; i < n; i++ )
        for( k = 0; k < n; k++ )
            for( j = 0; j < n; j++ )
                C[i+j*n] += A[i+k*n]*B[k+j*n];
}
moves through B with stride n
moves through A with stride 0
moves through C with stride n


void multMat3( int n, float *A, float *B, float *C ) {
    int i,j,k;
    /* This is jik loop order. */
    for( j = 0; j < n; j++ )
        for( i = 0; i < n; i++ )
            for( k = 0; k < n; k++ )
                C[i+j*n] += A[i+k*n]*B[k+j*n];
}
moves through B with stride 1
moves through A with stride n
moves through C with stride 0


void multMat4( int n, float *A, float *B, float *C ) {
    int i,j,k;
    /* This is jki loop order. */
    for( j = 0; j < n; j++ )
        for( k = 0; k < n; k++ )
            for( i = 0; i < n; i++ )
                C[i+j*n] += A[i+k*n]*B[k+j*n];
}
moves through B with stride 0
moves through A with stride 1
moves through C with stride 1


void multMat5( int n, float *A, float *B, float *C ) {
    int i,j,k;
    /* This is kij loop order. */
    for( k = 0; k < n; k++ )
        for( i = 0; i < n; i++ )
            for( j = 0; j < n; j++ )
                C[i+j*n] += A[i+k*n]*B[k+j*n];
}
moves through B with stride n
moves through A with stride 0
moves through C with stride n


void multMat6( int n, float *A, float *B, float *C ) {
    int i,j,k;
    /* This is kji loop order. */
    for( k = 0; k < n; k++ )
        for( j = 0; j < n; j++ )
            for( i = 0; i < n; i++ )
                C[i+j*n] += A[i+k*n]*B[k+j*n];
}
moves through B with stride 0
moves through A with stride 1
moves through C with stride 1
```



每一层对每个矩形每个元素访问的平均步数最小，速度就会越快，因为cache hit miss后会以block size大小保存相邻元素的值，如果步幅越小，hit的概率就越大，代码运行速度就越快。



对于三层循环，当最外两层变量确定后，最里层会循环n次，所以我们需要首先考虑最里层的步幅，明显当i为最里层时，ABC的步幅更新最小为1 1 0

然后考虑第二层，循环k的



观察数组里ijk的系数，就是每次更新的步幅

|      | A    | B    | C    |
| ---- | ---- | ---- | ---- |
| i    | 1    | 0    | 1    |
| j    | 0    | n    | n    |
| k    | n    | 1    | 0    |

循环的次序是从里到外，所以我们需要保证步幅的变化从里到外从小到大

对i的循环，平均步幅最小；其次是k然后是j



因此我们可以大致估算排名，从快到慢为：

j k i

k j i

j i k

i j k

k i j

i k j

![image-20211211123048128](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211123048128.png)



## Exercise 3

当矩阵大小比较小的时候，可以将数组中的元素放入cache中，因此与分block的时候大小区别不大，但是当矩阵的大小到达一定的时候，cache不能存下矩阵的所有值，所以会发生cache miss，进而运行时间会增加，这是选择分块的方式可以有效提高运行速率。

![image-20211211143338330](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211143338330.png)



![image-20211211143548349](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211211143548349.png)

速度会先增加然后减慢，block里的数据不能够全部存入cache中了，因此并不会带来明显的提升，所以当block的大小到达一定的时候，随着block大小的增加变得更慢了

