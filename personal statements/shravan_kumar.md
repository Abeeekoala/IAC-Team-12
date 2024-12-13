----
# Contents

---

1. [[#Single Cycle Work]]
	a) [[#Instruction Memory]]
	b) [[#Sign Extend]]
	c) [[#ALU]]
	d) [[#Control Unit and Top Level]]

2. [[#Pipelined work]]
	a) [[#Flip Flops]]
	b) [[#Top Level]]
	c) [[#Hazard Unit Implementation]]

3. [[#Testing Work]]
	a) [[#Hazard Unit Test]]

4. [[#Conclusion]]

---
# Single Cycle Work

---
## Instruction Memory
**[InstrMem.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/InstrMem.sv)**
- The instruction memory is ROM which has an address input to it and will output the value stored at the address.
- The values stored in the ROM are the values of the assembly code which has been compiled to machine code by the assembler in "instructions.mem" and this can be changed to the relevant machine code in .hex depending on the instructions being carried out.
- ROM has to be accessed asynchronously as the ROM should update as soon as the new PC value has been passed through to it and therefore always_comb logic is used.
- Byte addressing was implemented so that each memory cell contains a byte of the instruction memory and they are accessed 4-bytes at a time to be output.

**Relevant Commits**
[Instruction Memory Implementation Part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/b506b88f7759b5756544cff0409729dd4f80a78c)
[Instruction Memory Implementation Part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/b860a7a3c65c5e2cbf402266713b6a0b2d3f9ef7)

## Sign Extend
**[Sign_Ext.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/sign_ext.sv)**
- From Lab4 the sign_ext.sv unit was implemented by using the opcode through ```Case(Opcode)``` leaving ImmSrc redundant which I decided to make more efficient through the use of ```Case(ImmSrc)``` instead.
- By using ImmSrc this allows same opcodes which may have different requirements such as signed or unsigned extensions to be dealt with and also 
- ```Case(ImmSrc)``` will allow for more extension types to be implemented for the same opcode depending on the instruction being carried out which is not possible when using ```Case(Opcode)``` to determine what to do with the Imm.
- I implemented the i-type signed, s-type signed and b-type signed Imm extensions allowing Abraham to determine the rest of the Imm extensions depending on how he designed the ALU.
- As a result of more extension types being needed Abraham then expanded the sign_ext.sv to 3-bits and determined the other extensions based on the completed ALU design.

**Relevant Commits**
[Sign Extend Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/b103a8a7c154b7fe3d1cb050333cb0ef64a79499)

## ALU
[ALU.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/SingleCycle/modules/ALU.sv)
- Whilst I was working on the control unit I had seen that the ALU had insufficient capabilities and therefore I had expanded the ALUctrl signal coming from the control unit to 4 bits and added the required capabilities.
- To add these extra capabilities I added in extra cases to the 4 bit case(ALUctrl) logic and decided what the extra cases should be based on the RISC-V 32I instruction documentation and what was required by the control unit. 
- The capabilities I added were sufficient for implementing all the instructions in combination with the control unit, however, there was an issue with the signed SLTU and ASR which was the corrected by Abraham.

**Relevant Commits**
[ALU Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/990a034fd01777198f4e38c33748c5239b3a9f77#diff-73e85aef537eb0410e90d7b7ef538e7244f12d7d0bd9b8063e2d57ff2c80554b)

## Control Unit and Top Level
[CU.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/CU.sv)
- Having worked on the control unit from the start for the single cycle implementation I defined the input and output of the control unit as follows:
	- Inputs - ```funct3```, ```opcode```, ```funct7_5``` - determines the specific instruction being carried out.
		- ```funct7_5``` can be passed through as a 1-bit input is sufficient and not the whole of funct7 is required as funct7 is either 7'h20 or 7'h00 for each given same opcode and funct3 making the other bits in funct7 redundant.
	- Inputs - ```Zero```, ```Less```, ```LessU``` - each of the following return whether their relevant comparisons found in the ALU are true or not which is required to implement the branch instructions - these later replaced through a comparator unit with Branch and Jump as detailed later.
	- Output - ```ImmSrc``` - determines the type of sign extend carried out on the Imm if required.
	- Output - ```PCSrc``` - determines if there is a normal increment to PC or a jump/branch is being executed - PCSrc was replaced later by Branch and Jump as detailed later.
	- Output - ```RegWrite/MemWrite``` - determines if the regfile or datamem are being written to respectively.
	- Output - ```ALUCtrl``` - determines which operation is being executed by the ALU.
	- Output - ```ALUSrc``` - selects what to operands to feed into the ALU - this was expanded on as detailed later.
	- Output - ```ResultSrc``` - selects which operand to pass to result which can then be written to Rd.
- Initially, the design was based on the diagram provided in Lecture 7, however, it became clear as I was implementing the control unit that further logic and design changes would be required to implement the load, store, branch, jump and u-type instructions.
- Load, store instruction related design changes:
	- For load and store I had initially tried to implement two signals one specifying the width and the other specifying msb/zero extends that would be used with MemWrite to determine what operation is carried out. However, this is a 2-bit and 1-bit signal which is just as efficient as using funct3 so I reverted to a funct3 method of implementing load and store.
	- The funct3 method of implementing load and store is that if MemWrite is 1 then a store is being carried out otherwise a load is being carried out and the length to load/store with the msb/zero extend is determined by funct3 accordingly - here the additional signal of funct3 has to be passed to the datamem.
- Branch, jump, u-type instruction related design changes:
	- Initially, I had tried to implement three new MUXs would select at the WD3 input, PCNext input 1 and PCTarget Adder's second element with ALU carrying out imm << 12, however, it was clearly apparent this was the wrong approach as this would make pipelining very difficult and created too much redundancy.
	- Next the approach was to use the redundancy in sign_ext to carry out ```imm << 12``` inside the sign_ext and feed PCTarget to the ResultSrc mux adding an additional bit to that mux - this approach was far more efficient however this overlooked JALR instruction which needed ```PC = rs1 + Imm)``` further changes were required.
	- However, after further discussing with Abraham we decided to change the logic so when PC + x is required that is carried out in ALU itself as the ALU was redundant in those scenarios.
	- To do this we used ALUSrcA and ALUSrcB: ALUSrcA selects between Rs1 and PC and ALUSrcB selects between rs1 and ImmExt same as ALUSrc before.
	- Now additions to PC can be carried out in the ALU passed to result and written back, the special increments of PC  =+ Imm / = rs1 + (Imm << 12) can now be carried out inside the ALU as ALUout is the new PCTarget - this also removes the need for a second adder which was before calculating PCTarget.
	- rd = PC+4 was enabled through an extra bit in ResultSrc where the third option is PCPlus4 which passes it to result which can then be written to rd, rd = Imm << 12 was enabled through passing through just operand2 from the ALU to result which can be written to rd.
	- At first the  the branch instructions Zero, Less and LessU were initially designed by Abraham which in the ALU would carry out all the comparison types and the required comparison result can be accessed by the control unit, however, now through the use of ALUSrcA and ALUSrcB we can use a new component.
	- Abraham and I decided we should use a comparator unit which would get passed funct3 and therefore determine which comparison to carry out and return 0 or 1 depending on if the condition was met.
		- This was to make sure that the design would be compatible for pipelining later on as otherwise the operation overall is split between decode and execute stages which are separated by a flip flop so by the time Zero, Less and LessU return from the ALU the next instruction is already being processed which is completely different rendering the branch logic useless.
	- This combined with some external logic using Branch and Jump determines if PCSrc is 1 or 0 through ```PCSrc = (Jump) | (Branch & Comparator)``` - further details can be found in Abraham's personal statement.
		- Branch and Jump are 1-bit signals which go to 1 if the instruction is a branch or jump instruction respectively.
		- Comparator is the output of the comparator returning whether the comparison selected by funct3 returned true or false.
	- A separate comparator unit is required so that other branch and jump instructions can be carried out rs1/rs2 may not always match SrcA/SrcB for the ALU as in the branch instructions.
- Implementing all these changes gave this final [design](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCVsingle_cycle_final.png) giving minimal redundancy whilst implementing all the full RISC-V 32I instruction set.

**Relevant Commits**
[]()
[]()

---
# Pipelined work

---
## Flip Flops
[ff1.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff1.sv)
[ff2.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff2.sv)
[ff3.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff3.sv)
[ff4.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff4.sv)
- The flip flops are registers which will be placed between each of the stages in the pipeline and allow different instructions to be processed at different stages of the pipeline.
	- The main aim behind pipelining is to allow different areas of the CPU to process different instructions and therefore increase the clock frequency of the CPU.
- Shreeya had provided the basic flip flops required for pipelining, however, this was based on the design provided in Lecture 8 and therefore required adjustments to fit the [design without the hazard unit](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCV_pipelined.png) that I had decided upon.
- To make these changes I added in the new input and outputs following the existing always_ff clocked structure and following the naming structure as set out in the diagram.

**Relevant Commits**
[]()
- a
## Top Level
[fetch.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/fetch.sv)
[decode.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/decode.sv)
[execute.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/execute.sv)
[memory.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/memory.sv)
[writeback.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/writeback.sv)
[top.sv pipelined](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/top.sv)
- The top level in the single cycle was broken down into PC, control path and datapath which is not suitable for pipelining as this crosses multiple pipeline stages.
- Therefore, I decided to break down top into fetch, decode, execute, memory and writeback stages
- Each of stages would take the inputs from their respective prior stages or other stages and give the output, from giving the flipflop the appropriate inputs, to the next stage.
- I further expanded on this by implementing forwarding and the Hazard Unit which was designed by Abraham and Shreeya as detailed in the next section.

 **Relevant Commits**
[]()
- a
## Hazard Unit Implementation
[top.sv pipelined](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/top.sv)
- As the two main problems with 
- 
- a

**Relevant Commits**
[]()
- a
---
# Testing Work

---
## Hazard Unit Test
[]()
- a

**Relevant Commits**
[]()
- a
---
# Conclusion

---
To conclude, 
