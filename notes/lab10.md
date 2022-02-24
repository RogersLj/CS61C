# lab10

### fa21的lab08 https://cs61c.org/fa21/labs/lab08/



## Exercise 1: Working with CAMERA

### Checkpoint：

虚拟地址页号有3位 - 一共有8页

offset有5位 - 一页有可以存放32个地址



物理地址里的页叫页帧

物理地址页号有2位 - 一共有4页帧

offset和虚拟地址一样 - 一页可以有32个地址



所以虚拟地址位数是大于物理地址的位数的

给处理器一个内存无限大的假象



1. 页有多大？

可以存放32个字的内容



2. 没有page hits

因为如果页表里有虚拟地址到物理地址的映射，那么会被存在TLB中，而每次查看的时候都会先查看TLB，如果TLB没有就会查看页表

所以如果发生page hits，意味着我们需要找的映射在页表中而不在TLB里， 

但是我们的物理地址刚好只有4页，我们的TLB页刚好可以存放4个映射

因此我们需要查找的映射只会出现两种情况，一种是刚好有虚拟页到物理页的映射，而这一定会被放在TLB里，因此不会发生page hits，因为TLB hits之后根本不需要查看页表

如果我们虚拟页到物理页的映射不在TLB里，TLB相当于页表的cache，内容是同步的。那么不论物理页是满的还是有空页，我们都需要将我们虚拟页映射到一个物理页，（可能是选一个未用的页或者是换出），而此时需要重新写入page table和TLB。



要发生page hits，需要让物理页帧数量大于TLB里存放的页映射的数量，这样就会有在页表中存在映射，但是没有放入TLB中的情况，这个时候当查看TLB的时候会miss，然后查看page table会hits，然后将最新的映射换到TLB里。





3. 整个过程

1. We update the page table to map the corresponding VPN to the PPN. - 更新页表里虚拟页号到物理页号的映射
2. Calculate number of virtual page number (VPN) bits through the VA bits and offset bits. - 通过虚拟地址里的总位数和偏移量位数计算页号的位数
3. TLB does not contain the VPN so we access the page table for the corresponding VPN. - TLB miss然后去页表里查看是否有映射
4. We access the corresponding word using the offset. - 用偏移量找到最终地址
5. We bring the corresponding virtual page into physical memory from disk. - 将虚拟地址的内容加载到物理内存
6. The page table's entry for VPN has a valid bit of 0. - 查看页表时发现该页还没有分配映射
7. Get VPN by taking `VA[address bits - 1 : offset bits]`. - 取得虚拟地址里页号
8. Calculate number of offset bits by taking log 2 of page size. - 通过页大小计算偏移量位数
9. We update the TLB with the corresponding PT entry. - 通过页表的映射更新到TLB里
10. Get offset by taking `VA[offset bits - 1 ; 0]`. - 拿到偏移量
11. Access TLB for corresponding VPN. - 查找TLB
12. Access given virtual address. - 取得虚拟地址 



12 -> 8 -> 2 -> 7 -> 10 -> 11 -> 3 -> 6 -> 5 -> 4 -> 9 -> 1 



首先取得的虚拟地址，然后通过计算页表大小得到偏移量位数，用虚拟地址位数减去偏移量位数，得到了页码的位数。接下来通过页码位数算出具体的页号，然后去TLB里找是否有相应页号的映射，但是发现没有。接下来再去页表里查找，但是发现页表里的合法位为0，因此需要重新分配。于是将磁盘里地址加载到物理内存，通过计算的偏移量找到最终地址。然后更新TLB的映射，然后更新页表的映射。



4. PPN 物理页位数为2
5. VPN 虚拟页位数为3
6. PPN 物理页数为4
7. VPN 虚拟页数为8



---

## Exercise 2: Misses

1F

3F

5F

7F

9F

BF

DF

FF

10

30





---

## Exercise 4: Bringing it All Together

P1, P2, P3, and P4 为四个不同的进程，有各自的Page table但是有共同的TLB



导致很低的TLB hit率的原因：

多个进程一起运行，多个进程之间切换的时候，需要系统进行上下文的切换，每次切换会重置TLB，因为不同进程虚拟地址到物理地址的映射是不同的。



