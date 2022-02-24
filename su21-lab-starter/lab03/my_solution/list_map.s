
bl map

.text
main:
    jal ra, create_default_list
    add s0, a0, x0 # a0 (and now s0) is the head of node list
    #s0是list头节点的地址

    # Print the list
    add a0, s0, x0
    jal ra, print_list
    # Print a newline
    jal ra, print_newline

    # === Calling `map(head, &square)` ===
    # Load function arguments
    add a0, s0, x0 # Loads the address of the first node into a0
    #a0 - 头结点的位置

    # Load the address of the "square" function into a1 (hint: check out "la" on the green sheet)
    ### YOUR CODE HERE ###
	la a1, square	#a1是square函数的地址

    # Issue the call to map
    jal ra, map		#调用map

    # Print the squared list
    add a0, s0, x0
    jal ra, print_list
    jal ra, print_newline

    # === Calling `map(head, &decrement)` === map(a0, a1)
    # Because our `map` function modifies the list in-place, the decrement takes place after
    # the square does

    # Load function arguments
    add a0, s0, x0 # Loads the address of the first node into a0
    #s0是list头节点的地址,存在a0里
    
    # Load the address of the "decrement" function into a1 (should be very similar to before)
    ### YOUR CODE HERE ###
    la a1, decrement

    # Issue the call to map
    jal ra, map

    # Print decremented list
    add a0, s0, x0
    jal ra, print_list
    jal ra, print_newline

    addi a0, x0, 10
    ecall # Terminate the program

map:
    # Prologue: Make space on the stack and back-up registers
    ### YOUR CODE HERE ###
    #调用map函数，将之前的参数寄存器和返回地址压栈，返回地址在最上面
    addi sp, sp, -12
    sw 	ra, 0(sp)
    sw	s0, 4(sp)
    sw	s1, 8(sp) 	#后面会用到s1，防止s1内容丢失，也将其压入栈中
    
    
loop1:
    beq a0, x0, done # If we were given a null pointer (address 0), we're done.
    # if (head == NULL) return

    add s0, a0, x0 # Save address of this node in s0 - s0 = 头结点地址
    add s1, a1, x0 # Save address of function in s1	- s1 = square函数地址

    # Remember that each node is 8 bytes long: 4 for the value followed by 4 for the pointer to next. - 地址的前4个字节是value，后四个字节是指针
    # What does this tell you about how you access the value and how you access the pointer to next?

    # Load the value of the current node into a0 - 将s0里面地址的前四个字节内容加载到a0
    # THINK: Why a0? - a0是参数寄存器，交给square函数并返回
    ### YOUR CODE HERE ###
    lw a0, 0(s0)
    
    # Call the function in question on that value. DO NOT use a label (be prepared to answer why).
    # Hint: Where do we keep track of the function to call? Recall the parameters of "map".
    ### YOUR CODE HERE ###
    jalr ra, s1, 0

    # Store the returned value back into the node - s0地址的前四个字节
    # Where can you assume the returned value is? - a0
    ### YOUR CODE HERE ###
    sw a0, 0(s0)

    # Load the address of the next node into a0
    # The address of the next node is an attribute of the current node.
    # Think about how structs are organized in memory.
    ### YOUR CODE HERE ###
    lw a0, 4(s0)

    # Put the address of the function back into a1 to prepare for the recursion
    # THINK: why a1? What about a0? - a0是下一个结点的地址，将交给square函数循环处理;a1是square函数的地址,是需要传递到下一次循环里调用的参数
    ### YOUR CODE HERE ###
	add a1, x0, s1
    
    # Recurse
    ### YOUR CODE HERE ###
    j loop1

done:
    # Epilogue: Restore register values and free space from the stack
    ### YOUR CODE HERE ### - 怎么入栈，出栈就是一样的，函数结束即出栈
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12

    jr ra # Return to caller

# === Definition of the "square" function ===
square:
    mul a0, a0, a0
    jr ra

# === Definition of the "decrement" function ===
decrement:
    addi a0, a0, -1
    jr ra

# === Helper functions ===
# You don't need to understand these, but reading them may be useful

create_default_list:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    li s0, 0            # Pointer to the last node we handled
    li s1, 0            # Number of nodes handled
loop:                   # do...
    li a0, 8
    jal ra, malloc      #     Allocate memory for the next node
    sw s1, 0(a0)        #     node->value = i
    sw s0, 4(a0)        #     node->next = last
    add s0, a0, x0      #     last = node
    addi s1, s1, 1      #     i++
    addi t0, x0, 10
    bne s1, t0, loop    # ... while i!= 10
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

print_list:
    bne a0, x0, print_me_and_recurse
    jr ra               # Nothing to print
print_me_and_recurse:
    add t0, a0, x0      # t0 gets current node address
    lw a1, 0(t0)        # a1 gets value in current node
    addi a0, x0, 1      # Prepare for print integer ecall
    ecall
    addi a1, x0, ' '    # a0 gets address of string containing space
    addi a0, x0, 11     # Prepare for print char syscall
    ecall
    lw a0, 4(t0)        # a0 gets address of next node
    jal x0, print_list  # Recurse. The value of ra hasn't been changed.

print_newline:
    addi a1, x0, '\n'   # Load in ascii code for newline
    addi a0, x0, 11
    ecall
    jr ra

malloc:
    addi a1, a0, 0
    addi a0, x0, 9
    ecall
    jr ra
