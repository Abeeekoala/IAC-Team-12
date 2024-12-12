module CU (
    input logic [2:0]       funct3A,
    input logic [2:0]       funct3B,
    input logic [6:0]       opA,
    input logic [6:0]       opB,
    input logic             funct7_5A,
    input logic             funct7_5B,
    output logic [5:0]      ImmSrcA,
    output logic [5:0]      ImmSrcB,
    output logic [1:0]      MemWrite,
    output logic            RegWriteA,
    output logic            RegWriteB,
    output logic [3:0]      ALUctrlA,
    output logic [3:0]      ALUctrlB,
    output logic            ALUSrcA,
    output logic            ALUSrcB,
    output logic [1:0]      ResultSrcA,
    output logic [1:0]      ResultSrcB
);

always_comb begin
    // Initialize all control signals to their default states for both instruction slots
    ImmSrcA = 3'b000;
    ImmSrcB = 3'b000;
    ResultSrcA = 2'b00;
    ResultSrcB = 2'b00;
    ALUSrcA = 1'b0;
    ALUSrcB = 1'b0;
    ALUctrlA = 4'b0000;
    ALUctrlB = 4'b0000;
    RegWriteA = 1'b0;
    RegWriteB = 1'b0;
    MemWriteA = 1'b0;
    MemWriteB = 1'b0;
    BranchA = 1'b0;
    BranchB = 1'b0;
    JumpA = 1'b0;
    JumpB = 1'b0;


    // Process instruction A
        case(opA)
            // r-type instructions
            7'b0110011: begin
                RegWriteA = 1'b1;
                case(funct3A)
                    3'b000: ALUctrlA = funct7_5A ? 4'b0001 : 4'b0000; // ADD or SUB
                    3'b100: ALUctrlA = 4'b0100; // XOR
                    3'b110: ALUctrlA = 4'b0011; // OR
                    3'b111: ALUctrlA = 4'b0010; // AND
                    3'b001: ALUctrlA = 4'b0101; // SLL
                    3'b101: ALUctrlA = funct7_5A ? 4'b0111 : 4'b0110; // SRL or SRA
                    3'b010: ALUctrlA = 4'b1001; // SLT
                    3'b011: ALUctrlA = 4'b1010; // SLTU
                endcase
            end

            // i-type instructions
            7'b0010011: begin
                RegWriteA = 1'b1;
                ALUSrcA = 1'b1;
                case(funct3A)
                    3'b000: ALUctrlA = 4'b0000; // ADDI
                    3'b100: ALUctrlA = 4'b0100; // XORI
                    3'b110: ALUctrlA = 4'b0011; // ORI
                    3'b111: ALUctrlA = 4'b0010; // ANDI
                    3'b001: if (!funct7_5A) ALUctrlA = 4'b0101; // SLLI
                    3'b101: ALUctrlA = funct7_5A ? 4'b1000 : 4'b0110; // SRLI or SRAI
                    3'b010: ALUctrlA = 4'b1001; // SLTI
                    3'b011: ALUctrlA = 4'b1010; // SLTIU
                endcase
            end
        endcase
    

    // Process instruction B
        case(opB)
            // r-type instructions
            7'b0110011: begin
                RegWriteB = 1'b1;
                case(funct3B)
                    3'b000: ALUctrlB = funct7_5B ? 4'b0001 : 4'b0000; // ADD or SUB
                    3'b100: ALUctrlB = 4'b0100; // XOR
                    3'b110: ALUctrlB = 4'b0011; // OR
                    3'b111: ALUctrlB = 4'b0010; // AND
                    3'b001: ALUctrlB = 4'b0101; // SLL
                    3'b101: ALUctrlB = funct7_5B ? 4'b0111 : 4'b0110; // SRL or SRA
                    3'b010: ALUctrlB = 4'b1001; // SLT
                    3'b011: ALUctrlB = 4'b1010; // SLTU
                endcase
            end

            // i-type instructions
            7'b0010011: begin
                RegWriteB = 1'b1;
                ALUSrcB = 1'b1;
                case(funct3B)
                    3'b000: ALUctrlB = 4'b0000; // ADDI
                    3'b100: ALUctrlB = 4'b0100; // XORI
                    3'b110: ALUctrlB = 4'b0011; // ORI
                    3'b111: ALUctrlB = 4'b0010; // ANDI
                    3'b001: if (!funct7_5B) ALUctrlB = 4'b0101; // SLLI
                    3'b101: ALUctrlB = funct7_5B ? 4'b1000 : 4'b0110; // SRLI or SRAI
                    3'b010: ALUctrlB = 4'b1001; // SLTI
                    3'b011: ALUctrlB = 4'b1010; // SLTIU
                endcase
            end
        endcase
end

endmodule
