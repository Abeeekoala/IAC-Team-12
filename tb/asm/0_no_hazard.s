    .text
    .global main

main:
    # Set up a base address in s0 for our data region (e.g., 0x10000)
    lui    s0, 0x1          # s0 = 0x1000
    li     s1, 10           # s1 = 10
    li     s2, 20           # s2 = 20
    nop
    nop
    # Store them to memory at known offsets
    sw     s1, 0(s0)        # [0x1000] = 10
    sw     s2, 4(s0)        # [0x1004] = 20

    srai   s1, s1, 1        # s1 = 10 >> 1 = 5
    slli   s2, s2, 2        # s2 = 20 << 2 = 80

    lw     s3, 0(s0)        # s3 <- [0x1000] = 10
    lw     s7, 4(s0)        # s7 <- [0x1004] = 20

    addi   s4, s1, -5        # s4 = 5 - 5 = 0
    addi   s5, s2, 2        # s5 = 80 + 2 = 80
    slti   s10, s1, 10      # s10 = (s1 < 10)
    add    s6, s3, s4       # s6 = 10 + 0 = 10
    add    a0, s7, s3       # a0 = s7 + s3 = 30 
    xor    s8, s4, s5       # s8 = 10 ^ 80 = 90
    nop       
    sub    s6, s6, s10      # s5 = 10 - 1 = 9
    nop
    nop
    nop
    add    a0, a0, s6       # a0 = 30 + 9 = 39
    bne     a0, zero, finish    # enter finish state

finish:     # expected result is 39
    bne     a0, zero, finish     # loop forever