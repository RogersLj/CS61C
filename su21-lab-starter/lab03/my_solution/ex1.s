.data		#声明全局变量
.word 2, 4, 6, 8	#按字放入数据段中
n: .word 9		##声明变量n=9

.text
main:
    add t0, x0, x0	#清零寄存器t0(x5)	- t0 = 0
    addi t1, x0, 1	#t1(x6)寄存器置为1	- t1 = 1 
    la t3, n		#将n的地址放到寄存器t3(x28)里
    # 地址是32位，所以la是由两句指令组成
    # 先加载高20位，再低12位
    lw t3, 0(t3)	#将存储器取字到寄存器，也就是将n存到t3里
fib:
    beq t3, x0, finish #if (n = 0) finish
    add t2, t1, t0		#t2 = 1
    mv t0, t1			#t0 = 1
    mv t1, t2			# t1 =1 
    addi t3, t3, -1		# n -= 1	- t3 = 8
    j fib
finish:
    addi a0, x0, 1		# a0 = 1
    addi a1, t0, 0		# a1 = f(9)
    ecall # print integer ecall
    addi a0, x0, 10
    ecall # terminate ecall
