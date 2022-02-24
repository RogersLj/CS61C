# lab04

## exercise1

```assembly
.globl f

.data
neg3:   .asciiz "f(-3) should be 6, and it is: "
neg2:   .asciiz "f(-2) should be 61, and it is: "
neg1:   .asciiz "f(-1) should be 17, and it is: "
zero:   .asciiz "f(0) should be -38, and it is: "
pos1:   .asciiz "f(1) should be 19, and it is: "
pos2:   .asciiz "f(2) should be 42, and it is: "
pos3:   .asciiz "f(3) should be 5, and it is: "

output: .word   6, 61, 17, -38, 19, 42, 5
.text
main:
    la a0, neg3
    jal print_str
    li a0, -3
    la a1, output
    jal f               # evaluate f(-3); should be 6
    jal print_int
    jal print_newline

    la a0, neg2
    jal print_str
    li a0, -2
    la a1, output
    jal f               # evaluate f(-2); should be 61
    jal print_int
    jal print_newline

    la a0, neg1
    jal print_str
    li a0, -1
    la a1, output
    jal f               # evaluate f(-1); should be 17
    jal print_int
    jal print_newline

    la a0, zero
    jal print_str
    li a0, 0
    la a1, output
    jal f               # evaluate f(0); should be -38
    jal print_int
    jal print_newline

    la a0, pos1
    jal print_str
    li a0, 1
    la a1, output
    jal f               # evaluate f(1); should be 19
    jal print_int
    jal print_newline

    la a0, pos2
    jal print_str
    li a0, 2
    la a1, output
    jal f               # evaluate f(2); should be 42
    jal print_int
    jal print_newline

    la a0, pos3
    jal print_str
    li a0, 3
    la a1, output
    jal f               # evaluate f(3); should be 5
    jal print_int
    jal print_newline

    li a0, 10
    ecall

# f takes in two arguments:
# a0 is the value we want to evaluate f at
# a1 is the address of the "output" array (defined above).
# Think: why might having a1 be useful?
f:
    # YOUR CODE GOES HERE!
	addi a0, a0, 3   //将底数变成0 ~ 6
    slli a0, a0, 2	 //一个字4个字节，偏移量为4，向左移2位
    add a1, a1, a0	//加上偏移量表示最终的地址
    lw a0, 0(a1)	//加载地址的数据
    jr ra               # Always remember to jr ra after your function!

print_int:
    mv a1, a0
    li a0, 1
    ecall
    jr    ra

print_str:
    mv a1, a0
    li a0, 4
    ecall
    jr    ra

print_newline:
    li a1, '\n'
    li a0, 11
    ecall
    jr    ra

```





### 什么时候函数需要保存返回地址？

为什么有的函数需要保存返回地址？



有的段只是函数里面的片段，而不是函数，所以不需要返回地址。

因为ra存的地址是函数返回之后，下一条指令执行的地址，所以当调用函数的时候，ra就会改写。

而如果调用的函数会再调用其他函数，ra会再次被重写。因此，如果函数需要调用其他函数，就必须保存下来返回地址。



```assembly
.globl simple_fn naive_pow inc_arr

.data
failure_message: .asciiz "Test failed for some reason.\n"
success_message: .asciiz "Sanity checks passed! Make sure there are no CC violations.\n"
array:
    .word 1 2 3 4 5
exp_inc_array_result:
    .word 2 3 4 5 6

.text
main:
    # We test our program by loading a bunch of random values
    # into a few saved registers - if any of these are modified
    # after these functions return, then we know calling
    # convention was broken by one of these functions
    li s0, 2623
    li s1, 2910
    # ... skipping middle registers so the file isn't too long
    # If we wanted to be rigorous, we would add checks for
    # s2-s20 as well
    li s11, 134
    # Now, we call some functions
    # simple_fn: should return 1
    jal simple_fn # Shorthand for "jal ra, simple_fn"
    li t0, 1
    bne a0, t0, failure
    # naive_pow: should return 2 ** 7 = 128
    li a0, 2
    li a1, 7
    jal naive_pow
    li t0, 128
    bne a0, t0, failure
    # inc_arr: increments "array" in place
    la a0, array
    li a1, 5
    jal inc_arr
    jal check_arr # Verifies inc_arr and jumps to "failure" on failure
    # Check the values in the saved registers for sanity
    li t0, 2623
    li t1, 2910
    li t2, 134
    bne s0, t0, failure
    bne s1, t1, failure
    bne s11, t2, failure
    # If none of those branches were hit, print a message and exit normally
    li a0, 4
    la a1, success_message
    ecall
    li a0, 10
    ecall

# Just a simple function. Returns 1.
#
# FIXME Fix the reported error in this function (you can delete lines
# if necessary, as long as the function still returns 1 in a0).
simple_fn:
    # mv a0, t0 - delete this line
    li a0, 1
    ret

# Computes a0 to the power of a1.
# This is analogous to the following C pseudocode:
#
# uint32_t naive_pow(uint32_t a0, uint32_t a1) {
#     uint32_t s0 = 1;
#     while (a1 != 0) {
#         s0 *= a0;
#         a1 -= 1;
#     }
#     return s0;
# }
#
# FIXME There's a CC error with this function!
# The big all-caps comments should give you a hint about what's
# missing. Another hint: what does the "s" in "s0" stand for? - register that has to be saved
naive_pow:
    # BEGIN PROLOGUE
    addi sp, sp, -4
    sw s0, 0(sp)
    # END PROLOGUE
    li s0, 1
naive_pow_loop:
    beq a1, zero, naive_pow_end
    mul s0, s0, a0
    addi a1, a1, -1
    j naive_pow_loop
naive_pow_end:
    mv a0, s0
    # BEGIN EPILOGUE
    lw s0, 0(sp)
    addi sp, sp, 4
    # END EPILOGUE
    ret

# Increments the elements of an array in-place.
# a0 holds the address of the start of the array, and a1 holds
# the number of elements it contains.
#
# This function calls the "helper_fn" function, which takes in an
# address as argument and increments the 32-bit value stored there.
inc_arr:
    # BEGIN PROLOGUE
    #
    # FIXME What other registers need to be saved?
    #
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    # END PROLOGUE
    mv s0, a0 # Copy start of array to saved register
    mv s1, a1 # Copy length of array to saved register
    li t0, 0 # Initialize counter to 0
inc_arr_loop:
    beq t0, s1, inc_arr_end
    slli t1, t0, 2 # Convert array index to byte offset
    add a0, s0, t1 # Add offset to start of array
    # Prepare to call helper_fn
    #
    # FIXME Add code to preserve the value in t0 before we call helper_fn
    # Hint: What does the "t" in "t0" stand for? - temporary
    # Also ask yourself this: why don't we need to preserve t1? - t1只是存储了一个临时的偏移量，我们需要的地址已经存入到a0里，所以不再需要t0了
    #
    addi sp, sp, -4
    sw t0, 0(sp)
    jal helper_fn
    # Finished call for helper_fn
    lw t0, 0(sp)
    addi sp, sp, 4
    addi t0, t0, 1 # Increment counter
    j inc_arr_loop
inc_arr_end:
    # BEGIN EPILOGUE
    lw ra, 0(sp)
   	lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    # END EPILOGUE
    ret

# This helper function adds 1 to the value at the memory address in a0.
# It doesn't return anything.
# C pseudocode for what it does: "*a0 = *a0 + 1"
#
# FIXME This function also violates calling convention, but it might not
# be reported by the Venus CC checker (try and figure out why).
# You should fix the bug anyway by filling in the prologue and epilogue
# as appropriate.
helper_fn:
    # BEGIN PROLOGUE
    addi sp, sp, -4
    sw s0, 0(sp)
    # END PROLOGUE
    lw t1, 0(a0)
    addi s0, t1, 1
    sw s0, 0(a0)
    # BEGIN EPILOGUE
    lw s0, 0(sp)
    addi sp, sp, 4
    # END EPILOGUE
    ret

# YOU CAN IGNORE EVERYTHING BELOW THIS COMMENT

# Checks the result of inc_arr, which should contain 2 3 4 5 6 after
# one call.
# You can safely ignore this function; it has no errors.
check_arr:
    la t0, exp_inc_array_result
    la t1, array
    addi t2, t1, 20 # Last element is 5*4 bytes off
check_arr_loop:
    beq t1, t2, check_arr_end
    lw t3, 0(t0)
    lw t4, 0(t1)
    bne t3, t4, failure
    addi t0, t0, 4
    addi t1, t1, 4
    j check_arr_loop
check_arr_end:
    ret
    

# This isn't really a function - it just prints a message, then
# terminates the program on failure. Think of it like an exception.
failure:
    li a0, 4 # String print ecall
    la a1, failure_message
    ecall
    li a0, 10 # Exit ecall
    ecall
    
```

CC checker 只会检查在`.globl`里的函数





## exercise 3

a0  - 头结点地址

s0 - 头结点地址

s1 - 函数地址

t0 - 计数器



每个结点12个字节



```
add t0, s0, x0  把s0的内容加载到t0 
and
lw t0, 0(s0)    把s0地址的内容加载到t0
```





## exercise 4

### accumulatorone

```assembly
accumulatorone:
	addi sp sp -8
	sw s0 0(sp)
	sw ra 4(sp)
	
    lw s0 0(a0)
    bne s0 x0 L1
	
    lw s0 0(sp)
    lw ra 4(sp)
    addi sp sp 8
    li a0 0
    jr ra
    
L1:
	addi a0 a0 4
    jal accumulatorone
    
    add a0 a0 s0
    lw s0 0(sp)
    lw ra 4(sp)
    addi sp sp 8
   
    jr ra
```



```assembly
accumulatorone:
	addi sp sp -8
	sw s0 0(sp)
	sw ra 4(sp)
    
	lw s0 0(a0)
	beq s0 x0 Endone
    
	addi a0 a0 4
	jal accumulatorone
    
    add a0 a0 s0
    lw s0 0(sp)
    lw ra 4(sp)
    addi sp sp 8
	jr ra
    
Endone:
    lw s0 0(sp)
    lw ra 4(sp)
    addi sp sp 8
	li a0 0
	jr ra
```







### five

```assembly
accumulatorfive:
	addi sp sp -8
	sw s0 0(sp)
	sw ra 4(sp)
	mv s0 a0
	lw a0 0(a0)
    beq a0 x0 Endfive
Loopfive:
	addi s0 s0 4
	lw t0 0(s0)
	add a0 a0 t0
	bne t0 x0 Loopfive
	lw s0 0(sp)
	lw ra 4(sp)
	addi sp sp 8
	jr ra
Endfive:
	lw s0 0(sp)
	lw ra 4(sp)
	addi sp sp 8
	jr ra
```



```assembly
.globl accumulatorone
.globl accumulatortwo
.globl accumulatorthree
.globl accumulatorfour
.globl accumulatorfive

#Accumulator:
#Inputs: a0 contains a pointer to an array of nonzero integers, terminated with 0
#Output: a0 should return the sum of the elements of the array
#
#Example: Let a0 = [1,2,3,4,5,6,7,0]
#
#         Then the expected output (in a0) is 1+2+3+4+5+6+7=28

#DO NOT EDIT THIS FILE
#We have provided five versions of accumulator. Only one is correct, though all five pass the sanity test above.

accumulatorone:
	addi sp sp -8
	sw s0 0(sp)
	sw ra 4(sp)
	
    lw s0 0(a0)
    bne s0 x0 L1
	
    lw s0 0(sp)
    lw ra 4(sp)
    addi sp sp 8
    li a0 0
    jr ra
    
L1:
	addi a0 a0 4
    jal accumulatorone
    
    add a0 a0 s0
    lw s0 0(sp)
    lw ra 4(sp)
    addi sp sp 8
   
    jr ra
    

accumulatortwo:
	addi sp sp -4
	sw s0 0(sp)
	li t0 0
	li s0 0
Looptwo:
	slli t1 t0 2
	add t2 a0 t1
	lw t3 0(t2)
	add s0 s0 t3
	addi t0 t0 1
	bnez t3 Looptwo
	j Endtwo
Endtwo:
	mv a0 s0
	lw s0 0(sp)
	addi sp sp 4
	jr ra

accumulatorthree:
	addi sp sp -8
	sw s0 0(sp)
	sw ra 4(sp)
	lw s0 0(a0)
	beq s0 x0 TailCasethree
	addi a0 a0 4
	jal accumulatorthree
	add a0 a0 s0
	j Epiloguethree
TailCasethree:
	mv a0 x0
	j Epiloguethree
Epiloguethree:	
	lw s0 0(sp)
	lw ra 4(sp)
	addi sp sp 8
	jr ra

accumulatorfour:
	li t2 0
LoopFour:
	lw t1 0(a0)
	beq t1 x0 Endfour
	add t2 t2 t1
	addi a0 a0 4
	j LoopFour
Endfour:
	mv a0 t2
	jr ra

accumulatorfive:
	addi sp sp -8
	sw s0 0(sp)
	sw ra 4(sp)
	mv s0 a0
	lw a0 0(a0)
    beq a0 x0 Endfive
Loopfive:
	addi s0 s0 4
	lw t0 0(s0)
	add a0 a0 t0
	bne t0 x0 Loopfive
	lw s0 0(sp)
	lw ra 4(sp)
	addi sp sp 8
	jr ra
Endfive:
	lw s0 0(sp)
	lw ra 4(sp)
	addi sp sp 8
	jr ra

```

