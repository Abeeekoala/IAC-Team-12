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

These are just two examples of the many errors and bugs I encountered during the project. Each issue required careful debugging, investigation, and iterative fixes to ensure the CPU functioned as expected. More examples of the bugs/ errors fixed can be found in this [commit](https://github.com/Abeeekoala/IAC-Team-12/commit/52ca8fb5fd7e75723d944415bbf97a599b7b1d56).

### F1.s

### Proof of Tests result:
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
- [Mux for PC_Target](https://github.com/Abeeekoala/IAC-Team-12/commit/18c607f5d8e45990e6d4c1f9157ab84f7f2738b4#diff-658b1871d775cef76c9d49597837e74842c2b356e6888e095fcd7a0b8ae49d23R26)


For nop: For instance, I noticed one critical mistake in `RegFile` is that we 