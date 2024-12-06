# RISC-V RV32I Processor

## Introduction
This repo contains our RISC-V CPU, for single cycle implementation, pipelined, and pipelined with cache. The CPU passes the test cases.


### Team 12 members:

| Name   | Personal Statements |    
|------------|-----------------|
| Abraham Lin - Git Master | add link |      
| Charlotte Maxwell | add link|
| Shravan Kumar     |add link |
| Shreeya Agarwal   |add link |


### Team Contributions
|          |                 | Shreeya Agarwal | Shravan Kumar | Charlotte Maxwell | Abraham Lin| 
|----------|----------------|-----------------|---------------|-------------------|------------|
| **Lab 4**| Program Counter| * |               |                  |            |
|          | ALU            |    |               |                   |           |
|          | Register File  |           |               |                   |           |
|          | Instruction Memory  |      | *              |                   |           |
|          | Control Unit  |      |*               |                   |           |
|          | Sign Extend  |   *   |               |                   |           |
|          | Data Path  |     |               |   *                |           |
|          | Testbench  |      |               |                   |        *   |
|          | top level assembly  |      |               |                   |   *        |
| **Single Cycle**| Data Memory  |      |               |   *                |           |
| | Control Unit  |      |  *             |                   |           |
| | Register File | *     |             |                   |           |
| | PC Counter fixes (extra muxes and logic)  |*      |             |     *              |           |
| | datapath  |      | *            |     *              |        *   |
| | top level assembly  | *     | *            |     *              |        *   |
| | unit testing/testbenches  |      |             |                   |        *   |
| | F1.s  | *     |             |                   |        *   |
|**Pipelining** |ff1  |  *    | *            |                   |           |
| |ff2  | *     |            * |                   |           |
| |ff3  | *     |             *|                   |           |
| |ff4  | *     |            * |                   |           |
| |hazard unit  | *     |             |                   |   *        |
| | fetch assembly  |      |  *           |                   |   *        |
| | execute assembly  |      |  *           |                   |    *       |
| | decode assembly  |      |  *           |                   |      *     |
| | unit testing/testbench  |      |             |                   |      *     |
| **Pipelining with Cache** | Direct Mapped Cache  |      |             |        *           |          |
|  | 2-way set associative cache  |      |             |        *           |           |

Note that as team members all frequently met up together, the above table and commits do not accurately represent the individual contribution of team members as:

 - When working together, pushes were often committed from one laptop to avoid issues with git, and to have tests and diagrams open on others. As such, some commits are a combined effort of 2 or more members
- Some commits may be small mistakes which have taken hours to debug, as a combined effort of 2 or more team members, especially when it came to implementation
- Certain commits were overwritten by members having to upload a new file in its place due to issues with Git


For Lab 4 information, see [Lab_4](./Specifications//Lab_4.md).

### Evidence of a Working Processor

See the following videos, for the F1 program, and the 4 waveform PDF programs.

| Dataset        | Gaussian |  Triangle |  Sine | Noisy | 
|--------|------------|------------|------------|--------------|
| **Graphs**|  pic1         | pic2          | pic3          |pic4
| 

### Video Evidence

**F1 Lights**

**Gaussian**

**Sine**

**Triangle**

**Noisy**




- Shreeya:
    - Program Counter: PC.sv
        - Inputs: clk, rst, PCsrc, ImmOp[31:0]
        - Outputs: PC[31:0]
    - Sign extend: SignExtend.sv
        - Inputs: ImmSrc, Imm[11:5]+[4:0] _(from instr)_
        - Outputs: ImmOp[31:0]

- Charlotte:
    - DataPath: DataPath.sv
        - Inputs: rs1[19:15], rs2[24:20], rd[11:7] _(from instr)_, clk, RegWrite, ALUsrc, ALUctrl[2:0], ImmOp[31:0]
        - Outputs: EQ, a0[31:0]

- Shravan:
    - Control Unit: CU.sv
        - Inputs: op[6:0], funct3[14:12], funct7[30] _(from instr)_, EQ
        - Outputs: PCsrc, ALUctrl[2:0], ALUsrc, ImmSrc, RegWrite
    - InstrMem: InstrMem.sv
        - Inputs: PC[31:0]
        - Outputs: instr[31:0] 
- Abraham:
    - Top level assembly: top.sv
        - Inputs: clk, rst
        - Outputs: a0 
