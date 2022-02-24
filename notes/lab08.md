# lab 08

unrolled 展开的

这里指一个循环里对多个数据进行处理



## __m64 可以存放8个8位，4个16位，2个32位，1个64位数据

## __m128 可以存放4个32位浮点数

## __m128d 可以存放2个64位浮点数

## __m128i  可以存放16个8位，8个16位，4个32位，2个64位整数

## __m256 可以存放8个32位浮点数

## __m256d 可以存放4个64位的双精度浮点数

## __m256i 可以存放32个8位，16个16位，8个32位，4个64位整数

## __m512 可以存放16个32位浮点数

## __m512d 可以存放8个64位的双精度浮点数

## __m512i  可以存放64个8位，32个16位，16个32位，8个64位整数



# 格式 \_mm\_<intrin_op>_<suffix>

<intrin_op>
Indicates the basic operation of the intrinsic; for example, add for addition and sub for subtraction.

<suffix>
Denotes the type of data the instruction operates on. The first one or two letters of each suffix denote whether the data is packed (p), extended packed (ep), or scalar (s). The remaining letters and numbers denote the type, with notation as follows:
s single-precision floating point
d double-precision floating point
i128 signed 128-bit integer
i64 signed 64-bit integer
u64 unsigned 64-bit integer
i32 signed 32-bit integer
u32 unsigned 32-bit integer
i16 signed 16-bit integer
u16 unsigned 16-bit integer
i8 signed 8-bit integer
u8 unsigned 8-bit integer





# SSE

全称Streaming SIMD Extension，是x86上对SIMD指令集的一个扩展，主要用于处理单精度浮点数。Intel陆续推出SSE2、SSE3、SSE4版本。其中，SSE主要处理单精度浮点数，SSE2引入了整数的处理，

SSE指令集引入了8个128bit的寄存器，称为`XMM0`到`XMM7`。正因为这些寄存器存储了多个数据，使用一条指令处理，因此称这项功能为SIMD。



关于packed的解释，原意是完全的、满的，在这篇文章，Kittur解释了packed是指多个数据放到了一个向量里面，如4个单精度浮点数放到128bit寄存器，然后一条指令就操作这四个数。scaler类型的运算，一条指令只操作最低的某类型的数。extended packed则是用在SSE4引入的数据位数扩展的指令（看这里），可以将低位数的数据扩展到更高位数的数据，有有符号和无符号两种扩展方式。

变量后的数字，代表使用packed数据的第几个数据，如`r0`则使用`r`的最低位数据。

The packed values are represented in right-to-left order, with the lowest value being used for scalar operations.



---



## Exercise 2: Loop Unrolling Example

为了测试时间，将整个求数组和的循环再循环了2^14次



![image-20211217144913627](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217144913627.png)

__m128i _127 = _mm_set1_epi32(127)

__m128i - 128位整数，可以是有符号，也可以是无符号

ep满的 

i32有符号32位整数

_127 存放了  4个32位的127，每32位的低8位为1



![image-20211217144812776](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217144812776.png)



因为sum要加的元素为 vals[i] >= 128

因此需要将加载进tmp的4个数都和127进行比较

![image-20211217145948364](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217145948364.png)

如果大于的话该32位就全是1，可以作为掩码

![image-20211217150246983](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217150246983.png)

![image-20211217152528116](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217152528116.png)





## 什么是内存对齐

元素是按照定义顺序一个一个放到内存中去的，但并不是紧密排列的。从结构体存储的首地址开始，每个元素放置到内存中时，它都会认为内存是按照自己的大小（通常它为4或8）来划分的，因此元素放置的位置一定会在自己宽度的整数倍上开始，这就是所谓的内存对齐。

## 为什么要内存对齐

1. **平台原因(移植原因)**：不是所有的硬件平台都能访问任意地址上的任意数据的；某些硬件平台只能在某些地址处取某些特定类型的数据，否则抛出硬件异常。
2. **性能原因**：数据结构(尤其是栈)应该尽可能地在自然边界上对齐。原因在于，为了访问未对齐的内存，处理器需要作两次内存访问；而对齐的内存访问仅需要一次访问。

- 假如没有内存对齐机制，数据可以任意存放，现在一个int变量存放在从地址1开始的联系四个字节地址中，该处理器去取数据时，要先从0地址开始读取第一个4字节块,剔除不想要的字节（0地址）,然后从地址4开始读取下一个4字节块,同样剔除不要的数据（5，6，7地址）,最后留下的两块数据合并放入寄存器。这需要做很多工作。
- 现在有了内存对齐的，int类型数据只能存放在按照对齐规则的内存中，比如说0地址开始的内存。那么现在该处理器在取数据时一次性就能将数据读出来了，而且不需要做额外的操作，提高了效率。

