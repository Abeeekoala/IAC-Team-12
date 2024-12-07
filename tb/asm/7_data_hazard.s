    .text
    .global main

main:   li      x0, 50          # attempt to load but shouldn't
        addi    a0, zero, 50    # should get a0 = 50
        li      t1, 20
        li      t2, 30
        sub     a0, t1, t2      # a0 = t1 - t2 = -10

         