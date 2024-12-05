## EIE2 Instruction Set Architecture & Compiler (IAC) Group Project Team 12

### Team member:
- Abraham Lin : Git Master
- Charlotte Maxwell 
- Shravan Kumar Murki 
- Shreeya Agarwal 
For pipeline design see the following diagram
![alt text](images/RISCV_pipelined.png?raw=true)



For Lab 4 information, see [Lab_4](./Specifications//Lab_4.md).

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
