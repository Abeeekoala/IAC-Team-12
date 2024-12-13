# RISC-V RV32I Processor Coursework

## Personal Statement of Contributions

**Abraham Lin**

### Overview

- [Git Instructions](#git-instructions)
- [CPU Design Diagram](#cpu-design-diagram)
- [Single Cycle](#single-cycle)
    - [Sign Extension Unit](#sign-extension-unit)
    - [Arithmetic Logic Unit / Comparator](#arithmetic-logic-unit--comparator)
    - [Control Unit](#control-unit)
    - [Data Path](#data-path)
    - [Top Module for Single Cycle](#top-module-for-single-cycle)
    - [Testbench & Debug for Single Cycle](#testbench--debug-for-single-cycle)
        - [F1_Light.s](#f1_lights)
        - [Unit Tests](#unit-tests)
        - [Proof of Verified CPU](#proof-of-verified-cpu)
    - [Plotting PDF on Vbuddy](#plotting-pdf-on-vbuddy)
- [Pipelined](#pipelined)
    - [Hazard Unit](#hazard-unit)
    - [Testbench & Debug for Pipelined CPU](#testbench--debug-for-pipelined-cpu)
        - [Proof of Verified Pipelined CPU](#proof-of-verified-pipelined-cpu)
- [Pipelined with Cache](#pipelined-with-cache)
    - [2-way Set Associative Cache]()
    - [Testbench & Debug for Pipelined CPU with 2-way Set Associative Cache](#testbench--debug-for-pipelined-cpu-with-2-way-set-associative-cache)
        - [Unit Tests](#unit-tests-1)
        - [Proof of Verified Pipelined CPU with Cache](#proof-of-verified-pipelined-cpu-with-cache)
        
- [F1 Light on Vbuddy](#f1-light-on-vbuddy)

- [Reflections](#reflections)

---
## Git Instructions
To ensure a smooth workflow for our team, as the repository master, I created this [Git_instruction.md](/IAC-Team-12/Git_instructions.md). This file includes the basic instructions for team members to push their work to the repository.

## CPU design diagram
I was mainly responsible for designing the overall architecture and top-level structure of the CPU. To help my teammates understand our design and implement individual components accordingly, I created three top-level design diagrams that detail the wiring, inputs, outputs, and signal logic for the [Single-cycle](/IAC-Team-12/images/RISCVsingle_cycle_final.png), [Pipelined](/IAC-Team-12/images/RISCV_pipelined_hazard_final.png), and [Pipelined with Cache](/IAC-Team-12/images/RISCV_pipelined_cache_final.png).

# Single Cycle
## Sign Extension Unit
Building on the sign extend module from Lab 4, I expanded its logic to handle all instruction types in the `RISCV 32I` instruction set. By assigning the following ImmSrc values to different types of instructions, the unit now accounts for both signed and unsigned extensions:
| ImmSrc | Type             |
|--------|------------------|
|000     | I-type signed    |
|001     | I-type unsigned  |
|010     | S-type           |
|011     | B-type           |
|100     | U-type           |
|101     | J-type           |

### Relavent commits
- [Sign extend for all 32I instruction](https://github.com/Abeeekoala/IAC-Team-12/commit/877a310d032e2fc0b94aab24850477324624b92e#diff-a28e30ae4cad19732102578375f8939620ba125c881f050ec0501424f7a73b0aL16)
## Arithmetic Logic Unit / Comparator

For the ALU, I worked on the `Set Less Than Immediate (SLTI)` and `Set Less Than Immediate Unsigned (SLTIU)` operations and reworked the comparison logic. Initially, I designed the comparison outputs of the ALU as `Zero` (true if `ALUop1` = `ALUop2`), `Less` (true if `ALUop1` < `ALUop2`, signed), and `LessU` (true if `ALUop1` < `ALUop2`, unsigned). These three signals could then be interpreted by the control unit to handle all branch instructions.

When we decided to move the `PC + Imm` operation into the ALU, we needed to separate the comparison operation from the ALU. I introduced a separate Comparator component to handle all comparisons. I added a funct3 input so that it outputs only a single signal, `Relation`, representing whether the corresponding comparison is true. This was critical for adapting the pipelined design because the control unit (CU) and ALU/Comparator are in different pipeline stages, eliminating the need for the CU to interpret comparison results.

```SystemVerilog
always_comb begin
    case (funct3)
        3'b000: Relation = (rs1 == rs2);
        3'b001: Relation = ~(rs1 == rs2);
        3'b100: Relation = ($signed(rs1) < $signed(rs2));
        3'b101: Relation = ~($signed(rs1) < $signed(rs2));
        3'b110: Relation = (rs1 < rs2);
        3'b111: Relation = ~(rs1 < rs2);
        default: Relation = 0;
    endcase
end
```
The above code snippet shows how the comparator handle comparison based on `funct3`.
### Relavent commits
- [Added SLTI/SLTI U instructions; Comparison logic](https://github.com/Abeeekoala/IAC-Team-12/commit/62b34422980566354b90ddf21d19ce2b20ec6bbb#diff-73e85aef537eb0410e90d7b7ef538e7244f12d7d0bd9b8063e2d57ff2c80554b) 
- [Comparator initial design](https://github.com/Abeeekoala/IAC-Team-12/commit/01dacff5090e9f0ca77a48c43ef18c4d8aeccb0a#diff-7beba9f39da0b99d0fee641d5dacb8625b8e9f476d9715df43c29c8b73c3b5f6)
- [New Comparator logic with funct3 input](https://github.com/Abeeekoala/IAC-Team-12/commit/7296d792b20b9bce0a2376c0898651cc3a152e24#diff-7beba9f39da0b99d0fee641d5dacb8625b8e9f476d9715df43c29c8b73c3b5f6)

## Control Unit

Based on the design of the ALU, I also edited the CU to provide the correct signals, added the logic for interpreting comparison signals, and implemented the JALR instruction. I also contributed to reworking the `PCTarget` logic when we decided to use the ALU to calculate `PCTarget`.

### Relevant commits:
- [`ALUCtrl` signal](https://github.com/Abeeekoala/IAC-Team-12/commit/507d855c32e7a17ac7a02e46fa5d246e54120015#diff-d05ca95733e91d82993ae4ed81385aad0268f17447161b3f4dde7d3301b66353)

- [Comparison Interpretation for B-type Instruciton](https://github.com/Abeeekoala/IAC-Team-12/commit/62b34422980566354b90ddf21d19ce2b20ec6bbb#diff-d05ca95733e91d82993ae4ed81385aad0268f17447161b3f4dde7d3301b66353)

- [`JALR` Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/18c607f5d8e45990e6d4c1f9157ab84f7f2738b4#diff-d05ca95733e91d82993ae4ed81385aad0268f17447161b3f4dde7d3301b66353)

- [New `PCTarget` logic](https://github.com/Abeeekoala/IAC-Team-12/commit/55db9d01f8f7fb1c374e4ff72370abfdc7073627#diff-d05ca95733e91d82993ae4ed81385aad0268f17447161b3f4dde7d3301b66353)

## Data Path
While implementing the top module, I noticed many incompatible ports, inconsistencies with the design, and redundant mux components. I reviewed and modified these issues. Additionally, to accommodate `JAL` and `JALR`, the result to write back to the `Regfile` needs to be selected between `ALUout`, `PC + 4`, and `ReadData` from data memory. Therefore, I created a `mux4` to achieve that selection for the result.


### Relevant commits:
- [Data Path Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/585189af39263745860202220ffb74244db97ad1#diff-46d86a067fcb3a7a8d4961f6d2c8e70d7ee3c0a78858ac447080eae4b0c1d2b6)

## Top module for Single Cycle
While working out the top module, I implemented the new branch/jump logic as a combination logic between `Jump`, `Brnach` and `Relation`.

```SystemVerilog
assign PCSrc = (Relation & Branch) | Jump;
```
This ensured that `PC_next` is `PC_target`, which is `PC` + `Imm` for B-type and `JAL` or  `rs1` + `Imm` for `JALR`, both coming from the `ALUout`.


Another main challenge I faced was how to incorporate the `trigger` input. After researching, I decided to use the `Memory-Mapped I/O (MMIO)` approach. MMIO maps the control and data registers of a device into the same address space as the system's main memory. This allows the CPU to interact with hardware peripherals using standard memory instructions (e.g., load and store). Given that our implemented instruction set lacked special instructions for I/O, MMIO was a suitable solution.

Based on the memory map for pdf.s, I assigned the last address of the reserved data memory as the `trigger` input's address (`0x0000_00FC`).

![alt text](/IAC-Team-12/tb/reference/images/memory_map.jpg)

With this design:
```SystemVerilog
  if (A == 32'h000000FC) begin
      // MMIO read from trigger address
      RD = {31'b0, trigger};  // Return trigger in LSB
  end 
  else begin
      // Other loading instructions
  end
```
### Relevant commits:
- [Top for Single Cycle Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/d2ca54468bea576d5a7a01339a7816cab249d6bc#diff-53e28811152d51ade1779d42a8606112657e2c709b8e3920211cecb9d7ee6aa0)
- [Jump/Branch logic revision](https://github.com/Abeeekoala/IAC-Team-12/commit/7296d792b20b9bce0a2376c0898651cc3a152e24#diff-53e28811152d51ade1779d42a8606112657e2c709b8e3920211cecb9d7ee6aa0R35)
- [MMIO Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/2d5bc19b69f77c52fd95d66d69022e7940cdab2c#diff-6486d49c49cf72715552f0e2d16e6d326775647295646c98203524c297ee2acd)

## Testbench & Debug for Single Cycle

Verifying our CPU was both an exciting and frustrating part of the project. Sometimes, issues were obvious, and a quick fix would pass the tests. For example, by fixing the loading path for `datamemory` and `InstrMemory`, I passed 3/5 tests. However, more often than not, test cases would fail with no obvious reason. I would then use the waveform to trace the issue, identify the problematic components, and fix them.

For instance:

- The PDF test consistently failed. Upon close investigation, I realized that the base address to load the `pdf_data` was not set correctly according to the memory map.
- Before implementing the new `PCTarget` logic, I added a mux to select inputs between `rs1` or `PC` for `PCTarget`, which allowed the `JALR` instruction to behave as expected.
- The TestPDF case could not pass until I realized that RET was actually attempting to write to `ZERO`. There should have been no action for this, but our register file did not impose that restriction. Fixing this one line took more than three hours of staring at GTKWave.

These are just two examples of the many errors and bugs I encountered during the project. Each issue required careful debugging, investigation, and iterative fixes to ensure the CPU functioned as expected. More examples of the bugs/ errors fixed can be found in this [commit](https://github.com/Abeeekoala/IAC-Team-12/commit/52ca8fb5fd7e75723d944415bbf97a599b7b1d56).

### F1_Light.s

As part of the testbench, we need to test our CPU with a F1 light program. Building on top of the [F1 program](https://github.com/Abeeekoala/IAC-Team-12/commit/3ab7f30c640d5fbcb227a3180767129bf0baf1bf#diff-b2e855f54fda0f893c59ee4ca6ffa11fe92d2243b9f24ce662fd331f79401f51) my teammate had done. I aimed to implement the following features. First, allows the user to start the lights through `trigger` input, and also make the delay in between the light random. To accomplish these I introduce the `trigger_wait` loop and the `lfsr_continue` subroutine to generate sudo-random delay.

```SystemVerilog
trigger_wait:
    li t0, 0x00000FC            # MMIO address of trigger input
    lw x11, 0(t0)               # Load trigger value into x11 (a1)
    beq x11, zero, trigger_wait
```
This part first access the data memory address assigned to `trigger`, then store that result in `x11`, and finally compare it with `zero` to decide whether to continue to wait for `trigger`. This design is feasible in testing beacuse `trigger` is set to high across cycles, yet however in real life this will mean the user need to fire the `trigger` on the exact cycle CPU read from the `datamemory`. The solution to this is detailed in F1 Light on Vbuddy.

```SystemVerilog
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
```
This is a 7-bit LFSR using primitive polynomial $1 + X^3 + X^7$. The random cycle generated will be store in `s0`, and the last `bnez` is to ensure that we always have at least one cycle of delay.
The full `F1_Light.s` program can be found [here](https://github.com/Abeeekoala/IAC-Team-12/commit/2d5bc19b69f77c52fd95d66d69022e7940cdab2c#diff-9ca7878b769c5314423b747aecd5cc9c2f2333737db6ef8508cb8b2b4ce16c55). Yet this version of `F1_light.s`
was not random enough, beacuse the sequence of the delays was hardcoded since we initialize `s0` as 1, so every time we run the program the delays are exactly the same. I would like it to depends on when the user fire `trigger`. The solution was simple, we jumped to `lfsr_continue` subroutine when we did not recieve a `trigger` signal, and then jump back. Full implementation of the `F1_light.s` for testbench is [here](https://github.com/Abeeekoala/IAC-Team-12/blob/SingleCycle/tb/sasm/6_F1_Light.s)

With this design the cycles in between the states will also be random. To test this program, I added a function `waitForOutput`in `cpu_testbench.h` which wait for a state transition based on the current state and return fail if time out or get unexpected state.
```c
void waitForOutput(uint8_t currentState, uint8_t expectedNextState, int maxCycles) {
        int cycles = 0;
        while (cycles < maxCycles) {
            // Check if the output matches the expected value
            if (top_->a0 == expectedNextState) {
                printf("cycles delayed: %d\n", cycles);
                return;
            }   
            else if (top_->a0 != currentState) {
                    FAIL() << "Unexpected state transition: Current state 0x" << std::hex << (int)currentState
                        << ", transitioned to 0x" << (int)top_->a0
                        << " instead of 0x" << (int)expectedNextState;
                }
            runSimulation(1);
            cycles++;
        }
        // Output current state
        FAIL() << "Timed out waiting for output: Current state 0x" << std::hex << (int)currentState
            << ", expected transition to state 0x" << (int)expectedNextState
            << " after " << cycles << " cycles.";
    }
```
This help me implement the test for F1 light ensuring neat and readibility.
```cpp
TEST_F(CpuTestbench, TestLightSequence) {
    // Run simulation with trigger signal
    setupTest("6_F1_Light");
    initSimulation();
    
    runSimulation(100); //change the cycle to get different delay cycles
    top_->trigger = 1;

    // Validate light sequence
    waitForOutput(0x0,  0x1,  500);  // S0 expect S1
    waitForOutput(0x1,  0x3,  500);  // S1 expect S2
    waitForOutput(0x3,  0x7,  500);  // S2 expect S3
    waitForOutput(0x7,  0xF,  500);  // S3 expect S4
    waitForOutput(0xF,  0x1F, 500);  // S4 expect S5
    waitForOutput(0x1F, 0x3F, 500);  // S5 expect S6
    waitForOutput(0x3F, 0x7F, 500);  // S6 expect S7
    waitForOutput(0x7F, 0xFF, 500);  // S7 expect S8
    waitForOutput(0xFF, 0x0,  500);  // S8 expect S0
    waitForOutput(0x0,  0x1,  500);  // cycle back
}
```
### Unit Tests
Unit tests for Single Cycle CPU includes `mux`, `PCreg`, and `sign_ext`. In `sign_extend_tb.cpp`, I tested all type of the instructions to make sure the outputs were desired and consistent with the specification of RISCV.
To run a particular testbench execute the following commands.
```bash
git checkout SingleCycle
cd tb
bash -x ./doit.sh ./tests/<testbench_to_run> #Forexample ./tests/sign_ext_tb.cpp
```

### Proof of Verified CPU
![alt text](/IAC-Team-12/images/Single_cycle_tests_passed.png)

To reproduce the test results, follow these steps:

```bash
git checkout SingleCycle
cd tb
bash -x ./doit.sh
```
### Relevant commits:
- [3/5 Test passed](https://github.com/Abeeekoala/IAC-Team-12/commit/d392764c75df145b6d9c0545c748555a5105d4ef)
- [`datamemory` address fix](https://github.com/Abeeekoala/IAC-Team-12/commit/7fb178f045a6d8a4795626779db6b037de45ecc8)
- [Mux for `PC_Target`](https://github.com/Abeeekoala/IAC-Team-12/commit/18c607f5d8e45990e6d4c1f9157ab84f7f2738b4#diff-658b1871d775cef76c9d49597837e74842c2b356e6888e095fcd7a0b8ae49d23R26)
- [`regfile` fix](https://github.com/Abeeekoala/IAC-Team-12/commit/9b42b7dfab6cf453c7390ec1f06c43549f8e7dfb)
- [F1 Light ith random delay](https://github.com/Abeeekoala/IAC-Team-12/commit/2d5bc19b69f77c52fd95d66d69022e7940cdab2c)
- [F1 Light Program + Test](https://github.com/Abeeekoala/IAC-Team-12/commit/b329e71cc80a5dbe796a4716915a516544c3cd0c)
- [Unit Tests](https://github.com/Abeeekoala/IAC-Team-12/commit/de3ce702def50684b35bff3ebb75db07a7fd2c23)
- [CPU fully Verified](https://github.com/Abeeekoala/IAC-Team-12/commit/7296d792b20b9bce0a2376c0898651cc3a152e24)

## Plotting PDF on Vbuddy
In the `tb` folder I made a folder `plot` designated for Plotting `PDF`. 

In order to plot the PDF value on Vbuddy I made modification on `pdf.s`. I added an extra line in `_loop3`.
```bash
_loop3:                         # repeat
    LI      a0, 205             # a0 = 205 mark that we will load a value next cycle
    LBU     a0, base_pdf(a1)    #   a0 = mem[base_pdf+a1)
    addi    a1, a1, 1           #   incr 
    BNE     a1, a2, _loop3      # until end of pdf array
```
With that we know that the next `a0` value will be the value we should plot on the Vbuddy. 205 is chosen because none of the values in the array calculated by the `build` will exceed 200.
This led to the following logic inside `plot_tb.cpp`.
```cpp
if (plot == 0 && top->a0 == 205)
        {
            plot = 1;
        }
        if (plot > 256){
            break;
        }
        if (plot > 0){
            if (top->a0 == 205){
                to_load = true;
            }
            else if (top->a0 != 205 && to_load){
                to_load = false;
                plot++;
                vbdPlot(int(top->a0), 0, 255);

            }
        }
```
This plots the correct values built from the `pdf.s` and terminates when we plotted 256 values.

I also made the `doit_plot.sh` script so that we can test with different signals. This script takes in an optional argument for specifying the signals to test on; options include Gaussian, sine, triangle, and noisy. If nothing is given, the default is Gaussian. Then the scripts copy that `signal.mem` file into `data.hex` and then copy the `pdf.hex` in reference into `program.hex` then compile the `top.sv` and incorporate the `plot_tb.cpp` in simulation.

To run the Plotting program execute the following
```bash
git checkout SingleCycle
cd tb/plots/
bash -x ./doit_plot.sh <Optional signal name>
``` 
Note: The plotting Program is also implemented on `Pipelined` and `Pipelinedw/Cache` branches, simply navigate to the branch and execute the above commands.



# Pipelined 
Initially, we started the Pipelined design without the `Hazard Unit`. I had the following design diagram for it.

![alt text](/IAC-Team-12/images/RISCV_pipelined.png)

In order to test it I made a test `0_no_hazard` by insert `nop` between instructions to avoid any form of hazards.

### Relevant commit:
- [No Hazard Test](https://github.com/Abeeekoala/IAC-Team-12/commit/c01edbe9594b69afa7e35c4fee66c63945a2a546#diff-f8e1e8f7115869fc54e3b265957459888043164b8c6da0b34f86534904ae768f)

## Hazard Unit
I helped to implement the logic for forwarding, stall, and flush logic in hazard unit. Initially I had the stall signal when the ALU inputs needs the output from the data memory. Yet later on when I am debuging, I realized that it will be too late to stall the pipeline. We need to stall it when that instruction is in the decode stage and the executing stage is a loading instruction. Therefore I change the `LoadM` input to `LoadE` and added the `Rs1D` and `Rs2D` inputs. 

Also I added the logic for hazard unit to set `Flush` signal when there is a `rst` and not to forward the attempt to write into `ZERO`. An additional test was made to verified these changes.

### Relevant commits
- [Hazard Unit Initial logic](https://github.com/Abeeekoala/IAC-Team-12/commit/97ea56f0cd3670ce42df4efbfb932bd9da8b4dd4#diff-0e44c2f03a2bbd32438ef0083e2a84575f4c41f032c298fb8f2c158c2371aad5)
- [Hazard Unit Stall logic fixed & CU handling Stall](https://github.com/Abeeekoala/IAC-Team-12/commit/a7e094bcdb5a53e8d9acbf4a5b7ea0cce94983ab#diff-0e44c2f03a2bbd32438ef0083e2a84575f4c41f032c298fb8f2c158c2371aad5)
- [Hazard Unit Flush + ZERO forwarding issue](https://github.com/Abeeekoala/IAC-Team-12/commit/521e6a65270be6a752ee7b81447a1822252420c9#diff-0e44c2f03a2bbd32438ef0083e2a84575f4c41f032c298fb8f2c158c2371aad5)

 ## Testbench & Debug for Pipelined CPU

 The debugging for pipelined largely focus on the logic with `Stall` and `Flush` signals, as I detailed above. One interesting debugging technique I cane up with to deal with multiple instruction executing in different stages. 

 ![alt text](/IAC-Team-12/images/Pipeline_Debugging.png)

 In the above example, The issue was that we were writing to the `regfile` on the posedge of `clk` and at the decode stage, it can't fetch the updated `regfile` value because it was only updated on the next cycle. Thus the solution was to write to `regfile` on the negedge. I did the same thing for every failed case.
 
 ### Proof of Verified Pipelined CPU:
 ![alt text](/IAC-Team-12/images/Pipelined_tests_passed.png)

 To reproduce the test results, follow these steps:

```bash
git checkout Pipelined
cd tb
bash -x ./doit.sh
```
### Relevant Commits
- [Passed All Test](https://github.com/Abeeekoala/IAC-Team-12/commit/a7e094bcdb5a53e8d9acbf4a5b7ea0cce94983ab)
- [Additional Data Hazard Test with `rst`](https://github.com/Abeeekoala/IAC-Team-12/commit/521e6a65270be6a752ee7b81447a1822252420c9#diff-74e4c4e6ff1c41eabaf5c623494365a0615eb9afecf0d6eaf16f45d7410f9298)

# Pipelined with Cache

## 2-way set associative cache
For the 2-way set associative cache, I revised the write allocate writeback policy and added in the logic t0 handle `rst`.
```SystemVerilog
always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all sets in the cache
            for (int i = 0; i < 4; i++) begin
                cache[i].U <= 0;
                cache[i].ValitdityBit0 <= 0;
                cache[i].ValitdityBit1 <= 0;
                cache[i].DB0 <= 0;
                cache[i].DB1 <= 0;
                cache[i].tag0 <= '0;
                cache[i].tag1 <= '0;
            end
        end
```
This set the validity flags to `0` and reset the tags preventing wrongful hit and loading. Also, set the dirty bits to `0` to avoid wrong enviction and writeback. 

I also added in the MMIO access for trigger input, moved the loading hit update for `LRU` flag to clocked logic to prevent clocked and combinaional dual assignment. 

### Relavant Commits
- [Writeback policy & handle `rst`](https://github.com/Abeeekoala/IAC-Team-12/commit/d1590e0b52b53423fc1ecac8238f01311c9dfa85#diff-b2adac2aa9dda6c0ae891d38720759f014af7c02900145b9992541ff78bd4133)
- [Trigger Inputs & LRU flags](https://github.com/Abeeekoala/IAC-Team-12/commit/f7df1d904ba4cbbe8ce68d57b220ff532f5b6319#diff-b2adac2aa9dda6c0ae891d38720759f014af7c02900145b9992541ff78bd4133R145)

## Testbench & Debug for Pipelined CPU with 2-way set associative cache

After some minor debugs across files, I came across the issue that our datamemory were not byte-addressed. Which will lead to wrong writeback and wrong loading address. So I changed all the datamemory on all the branches to byte-addressing, and reverified them. 

With the byte-addressing data memory I modified the cache `ReadData` output.
```SystemVerilog
case (funct3)
    3'b000: begin                                           // lb
        case (A[1:0])
            2'b00: DATA_OUT = {{24{Data[7]}}, Data[7:0]};
            2'b01: DATA_OUT = {{24{Data[15]}}, Data[15:8]};
            2'b10: DATA_OUT = {{24{Data[23]}}, Data[23:16]};
            2'b11: DATA_OUT = {{24{Data[31]}}, Data[31:24]};      
        endcase
    end 
    3'b001: begin                                           // lh
        if (A[1]) begin
            DATA_OUT = {{16{Data[31]}}, Data[31:16]};
        end 
        else begin
            DATA_OUT = {{16{Data[15]}}, Data[15:0]};
        end
    end          
    3'b010: DATA_OUT = Data;                                // lw
    3'b100: begin
        case (A[1:0])
            2'b00: DATA_OUT = {{24{1'b0}}, Data[7:0]};
            2'b01: DATA_OUT = {{24{1'b0}}, Data[15:8]};
            2'b10: DATA_OUT = {{24{1'b0}}, Data[23:16]};
            2'b11: DATA_OUT = {{24{1'b0}}, Data[31:24]};      
        endcase
    end
    3'b101: begin                                           // lhu
        if (A[1]) begin
            DATA_OUT = {{16{1'b0}}, Data[31:16]};
        end 
        else begin
            DATA_OUT = {{16{1'b0}}, Data[15:0]};
        end
    end           
    default: DATA_OUT = 32'b0;                        // Default case
endcase
```
This passed 7/9 test passed. The next main challenge was how to incorporate the `stall` signal from cache with the `stall` from hazard unit. This two types of `stall` are different; one is to stall only the fetching and decoding stage for data to be ready at writeback stage; the other is to stall the whole pipelined for fetching data in datamemory. I worked out the logic and sent the signal to approprate components. 

Finally with the fix on `store` instructions, and added a register for fetch signal to prevent logic feedback and latch, all the tests passed.

### Unit Tests
Unit tests for `Hazard unit` and `CU` are implemented I did some minor fix and verified them.

#### Relevant Commits
- [CU_tb fix](https://github.com/Abeeekoala/IAC-Team-12/commit/9ef76f7cffe34e3bb2edc7e573a3a9d4eea9dfea)
- [Hazard_unit_tb fix](https://github.com/Abeeekoala/IAC-Team-12/commit/2fac2326a419fa1496394db83d8b571071388a57)

### Proof of Verified Pipelined CPU with Cache:
![alt text](/IAC-Team-12/images/Pipelined_cache_tests_passed.png)

 To reproduce the test results, follow these command:

```bash
git checkout Pipelinedw/Cache
cd tb
bash -x ./doit.sh
```

When executing the plotting program on this CPU, I realized that when there was cache miss the CPU will actually write a wrong value, `0`, to the desinated register. This did not show up in the test because it get overwrite the next cycle with correct data from datamemory. Yet I modify the logic for RegWrite when stall to prevent this unwanted write to `regfile`.

### Relevant Commits
- [Cache debugging](https://github.com/Abeeekoala/IAC-Team-12/commit/d94de3b3e09da1618af6f9a4020221cad87739ba#diff-b2adac2aa9dda6c0ae891d38720759f014af7c02900145b9992541ff78bd4133)
- [Fix byte-addressing for Single Cycle](https://github.com/Abeeekoala/IAC-Team-12/commit/f35b1f27749d7b1926a0a7103a24b88979478960)
- [Fix byte-addressing for Pipelined](https://github.com/Abeeekoala/IAC-Team-12/commit/92804d6929bdb76c16136c05da8ab16c151c7e9f)
- [Fix byte-addressing + 7/9 tests passed](https://github.com/Abeeekoala/IAC-Team-12/commit/f55ca295b494453c31b338cdc6d54e99bc4409e9#diff-b2adac2aa9dda6c0ae891d38720759f014af7c02900145b9992541ff78bd4133)
- [Fetch register + 9/9 test passed](https://github.com/Abeeekoala/IAC-Team-12/commit/197c252a446eeaf2a0428517e251799679bae9f2#diff-b2adac2aa9dda6c0ae891d38720759f014af7c02900145b9992541ff78bd4133)
- [Fix RegWrite logic when stall](https://github.com/Abeeekoala/IAC-Team-12/commit/e3db1ac755b862be06607e47d3e963c54a889a99)

# F1 Light on Vbuddy
As mentioned above `trigger` signal is nearly imporssible to be fired at the exact cycle we try to load the corresponding address. This was resolved by implement a MMIO FSM in datamemory. 
The FSM has the state defined below.
```SystemVerilog
typedef enum {IDLE, MMIO_requested, MMIO_recieved} MMIO_state;
```
And the next state logic is determined by `MMIO_access`, meaning that the CPU requested a MMIO input, and `trigger`.
```SystemVerilog
always_comb begin
    //MMIO FSM next_state logic
    case(current_state)
        IDLE: next_state = MMIO_access ? MMIO_requested : IDLE;
        MMIO_requested: next_state = trigger ? MMIO_recieved : MMIO_requested;
        MMIO_recieved: next_state = MMIO_access ? IDLE : MMIO_recieved;
    endcase
```
In `F1_tb.cpp`, the reaction time of the user/player was obtained through `vbdElapsed()` and display in digits by `intToBCD()` function
```cpp
if (top->a0 == 0 && timing){
    vbdInitWatch();
    while (timing){
        if (vbdFlag()){
            time = intToBCD(vbdElapsed());
            timing = 0;
        } 
    }
    vbdHex(4, (int(time)>>16) & 0xF);
    vbdHex(3, (int(time)>>8) & 0xF);
    vbdHex(2, (int(time)>>4) & 0xF);
    vbdHex(1, int(time) & 0xF);
}
```
I also made the doit_F1.sh script to execute the program.
```bash
#!/bin/bash
# This script display the pdf build from different signals
# Usage: ./doit.sh signal_name
SCRIPT_DIR=$(dirname "$(realpath "$0")")
RTL_FOLDER="$SCRIPT_DIR/../../modules"
chmod +w "$SCRIPT_DIR"
rm -rf obj_dir
rm -f top.vcd
cd $SCRIPT_DIR
name="top"
verilator   -Wall --trace \
            -cc ${RTL_FOLDER}/top.sv \
            --exe F1_tb.cpp \
            -y ${RTL_FOLDER}
# Create default empty file for data memory
touch data.hex
touch program.hex
cp "$SCRIPT_DIR/F1_Light.hex" "$SCRIPT_DIR/program.hex"
#build C++ project via make automatically generated by Verilator
make -j -C obj_dir/ -f Vtop.mk Vtop
#run executable simulation file
obj_dir/Vtop
```
To run this program, follow the following commands.
```bash
git checkout Pipelinedw/Cache
cd tb/F1_Light
bash -x ./doit_F1.sh
```
### Relavent Commit
- [MMIO FSM + F1 light on vbuddy](https://github.com/Abeeekoala/IAC-Team-12/commit/2e89862b8989782025f32211b6051a7f951e628d#diff-86fa51c0cb8f46be970cb7ec76d0e58aeafb3fa9223d0ebd0ad5722b51f0fbb7R6)

# Reflections
Throughout the project, I focused on designing, integrating, debugging, and creating testbenches for individual components as well as the overall top-level module. This experience was invaluable because it allowed me to see how my designs behaved in a practical setting, and it forced me to identify and correct flaws through rigorous verification and debugging processes. By overcoming these challenges, I not only deepened my understanding of various RISC-V implementations but also gained experience in building them in system verilog.

If time had permitted, I would have liked to analyze the cache hit rate and compare performance against a hierarchical cache structure incorporating both L1 and L2 caches. Such an investigation could provide insights into performance improvements and further optimization opportunities.

Additionally, I learned the importance of effective teamwork and how to distribute tasks among team members for efficient development. This project demonstrated that collaboration and clearly defined responsibilities can significantly improve both productivity and overall project quality.