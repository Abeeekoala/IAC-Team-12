# RISC-V RV32I Processor Coursework

## Personal Statement of Contributions

**Abraham Lin**

### Overview

- Git Instructions
- Design Diagram
- Sign Extension Unit
- Instruction Memory
- Data Memory
- Jump Instructions
- F1 Program
  - SLLI Instruction
  - Program
- Reference Program
  - Features Added
  - Testing
  - Pipelining
  - Results
- Additional Comments

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
- TestPDF can not pass until I realize that `RET` is actually attempting to write to `ZERO` and there should be no action for this. Yet, our regfile did not inpose this restriction. So this fix had been critical for us. (1 line = 3+ hours starring at the GTKWave).

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

```SytemVerilog
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
## Unit Tests
Unit tests for Single Cycle CPU includes `mux`, `PCreg`, and `sign_ext`. In `sign_extend_tb.cpp`, I tested all type of the instructions to make sure the outputs were desired and consistent with the specification of RISCV.
To run a particular testbench execute the following commands.
```bash
git checkout SingleCycle
cd tb
bash -x ./doit.sh ./tests/<testbench_to_run> #Forexample ./tests/sign_ext_tb.cpp
```

### Proof of CPU_testbench result:
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

 ![alt text](/IAC-Team-12/images/Pipeline%20Debugging.png)

 In the above example, The issue was that we were writing to the `regfile` on the posedge of `clk` and at the decode stage, it can't fetch the updated `regfile` value because it was only updated on the next cycle. Thus the solution was to write to `regfile` on the negedge. I did the same thing for every failed case.
 
 ### Proof of Verified Pipelined CPU:

### Relevant Commits
- [Passed All Test](https://github.com/Abeeekoala/IAC-Team-12/commit/a7e094bcdb5a53e8d9acbf4a5b7ea0cce94983ab)
- [Additional Data Hazard Test for `ZERO`](https://github.com/Abeeekoala/IAC-Team-12/commit/521e6a65270be6a752ee7b81447a1822252420c9#diff-74e4c4e6ff1c41eabaf5c623494365a0615eb9afecf0d6eaf16f45d7410f9298)
