---
# Contents

---

1. [Single Cycle Work](#single-cycle-work)

   a) [Instruction Memory](#instruction-memory)  
   b) [Sign Extend](#sign-extend)  
   c) [ALU](#alu)  
   d) [Control Unit and Top Level](#control-unit-and-top-level)

2. [Pipelined Work](#pipelined-work)

   a) [Flip Flops](#flip-flops)  
   b) [Top Level](#top-level)  
   c) [Hazard Unit Implementation](#hazard-unit-implementation)

3. [Testing Work](#testing-work)

   a) [Hazard Unit Test](#hazard-unit-test)

4. [Conclusion](#conclusion)

---
# Single Cycle Work

---
## Instruction Memory
**[InstrMem.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/InstrMem.sv)**
- The instruction memory is ROM which has an address input to it and will output the value stored at the address.
- The values stored in the ROM are the values of the assembly code which has been compiled to machine code by the assembler in ```instructions.mem``` and this can be changed to the relevant machine code in a .mem/.hex depending on the instructions being carried out.
- ROM has to be accessed asynchronously as the ROM should update as soon as the new PC value has been passed through to it and therefore ```always_comb``` logic is used.
- Byte addressing was implemented so that each memory cell contains a byte of the instruction memory and they are accessed 4-bytes at a time to be output.

**Relevant Commits:**
[Instruction Memory Implementation Part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/b506b88f7759b5756544cff0409729dd4f80a78c), 
[Instruction Memory Implementation Part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/90447b4d2d04f346f4cf5f9cf07039cb7ed028a9), 
[Instruction Memory Implementation Part 3](https://github.com/Abeeekoala/IAC-Team-12/commit/b860a7a3c65c5e2cbf402266713b6a0b2d3f9ef7)

## Sign Extend
**[Sign_Ext.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/sign_ext.sv)**
- From Lab4 the sign_ext.sv unit was implemented by using the opcode through ```Case(Opcode)``` leaving ImmSrc redundant which I decided to make more efficient through the use of ```Case(ImmSrc)``` instead.
- By using ImmSrc this allows same opcodes which may have different requirements such as signed or unsigned extensions to be dealt with and also 
- ```Case(ImmSrc)``` will allow for more extension types to be implemented for the same opcode depending on the instruction being carried out which is not possible when using ```Case(Opcode)``` to determine what to do with the Imm.
- I implemented the i-type signed, s-type signed and b-type signed Imm extensions allowing Abraham to determine the rest of the Imm extensions depending on how he designed the ALU.
- As a result of more extension types being needed Abraham then expanded the sign_ext.sv to 3-bits and determined the other extensions based on the completed ALU design.

**Relevant Commits:**
[Sign Extend Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/b103a8a7c154b7fe3d1cb050333cb0ef64a79499)

## ALU
[ALU.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/SingleCycle/modules/ALU.sv)
- Whilst I was working on the control unit I had seen that the ALU had insufficient capabilities to implement the full RV32I base instructions and therefore I had expanded the ALUctrl signal coming from the control unit to 4 bits and added the required capabilities.
- To add these extra capabilities I added in extra cases to the 4 bit ```Case(ALUctrl)``` logic and decided what the extra cases should be based on the RISC-V 32I instruction documentation and what was required by the control unit. 
- The capabilities I added were sufficient for implementing all the instructions in combination with the control unit, however, there was an issue with the signed SLTU and ASR which was the corrected by Abraham.

**Relevant Commits:**
[ALU Implementation](https://github.com/Abeeekoala/IAC-Team-12/commit/990a034fd01777198f4e38c33748c5239b3a9f77)

## Control Unit and Top Level
[CU.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/CU.sv)
- Having worked on the control unit from the start for the single cycle implementation I defined the input and output of the control unit as follows:
	- Inputs - ```funct3```, ```opcode```, ```funct7_5``` - determines the specific instruction being carried out.
		- ```funct7_5``` can be passed through as a 1-bit input is sufficient and not the whole of funct7 is required as funct7 is either 7'h20 or 7'h00 for each given same opcode and funct3 making the other bits in funct7 redundant.
	- Inputs - ```Zero```, ```Less```, ```LessU``` - each of the following return whether their relevant comparisons found in the ALU are true or not which is required to implement the branch instructions - these later replaced through a comparator unit with Branch and Jump as detailed later.
	- Output - ```ImmSrc``` - determines the type of sign extend carried out on the Imm if required.
	- Output - ```PCSrc``` - determines if there is a normal increment to PC or a jump/branch is being executed - ```PCSrc``` was replaced later by Branch and Jump as detailed later.
	- Output - ```RegWrite/MemWrite``` - determines if the regfile or datamem are being written to respectively.
	- Output - ```ALUCtrl``` - determines which operation is being executed by the ALU.
	- Output - ```ALUSrc``` - selects what to operands to feed into the ALU - this was expanded on as detailed later.
	- Output - ```ResultSrc``` - selects which operand to pass to result which can then be written to Rd.
- Initially, the design was based on the diagram provided in Lecture 7, however, it became clear as I was implementing the control unit that further logic and design changes would be required to implement the load, store, branch, jump and u-type instructions.
- Load, store instruction related design changes:
	- For load and store I had initially tried to implement two signals one specifying the width and the other specifying msb/zero extends that would be used with MemWrite to determine what operation is carried out. However, this is a 2-bit and 1-bit signal which is just as efficient as using ```funct3``` so I reverted to a ```funct3``` method of implementing load and store.
	- The ```funct3``` method of implementing load and store is that if MemWrite is 1 then a store is being carried out otherwise a load is being carried out and the length to load/store with the msb/zero extend is determined by ```funct3``` accordingly - here the additional signal of funct3 has to be passed to the datamem.
- Branch, jump, u-type instruction related design changes:
	- Initially, I had tried to implement three new MUXs would select at the WD3 input, PCNext input 1 and PCTarget Adder's second element with ALU carrying out ```imm<<12```, however, it was clearly apparent this was the wrong approach as this would make pipelining very difficult and created too much redundancy.
	- Next the approach was to use the redundancy in sign_ext to carry out ```imm<<12``` inside the sign_ext and feed PCTarget to the ResultSrc mux adding an additional bit to that mux - this approach was far more efficient however this overlooked JALR instruction which needed ```PC = rs1 + Imm``` further changes were required.
	- However, after further discussing with Abraham we decided to change the logic so when ```PC+x``` is required that is carried out in ALU itself as the ALU was redundant in those scenarios.
	- To do this we used ```ALUSrcA``` and ```ALUSrcB```: ```ALUSrcA``` selects between ```Rs1``` and ```PC``` and ```ALUSrcB``` selects between ```rs1``` and ```ImmExt``` same as ```ALUSrc``` before.
	- Now additions to ```PC``` can be carried out in the ALU passed to result and written back, the special increments of ```PC  =+ Imm``` or ```PC = rs1 + (Imm << 12)``` can now be carried out inside the ALU as ALUout is the new ```PCTarget``` - this also removes the need for a second adder which was before calculating ```PCTarget```.
	- ```rd = PC+4``` is enabled through an extra bit in ```ResultSrc``` where the third option is ```PCPlus4``` which passes it to result which can then be written to ```rd```, ```rd = Imm << 12``` is enabled through passing through just ```operand2``` from the ALU to result which can be written to rd.
	- At first the  the branch instructions ```Zero```, ```Less``` and ```LessU``` were initially designed by Abraham which in the ALU would carry out all the comparison types and the required comparison result can be accessed by the control unit, however, now through the use of ```ALUSrcA``` and ```ALUSrcB``` we can use a new component.
	- Abraham and I decided we should use a comparator unit which would get passed ```funct3``` and therefore determine which comparison to carry out and return 0 or 1 depending on if the condition was met.
		- This was to make sure that the design would be compatible for pipelining later on as otherwise the operation overall is split between decode and execute stages which are separated by a flip flop so by the time ```Zero```, ```Less``` and ```LessU``` return from the ALU the next instruction is already being processed which is completely different rendering the branch logic useless.
	- This combined with some external logic using ```Branch``` and ```Jump``` determines if ```PCSrc``` is 1 or 0 through ```PCSrc = (Jump) | (Branch & Comparator)``` - further details can be found in Abraham's personal statement.
		- ```Branch``` and ```Jump``` are 1-bit signals which go to 1 if the instruction is a branch or jump instruction respectively.
		- Comparator is the output of the comparator returning whether the comparison selected by ```funct3``` returned true or false.
	- A separate comparator unit is required so that other branch and jump instructions can be carried out ```rs1```/```rs2``` may not always match ```SrcA```/```SrcB``` for the ALU as in the branch instructions but it is always ```rs1``` and ```rs2``` which are being compared for branch instruction.
- Implementing all these changes gave this final [design](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCVsingle_cycle_final.png) giving minimal redundancy whilst implementing all the full RISC-V 32I instruction set.

**Relevant Commits:**
[CU lab4](https://github.com/Abeeekoala/IAC-Team-12/commit/b506b88f7759b5756544cff0409729dd4f80a78c), 
[CU structural expansion for full RV32I part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/abbe81c48f9d5e8554193283aa25455b013559f7), 
[CU structural expansion for full RV32I part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/a3fe5cd501141c9e7df739b66b952b2ed89e8a19), 
[Initial approach part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/44b64bba4add87c036b685a4f20d5bff0ac3dd2b), 
[Initial approach part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/5c000fd5c98d64450efedf09105834919e1c96a2), 
[Initial approach part 3](https://github.com/Abeeekoala/IAC-Team-12/commit/560825419bd992ca714c1872c065624e15c1f389), 
[Initial approach part 4](https://github.com/Abeeekoala/IAC-Team-12/commit/1c02a4eba6ffe36256f3d983f05cab05e6567a8c), 
[Top for initial approach adjustments](https://github.com/Abeeekoala/IAC-Team-12/commit/ef970687f34cd3ec25ada42bb31c7a7134c64ff3), 
[Top and datapath Corrected branch/jump logic approach part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/55db9d01f8f7fb1c374e4ff72370abfdc7073627), 
[Top and datapath for corrected branch/jump logic approach part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/01dacff5090e9f0ca77a48c43ef18c4d8aeccb0a), 
[Control Unit changes for corrected branch/jump logic approach](https://github.com/Abeeekoala/IAC-Team-12/commit/49fb328c3a4c283633a69ada0af418f7246cb84c)

---
# Pipelined work

---
## Flip Flops
[ff1.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff1.sv), 
[ff2.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff2.sv), 
[ff3.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff3.sv), 
[ff4.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/modules/ff4.sv), 
- The flip flops are registers which will be placed between each of the stages in the pipeline and allow different instructions to be processed at different stages of the pipeline.
- The stages of the pipeline are fetch, decode, execute, memory and writeback where the flipflops act as the interface between the different stages.
	- The main aim behind pipelining is to allow different areas of the CPU to process different instructions and therefore increase the clock frequency of the CPU.
- Shreeya had provided the basic flip flops required for pipelining, however, this was based on the design provided in Lecture 8 and therefore required adjustments to fit the [design without the hazard unit](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCV_pipelined.png) that I had decided upon.
- To make these changes I added in the new input and outputs following the existing always_ff clocked structure and following the naming structure as set out in the diagram.

**Relevant Commits:**
[Adjusting flipflops part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/ca8ba72406c514f62a6e3da46216f767b1fcff96), 
[Adjusting flipflops part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/07b332b0c90ce36c5a3507abadeb9d7d487532be)

## Top Level
[fetch.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/fetch.sv), 
[decode.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/decode.sv), 
[execute.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/execute.sv), 
[memory.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/memory.sv), 
[writeback.sv](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/writeback.sv), 
[top.sv pipelined](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/top.sv)
- The top level in the single cycle was broken down into PC, control path and datapath which is not suitable for pipelining as this crosses multiple pipeline stages.
- Therefore, I decided to break down top into fetch, decode, execute, memory and writeback stages
- Each of stages would take the inputs from their respective prior stages or other stages and give the output, from giving the flipflop the appropriate inputs, to the next stage.
- This current [pipelined design without hazard unit](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCV_pipelined.png) worked, however, does not consider data and control hazards and relies on the programmer to deal with such hazards.
- I further expanded on this design to deal with control and data hazards by implementing forwarding and the Hazard Unit which was designed by Abraham and Shreeya as detailed in the next section.

 **Relevant Commits:**
[Pipelined top part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/1f885370f2057c63a87a934932f9d18324abf7a4), 
[Pipelined top part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/4d6ebd37a093b46a80756ec88bdb7710fe3f7e71), 
[Pipelined top issue fix](https://github.com/Abeeekoala/IAC-Team-12/commit/d2a427133a5b2896e6b56eb0a11d980f1a9e2a03)

## Hazard Unit Implementation
[top.sv pipelined](https://github.com/Abeeekoala/IAC-Team-12/blob/main/modules/top.sv)
- As the two main problems with pipelining is the control and data hazards which must be dealt with for a functioning CPU the main ways of dealing with these hazards are set out as follows:
	- Data hazards - forward the data required to the relevant ALU operand if it is available and was used in a prior instruction or stall until that operand can be forwarded.
	- Control hazards - flush the incorrect instructions which were being processed before the jump or branch was decided.
- Implementing a mux before the ```ResultSrcA``` and before ```ResultSrcB``` allows forwarding to be implemented because forwarding is required as determined by ForwardA and ForwardB respectively then a memory or writeback stage forward can be executed.
	- However, if datamem is what is writing to the register then there must also be an accompanying stall with the forwarding as ```ResultW``` is being accessed in that case.
- The stall and flush were initially attempted to be implemented through adjusting the register logic themselves as decided by Abraham which would deal with ```stall``` and ```flush``` in the flip flops and ```PCreg``` itself.
- This was the design that I had therefore implemented, however, during testing it was apparent that the control hazards were not being dealt with correctly and so flush and stall was reimplemented by Abraham through the control unit according to his new [fully pipelined design](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCV_pipelined_hazard_final.png) - further details of what changes he made to my initial implementation of his original design can be found on his personal statement.

**Relevant Commits:**
[Pipelined with hazard unit part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/599b6b8c0a58f5e7a9d087d1e6c20102dc674bf0), 
[Pipelined with hazard unit part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/2168e83a110f93fdbc62c158400a5ed9937d8b40), 
[Pipelined with hazard unit part 3](https://github.com/Abeeekoala/IAC-Team-12/commit/4b91a1928d8accde1d8cfa761d565519e7d51f6a)

---
# Testing Work

---
## Hazard Unit Test
[hazardunit_tb.cpp](https://github.com/Abeeekoala/IAC-Team-12/blob/Pipelinedw/Cache/tb/tests/hazardunit_tb.cpp)
- As I had not designed the hazard unit myself or written any tests to further improve my understanding of the hazard unit and gain a complete understanding of pipelining I had decided to write a unit test for the hazard unit.
- The main tests I wrote serve the purpose of testing for:
	- Forwarding - that both ForwardA and ForwardB are taking the correct values when a data hazard occurs.
	- Stalling - that a stall is being implemented when there is a data memory related data hazard such that forwarding is occurring from ResultW.
	- Flushing - when a reset has been initialised and when a jump/branch is being executed.
- The existing [design with pipelining and cache](https://github.com/Abeeekoala/IAC-Team-12/blob/main/images/RISCV_pipelined_cache_final.png) that was implemented successfully passed all the tests in the hazard unit testbench.

**Relevant Commits:**
[Hazard unit test bench](https://github.com/Abeeekoala/IAC-Team-12/commit/33c95100c6f1666f0f923dda4f5213ae6ccd2631), 
[Error fixes part 1](https://github.com/Abeeekoala/IAC-Team-12/commit/54eaa758dfeeec3e0fcce3857d1c753800fd7f39), 
[Error fixes part 2](https://github.com/Abeeekoala/IAC-Team-12/commit/2fac2326a419fa1496394db83d8b571071388a57)

---
# Conclusion

---
In conclusion, I found taking part in this project very interesting and useful towards developing my understand of IAC despite the challenges during design I found the process of designing and making designs more efficient was incredibly enjoyable. If I were to do this project again I would perhaps also involve myself in the work of the cache, however, as I felt my understanding after the lectures of pipelining was the weakest carrying out the most amount of work in pipelining in this project was incredibly helpful. Also, taking up key components like control unit and top level design helped give me a complete and solid understanding of the whole CPU which I would have otherwise not have been able to gain.
