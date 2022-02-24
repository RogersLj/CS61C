
bl main

.data
source:
    .word   3
    .word   1
    .word   4
    .word   1
    .word   5
    .word   9
    .word   0
dest:
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0
    .word   0

.text
fun:
    addi t0, a0, 1		#x + 1	
    sub t1, x0, a0		#-x
    mul a0, t0, t1		#-x * (x + 1)
    jr ra

main:
    # BEGIN PROLOGUE
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw ra, 16(sp)		#保存寄存器和返回地址压入栈中
    # END PROLOGUE
    addi t0, x0, 0		#t0 = 0
    addi s0, x0, 0		#s0 = 0
    la s1, source		#s1 - source数组的起始地址 - 就像指针
    la s2, dest			#s2 - dest数组起始地址 - 就像指针
loop:
    slli s3, t0, 2		#s3 = t0 << 2，因为每个int是4个字节，地址每次偏移4
    add t1, s1, s3		#t1 = s1 + s3 - source数组的起始地址加上偏移量
    lw t2, 0(t1)		#t2 = source[s3]
    beq t2, x0, exit
    add a0, x0, t2		#a0 存放参数 source[s3]
    addi sp, sp, -8
    sw t0, 0(sp)
    sw t2, 4(sp)
    jal fun				#执行fun(source[k])
    lw t0, 0(sp)
    lw t2, 4(sp)
    addi sp, sp, 8
    add t2, x0, a0		#t2为fun返回值
    add t3, s2, s3		#dest相应偏移量
    sw t2, 0(t3)
    add s0, s0, t2		#sum += dest[k]
    addi t0, t0, 1		#k++
    jal x0, loop
exit:
    add a0, x0, s0
    # BEGIN EPILOGUE
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20
    # END EPILOGUE
    jr ra
