# Personal Statement
## Shreeya Agarwal

### Overview
- PC Register
- Sign Extension Unit
- Register File
- F1 assembly code
- Flip Flop Registers
- Hazard Unit
- Memory Implementation for 2 set associative cache
- Unit Test
- Branch Prediction
- Super Scalar model
- Additional Comments

Note, throughout looking in the commit history, I sometimes come up by ShreeyaAg, and sometimes I have commited as root (due to some weird configuration with laptop not sure).

### PC Register

I made the PC Register for Lab 4, and it's structure didn't need to be changed for the implementation of a single cycle CPU. Upon Pipelining however, the logic had to be changed slightly to implement Stall and Flush for data hazards through a hold.

### Sign Extension Unit

The Sign Extension from labs 4 shouldn't have had a change in structure for the single cycle CPU. However initially I didn't take into account modifying the test case for each instruction type. Since I made a general case, when it came to testing and implementing, the logic had to be updated to take into account each instruction type, which was done with the help of my teammate who was doing implementation. The instruction types can be seen as below:

![alt text](images/regfile.png)

In the module, the type of instruction is determined by the ImmSrc signal.

| ImmSrc | Type |
|--------|------|
|000     | Immediate-Signed|
|001     | Immediate-Unsigned|
|010     | Store|
|011     | Branch|
|100     | Upper Immediate |
|101     | Jump |

A case statement was used to implement all of these changes

### Register File

The Register File uses multiple components to store data.

![alt text](images/signext.png)

```SystemVerilog

parameter ADDR_WIDTH = 5,          // a0_width = 5
DATA_WIDTH = 32
```

Here I've defined the width of the address bus to select the registers. Here, I have ${2^{5} = 32}$ possible register addresses. The data is also 32 bits wide, which was further instantiated here:

```systemverilog
logic [DATA_WIDTH-1:0] regfile_array [2**ADDR_WIDTH-1:0];
```

We have 2 read ports which are used to select which registers to read from, and 1 write address to specify where the data is written into.

We then start the logic for *reading* and *writing*.

The **read logic** is implemented in an `always_comb` block to ensure the logic executes combinationally whenever an address input (`A1`, `A2`, `A3`) change. In the file, `a0` is a specialised output reading from register `x10`, used to represent the first arguement register so tha nothing is automatically written back into that as an automatic loop.

I ensured the logic was **asynchronoous** so that the outputs changed immediately when the respective register address changes without waiting for a clock edge (good especially as reading is a fast, low-latency operation).

The **write logic** is synchronous, and the data from `WD3` would be written to the register specified by `A3` if `WE3` is high. We also check that `A3 != 5'b00000` since `x0` is hardwired to 0, and we don't want to modify that.

### F1.s assembly code

The initial code I came up with:

```assembly
main:
    # initialise the light states in data memory
    li t0, 0x00100000           # base address of data memory
    sw zero, 0(t0)              # turn off all lights intitally

    #turn on light1
    li t1, 0x1                  # state of light1
    sw t1, 0(t0)                # store data in memory
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

# delay loop
delay:
    li t2, 0xFFF           # adjust delay as needed

delay_loop:
    addi t2, t2, -1             # decrement counter
    bnez t2, delay_loop         # loop until counter reaches 0
    ret                         # return to main program

    .data
    .org 0x00100             	# start of data memory

    .word 0                     # light stages (default: all of)
```

In this code, we see it cycle through the different states of lights, where the states are encoded in HEX. I incremented this in powers of 2, because we essentially add '1' to the next bit of the binary number (same as multiplying by 2), allowing each light to correspond to a specific bit in the binary number. 

My main issues were spelling mistakes, not implementing a trigger, not beginning the *text* section and not making the *main* globally visible. This was modified in the implementation by my teammate, where we used a **LSFR-7** to generate a pseudo-random sequence (with 3 stages: initialisation, feedback calculation, update). We also added delay control to ensure the *delay value* doesn't reach zero when counting down to create the delay.

### Flip Flop Registers

After the implementation of single cycle was finished, we moved on to pipelining. One of the major changes to the design was the addition of the 4 flip flops, which are key to store enable parallel execution of multiple instructions.

According to the diagram given in the lecture slides, I made the initial structure for the 4 flip flops, with all the inputs and outputs and their widths. The logic was inside a block, and always synchronous.

Since the addition of the flip flops made the breakdown of the 4 stages clearer, instructions in the stage before were stored into the stage after:

e.g. fetch into decode, decode into memory etc.

Upon starting the implementation of this, we also saw it to be easier to split the top file into the 4 stages, to easily differentiate what's going on at every stage, and make our top file cleaner and less crowded. This is very evident within the files.

Within the flip flops, the main thing which had to be changed was the addition of the flush and stall logic, which became clearer after the hazard unit implementation, and can be seen within the final file. 


### Hazard Unit

The hazard unit is used to manage pipeline hazards, and ensure the correct execution of instructions without errors. Hazards arise when dependencies and conditions prevent instructions from being executed as intended.

The main hazards we had to tackle were:

**Data Hazards**
 - Read-after-Write (RAW)
    - a.k.a true dependency
    - when an instruction reads data another instruction is writing into

 - Write-after-Read (WAR)
   - a.k.a antidependency
   - when an instruction writes to a register that a previous instruction read from

- Write-after-Write (WAW)
 - a.k.a output dependency
 - when 2 instructions write to the same register

 **Control Hazards**
 These arose due to branch conditions which could cause the pipeline to potentially fetch the wrong instruction. If the processor takes the wrong value, then delays occur till the branch condition is resolved.

 **Structural Hazards**
 These occur when there's not enough hardware resources to execute an instruction. 

 **How were these tackled?**

1) Stalling - insert a `nop` to delay stages till dependencies were solved
2) Forwarding - forward data available earlier than expected (i.e. data is written back to a register or memory later in the pipeline) to avoid stalling
3) Flushing - if there's a misprediction in branch instruction, or a data dependency causing an incorrect instruction to enter the pipeline, we flush to avoid errors.

**Initial Implementation**
In my initial implementation, we see source registers from the *Decode*, and *Execute* stage, destination registers from the *Memory* and *Write-back* stage, and flags to indicate if a load is in the MEM stage, if MEM stage is writing back to a register, or WB stage is writing back to a register.

These would lead to signals for forwarding 2 signals, and if the pipeline should be stalled or flushed.

In summary, it handles load-use hazards by stalling, and control hazards by flushing.

**Main Initial Logic**

All flush, stall, and forwarding was intialised as 0.

```systemverilog
        if (RegWriteM && (RdM != 0) && (RdM == Rs1E)) begin
            ForwardAE = 2'b10; //forward from MEM to EX
        end
        else if (RegWriteW && (RdW != 0) && (RdW == Rs1E)) begin
            ForwardAE = 2'b01; //Forward from WB to EX
        end
        else begin
            ForwardAE = 2'b00;   //no forwarding
        end
```

This was responsible for the *forwarding* from the *MEM* or *WB* stages to the *EX* stage. If the EX stage requires data that is not yet written back but is available in a previous stage (MEM or WB), the data is forwarded instead of waiting for the data to be written back to the register file.


```systemverilog
    if(RegWriteM && (RdM != 0) && (RdM == Rs2E)) begin
        ForwardBE = 2'b10;
    end
    else if (RegWriteM && (RdW != 0) && (RdW == Rs2E)) begin
        ForwardBE = 2'b01;
    end
    else begin
        ForwardBE = 2'b00;
    end
```

This block was responsible for the data forwarding logic and is specifically for the second source register `Rs2E` used in the *Execute* (EX) stage. If the instruction in the EX stage depends on data that will be written back in the MEM or WB stages, this logic forwards the data from the appropriate stage (MEM or WB) to the EX stage. This helps avoid data hazards and ensures that the EX stage has the correct input values, preventing pipeline stalls.

```systemverilog
    if (MEmReadE && ((RD2E == Rs1D) || (RD2E == Rs2D))) begin
        stall = 1'b1;
    end
    else begin
        stall = 1'b0;
    end
```
This code detects a load-use data hazard and inserts a stall to delay the execution of the instruction in the EX stage until the load instruction in the MEM stage completes and writes back the data to the register file. Without this stall, the instruction in the EX stage could try to use data that hasn't yet been written back, leading to incorrect results.

`MemReadE` checks if the current instruction is a load (`lw`). `RD2E == Rs1D || RD2E == Rs2D` checks if the load instruction's data is needed by the current instruction. If a hazard is deteted, it sets `stall` to `1`.

```systemverilog
    if (branch) begin
        flush = 1;
    end
``` 

This block was to deal with control hazards which occur when the program execution path is uncertain due to a branch instruction, such as following a branch like `beq`, `jal`, or `jalr`. This logic managed the **flush** of the pipeline when a branch is taken. The flush was going to be involved in the **IF** stage, and the **ID** stage.

We then updated it and came up with a cleaner logic for the following reasons:

 - My intial logic lacked explicit flushing logic for control hazards
 - It had logic to handle **load-use hazards**, but may have conflated for different types of hazards due to shared signal names

This had clearer modularity (separating logic for data and control hazards for easier debugging and extending), a `flush` signal specifically for control hazards, and simpler logic (especially with regards to my naming conventions).

### Memory Implementation for Cache

I wanted to be more involved with the implementation and debugging aspects of this project, especially as I didn't have much of a hands on role within the memory stage of this project beyond the first part. For this reason, once my teammates had finished writing up the logic for the *2 way set-associative cache*, I decided to look into implementation of this new module. 

Having split the top file into the 4 separate stages prior made this much easier. Using the schematic drawn up, I implemented the new logic by adding in *cache* inputs and outputs, as well as modifying what was going into and out of the *Data Memory*.

This then led to the modificiation of the top file, with new input signals, and a couple of new wires instantiated. 

### Unit Test

Following this, the main requirements for the assignment were done. Since we had already done a test for each processor, and our layout made it very easy to debug and see what was going wrong, we didn't have to implement a lot of individual tests.

For some of the bigger units however, we decided to include tests (i.e. the *Control Unit* and the *Hazard Unit*). I had never written a test before, so this was a good way for me to understand the logic of other units which I hadn't written, and also ensure we don't run into any small issues with bigger modules. 

Writing the unit test for the *Control Unit*, I fully understood the different instructions and how they were implemented, and what expected outputs would lead to, and this also helped me clarify how its inputs and outputs linked in with other modules as well. This was all written in C++, and intially I used a really bad structure, and made lots of errors which caused  weird output. I then, comparing against the structure of some of the other unit tests, matched my structure, leading to much easier debugging and clarification in what's being tested.


### Additional Comments
