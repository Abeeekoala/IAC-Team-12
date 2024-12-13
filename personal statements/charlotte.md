- Name: Charlotte Maxwell
- CID : 02391539
- Github username: SharlotteMaxswell(main) + Shartlottesx -- mild email confusion

# Summary of Project Contributions:

**1. Single Cycle Processor:**
-	Developed the initial [ALU](https://github.com/Abeeekoala/IAC-Team-12/compare/59e54de5fe5eb7e57bbc3a8620dda4d56ddc0006...7db364e4a8f3db42ad5f8fefb383a98c8bd2936a) and [Regfile](https://github.com/Abeeekoala/IAC-Team-12/compare/d1c2960d947939d752ef325d64ce5ca7c6346ec7...e406d774e596a85691391954dcc78c0bfe51a7a8) (Lab4) and DataMemory modules. [Relevant Commit](https://github.com/Abeeekoala/IAC-Team-12/compare/d1c2960d947939d752ef325d64ce5ca7c6346ec7...e406d774e596a85691391954dcc78c0bfe51a7a8)
-	Implemented aspects of the control unit functionality, specifically the Load and Store instructions within the DataMemory module.
-	Created the datapath, and it's constituent components, and top-level file containing the integration logic for the processor. [Relevant Commit](https://github.com/Abeeekoala/IAC-Team-12/compare/58a4e07e6a51d0d50c7cf1ff4758921472b0aabe...5a30c64055e53f243a995f5d7e4c503c6633bc73)

 **2.	Cache Design:**
- Initiated the design of a Direct-Mapped Cache module.
- Designed and implemented a Two-Way Set-Associative Cache. [Relevant Commit](https://github.com/Abeeekoala/IAC-Team-12/compare/1cfc10df4084978b2fd85174123ef32d3d36f3f1...2dfd64eaca9f6badea25ad6f8c942b7c545fc03b)
- Created a hierarchical memory system by developing L1 and L2 cache modules, incorporating spatial locality logic in the L2 cache aiming to improve the hit rate. [Relevant Commit](https://github.com/Abeeekoala/IAC-Team-12/compare/79cb206cf9cab368370618db3f8eabe7ecc575eb...c75a4ac9faaf226b9a99b6c788056dd9bf376315)

## Single Cycle:
In the single-cycle processor design, I focused on memory handling and memory instructions. My contributions included building the ALU in an early lab assignment (Lab 4). Initially, the ALU had limited functionality but was later expanded by Shravan to support the full RISC-V instruction set.
```systemverilog
always_comb begin
    case(ALUctrl)
    3'b000: ALUout = ALUop1 + ALUop2;
    3'b001: ALUout = ALUop1 - ALUop2;
    3'b010: ALUout = ALUop1 & ALUop2;
    3'b011: ALUout = ALUop1 | ALUop2;
    // 101: ALUout = SLT function 
    default: ALUout - 32'b0;
    endcase

    eq = (ALUop1 == ALUop2);
end

endmodule
```
For the DataMemory module, I implemented the logic for handling Load and Store instructions by passing the func3 control signal into the module. 
```systemverilog
 always_comb begin
        if (opcode == 7'b0000011) begin // Load instructions
            case (funct3)
                3'b000: read_data = {{24{mem[rs1 + imm][7]}}, mem[rs1 + imm][7:0]};  // lb
                3'b001: read_data = {{16{mem[rs1 + imm][15]}}, mem[rs1 + imm][15:0]}; // lh
                3'b010: read_data = mem[rs1 + imm];                                   // lw
                3'b100: read_data = {24'b0, mem[rs1 + imm][7:0]};                     // lbu
                3'b101: read_data = {16'b0, mem[rs1 + imm][15:0]};                    // lhu
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end
```
Initially, I incorrectly attempted to compute the memory address within the module itself. After recognizing this issue, I adjusted the design to accept a pre-computed memory address (A) as input, streamlining the module’s operation. 
I also created the datapath module, containing the ALU ALU mux Datamemory and another Mux, which acted as a part of top.sv to help implement the overall logic of the processor whilst simplifying the logic in top.sv and increasing readabiltiy.

## Cache: 
### 2-way set
I began designing a Direct-Mapped Cache module but shifted my focus to a Two-Way Set-Associative Cache to prioritize its implementation. My design was guided by class lecture notes and the recommended textbook. The most challanging part of this was dealing with Cache writeback logic and I found this quite confusing to get my head round and I eneded up drastically simplifying the datamemory module, this resulted in quite a complex cache file though as the instruction procesing which was previously handled in datamemory was now handled in cache. Initially, I instantiated DataMemory directly within the cache file, but this was later refined by creating a dedicated Memory Top module to house all memory components by Shreeya.
![WhatsApp Image 2024-12-06 at 13 52 31_d64e2fe9](https://github.com/user-attachments/assets/119e061b-1ee0-435e-a7f7-713fa51674af)
This is the inital diagram which i designed to implement the cache logic. 
### L1 L2
To improve performance and align with hierarchical memory design principles, I started the development of a bigger L2 cache. This cache was designed to exploit spatial locality and improve hit rates compared to the initial L1-only setup. Implementing this required creating a robust replacement and eviction policy to handle the writeback process from L1 to L2 and, ultimately, to main memory. This aspect of the design was particularly challenging and required adapting to statemachine logic to coherently implement the different states of the memory module.
```systemverilog     // State machine states
    typedef enum logic [2:0] {
        IDLE, CHECK_HIT, FETCH_FROM_L2, FETCH_FROM_MEMORY, WRITE_TO_L2
    } state_t;
```

![WhatsApp Image 2024-12-11 at 01 50 46_290c75ea](https://github.com/user-attachments/assets/9c0aeaf6-5a59-4e00-bb27-3db7623e392c)



## What I have learnt:
I found this project incredibly useful to apply what we had learnt from lectures and consolidate that knowledge, in fact I feel this helped me to fully grasp and understand the content. Before this project I had not worked collaboratively using GitHub before so there was a slight learning curve with branches git push and pull where my teammates were incredibly patient and helped explain everything to me. Our teamwork and communication was fantastic throughout the project and we set achievable timelines which we stuck to allowing us to explore further opportunities for learning and growth such as implementing the L1 L2 cache.
### Mistakes I have made:
As I was primarily responsible for memory-related components, my learning and focus were concentrated in that area. If I were to undertake the project again, I would:
-	Take on responsibilities related to pipelining, as I had limited involvement in this aspect.
-	Contribute more to writing testbench code and debugging to increase my overall technical contributions.

Overall, I believe we worked effectively as a team and successfully achieved our project goals. While some modules were challenging to work on collaboratively, any imbalance in workload was quickly addressed, ensuring consistent progress.




