    .text
    .globl main
main:
    # Initialize LFSR-7
    li s0, 1                    # s0 store LFSR-7 value

    # Wait for trigger to start
trigger_wait:
    li t0, 0x00000FC            # MMIO address of trigger input
    lw x11, 0(t0)               # Load trigger value into x11 (a1)
    beq x11, zero, trigger_wait 

    # Start light sequence
    # State S0: All lights off
    li a0, 0x0                  # data_out = 0 (all lights off)
    jal ra, delay               # Random delay

    # State S2: Turn on lights 1
    li a0, 0x1
    jal ra, delay               

    # State S3: Turn on lights 1 and 2
    li a0, 0x3
    jal ra, delay

    # State S4: Turn on lights 1 to 3           
    li a0, 0x7
    jal ra, delay

    # State S4: Turn on lights 1 to 4
    li a0, 0xF
    jal ra, delay

    # State S5: Turn on lights 1 to 5
    li a0, 0x1F
    jal ra, delay

    # State S6: Turn on lights 1 to 6
    li a0, 0x43
    jal ra, delay

    # State S7: Turn on lights 1 to 7
    li a0, 0x7F
    jal ra, delay

    # State S8: Turn on lights 1 to 8
    li t1, 0xFF
    sw t1, 0(t0)
    jal ra, delay

    # Loop back to wait for the next trigger
    j main                    # Jump back to start

# delay loop
delay:
    # If LFSR-7 value is zero; if so, initialize to 1
    bnez s0, lfsr_continue
    li s0, 1

lfsr_continue:
    # Compute primitive polynomial (bit3 ^ bit7)
    srli t4, s0, 6            # t4 = s0 >> 6 (bit 7)
    andi t4, t4, 1            # t4 = bit 7 value
    srli t5, s0, 2            # t5 = s0 >> 3 (bit 3)
    andi t5, t5, 1            # t5 = bit 3 value
    xor  t6, t4, t5           # t6 = bit7 ^ bit3

    # Update LFSR value
    slli s0, s0, 1            # s0 = s0 << 1
    or   s0, s0, t6           # Insert feedback bit into s0

    # Ensure delay value is not zero
    bnez s0, delay_not_zero
    li s0, 1                  # Reset to 1 if zero

delay_not_zero:
    mv t2, s0                 # Set delay counter

# count down till 0
delay_loop:
    addi t2, t2, -1
    bnez t2, delay_loop
    ret                       # return to main
