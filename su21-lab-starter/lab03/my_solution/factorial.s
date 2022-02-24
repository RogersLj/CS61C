.globl factorial

.data
n: .word 8

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    add t1, x0, a0	#t1 - counts from n to 1
    addi t2, x0, 1  #t2 = result
    
loop:
	ble t1, x0, finish 		#(n <= 0)
    mul t2, t2, t1			# res = res * n
    addi t1, t1, -1			# n --
    jal x0, loop
    
finish:
	mv a0, t2	#将结果存到保存寄存器里
	jr ra
