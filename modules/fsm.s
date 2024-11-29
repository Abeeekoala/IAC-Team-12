main:
    # initialise the light states in data memory
    li t0, 0x00100000           # base address of data memory
    sw zero, 0(t0)              # turn off all lights intitally

    #turn on light1
    li t1, 0x1                  # state of light1
    sq t1, 0(t0)                # store data in memory
    jal ra, delay               # delay before next light

    # turn on light2
    li t1, 0x3                  # light 1 and 2 state
    sw t1, 0(t0)                # store state in memory
    jal ra, delay               # delay before next light

    # turn on light 3           
    li t1, 0x7                  # light 1/2/3 state
    sw t1, 0(t0)                # store state in memort
    jal ra, delay               # delay before reset

    # turn on light 4
    li t1, 0xF                 #light 1/2/3/4 state
    sw t1, 0(t0)
    jal ra, delay

    # turn on light 5
    li t1, 0x1F                 #light 1/2/3/4 state
    sw t1, 0(t0)
    jal ra, delay

    # turn on light 6
    li t1, 0x43                #light 1/2/3/4 state
    sw t1, 0(t0)
    jal ra, delay

    # turn on light 7
    li t1, 0x7F                 #light 1/2/3/4 state
    sw t1, 0(t0)
    jal ra, delay

    # turn on light 8
    li t1, 0xFF                 #light 1/2/3/4 state
    sw t1, 0(t0)
    jal ra, delay


    # reset sequence (loop back to start)
    j main                      # restart sequence

//delay loop
delay:
    li t2, 0xFFF           # adjust delay as needed

delay_loop:
    addi t2, t2, -1             # decrement counter
    bnez t2, delay_loop         # loop until counter reaches 0
    ret                         # return to main program

    .data
    .org 0x00100000             # start of data memory

    .word 0                     # light stages (default: all of)
