#Programming project 2

#Test cases and outputs
#(1+2) outputs: 12+ = 3
#(1-(3+5)) outputs: 135+- = -7
#((5-1)+3) outputs: 51–3+ = 7
#(4–(1–2)) outputs: 412-- = 5
#((6-2)+(2-7)) outputs: 62–27-+ = -1
#(((2+1)–5)+(8–4)) outputs: 21+5-84-+ = 2
#((8+1)–(((3-1)+2)–3)) outputs: 81+31–2+3-- = 8

#When running the code: insert a fully parenthesized infix expression
#Parameters: The infix expression should contain at most 60 characters


.data
    buffer: .space 60
    postfixExpression:.space 60
    evaluationStack: .space 124
    str1:  .asciiz "Enter expression to evaluate (infix)\n"
    printEqualSign: .asciiz " = "
    .globl main
    .text
main:
input:
    la $a0, str1                # Prompt user to input expression
    li $v0, 4
    syscall

    li $v0, 8                   # take in input

    la $a0, buffer              # load byte space into address
    li $a1, 60                  # allot the byte space for string

    syscall

infix2postfix:
    li $s1,0                    # length of input string
    la $s2,postfixExpression    # puts the string address into $s2
    li $s3,0                    # index
    la $t1,buffer               # copy of input address
    jal stringLength            # get length of input
    addi $s1,$s1,-1             # deals with exit character at the end
    j infix2postfixCondition
infixLoop:
    lb $s4,($t1)                # t2<-buffer[t1]
    jal filterLexeme            # handles current character

    addi $t1, $t1, 1            # moves input string pointer to next character

    addi $s3,$s3,1              # Increments index
infix2postfixCondition:
    blt $s3,$s1,infixLoop       # loop while index is less than length of input string 
    
    
printInfo:
    la $a0,postfixExpression    # Prints the post fix expression
    li $v0,4
    syscall
    
evaluate:
    la $a0,printEqualSign       # Prints the equal sign
    li $v0,4
    syscall

    la $s5,postfixExpression    # postfix expression is to be evaluated
    la $s7,evaluationStack      # The stack that is used to evaluate the postfix expression
    j evaluationLoopCondition

evaluationLoop:
    beq $s6,43, doAddition      # if +, do addition
    beq $s6,45, doSubtraction   # if -, do subtraction

addNumberToStack:
    addi $s6,$s6,-48            # converts char to int before push (49=1 and 48=0, 49-48=0)
    addi $s7,$s7,4              # moves pointer 4 bytes over
    sw $s6,($s7)                # adds value to stack
    j evaluationLoopCondition

doAddition:
    lw $t0,($s7)                # Retreives number from top of stack
    addi $s7, $s7, -4           # moves pointer to next number
    
    lw $t1,($s7)                # Retreives number from top of stack
    addi $s7, $s7, -4           # moves pointer to next number

    add $t1,$t1,$t0             # adds the numbers

    addi $s7,$s7,4              # moves stack pointer
    sw $t1,($s7)                # pushes sum to stack
    
    j evaluationLoopCondition

doSubtraction:
    lw $t0,($s7)                # Retreives number from top of stack
    addi $s7, $s7, -4           # moves pointer to next number

    lw $t1,($s7)                # Retreives number from top of stack
    addi $s7, $s7, -4           # moves pointer to next number

    sub $t1,$t1,$t0             # subtracts the numbers
    
    addi $s7,$s7,4              # moves stack pointer
    sw $t1,($s7)                # pushes difference to stack
    
    j evaluationLoopCondition

evaluationLoopCondition:
    lb $s6, ($s5)               # Gets the next character in postfix expression
    addi $s5,$s5,1              # Moves the postfix expression pointer
    bne $s6,0,evaluationLoop    # If the next char does not have ascii value 0, jump to loop
    
    #After the loop

    lw $t5,($s7)                # get the final result from the stack
    addi $sp,$sp,4              # pop from the stack
    
    move $a0,$t5                # Printing the final result
    li $v0,1
    syscall


quitProgram:
    li $v0, 10                  # end program
    syscall

#method
stringLength:
    lb $t2,($t1)                # t2<-buffer[t1]
    beqz $t2,backToCall         # once EOF is scanned, exit
    addi $t1,$t1,1              # go to next position in input
    addi $s1,$s1,1              # size++
    j stringLength              # loop again
backToCall:
    la $t1,buffer               # moves $t1 back to the beginning of buffer
    li $t2,0                    # resets $t2 so $t2 can be used later
    jr $ra                      # jumps back to the place the method was called

#method
filterLexeme:
    beq $s4,40,handleOpenPar    # if '(' is scanned
    beq $s4,41,handleClosePar   # if ')' is scanned
    beq $s4,43,handleOperator   # if '+' is scanned
    beq $s4,45,handleOperator   # if '-' is scanned
    beq $s4,48,handleDigit      # if '0' is scanned
    beq $s4,49,handleDigit      # if '1' is scanned
    beq $s4,50,handleDigit      # if '2' is scanned
    beq $s4,51,handleDigit      # if '3' is scanned
    beq $s4,52,handleDigit      # if '4' is scanned
    beq $s4,53,handleDigit      # if '5' is scanned
    beq $s4,54,handleDigit      # if '6' is scanned
    beq $s4,55,handleDigit      # if '7' is scanned
    beq $s4,56,handleDigit      # if '8' is scanned
    beq $s4,57,handleDigit      # if '9' is scanned
    beq $s4,32,returnToCall     # if ' ' is scanned, exit function
    
    

handleOpenPar:
    addi $sp, $sp,-1            # push '(' to stack
    sb $s4,($sp)
    j returnToCall

handleClosePar:
    j closeParCondition
closeParLoop:
    sb $t4,($s2)                #postfix+=stack.pop()
    addi $s2,$s2,1
    
closeParCondition:
    lb $t4,($sp)                # stack peek
    beq $t4,40,lastPop          # if '(', then exit loop
    addi $sp,$sp,1              # pop from stack
    j closeParLoop              # Go to loop
lastPop:
    
    lb $t4,($sp)                # stack.pop()
    addi $sp,$sp,1
    j returnToCall              # exits method

handleOperator:
    lb $t4,($sp)                # stack.peek()
    beq $t4,43,popOperator      # if '+'
    beq $t4,45,popOperator      # if '-'
    j pushOperator              # Now that there is no operator on top of stack, push operator to stack

popOperator:
    sb $t4,($s2)                # postfix+=stack.pop()
    addi $s2,$s2,1
    addi $sp,$sp,1

pushOperator:
    addi $sp,$sp,-1             # pushes operator to stack
    sb $s4,($sp)
    j returnToCall

handleDigit:
    sb $s4,($s2)                # postfix+=number
    addi $s2,$s2,1
    
    j returnToCall

returnToCall:
    jr $ra                      # jumps to the part of the program that called the method
