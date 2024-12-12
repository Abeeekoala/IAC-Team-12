module sign_ext (
    input   logic [31:7]      ImmA,
    input   logic [31:7]      ImmB,
    input   logic [5:0]       ImmSrc,
    output  logic [31:0]      ImmExtA,
    output  logic [31:0]      ImmExtB
);

//Memo:
//I-type: Instr[31:20] = imm[11:0]; need signed and unsigned extension
//S-type: Instr[31:25] = imm[11:5], Instr[11:7] = imm[4:0]; always signed
//B-type: Instr[31:25] = imm[12|10:5], Instr[11:7] = imm[4:1|11], imm[0] = 1'b0; always signed
//U-tpe: Instr[31:12] = imm[31:12], imm[11:0] = 12'h000; 
//J-tpe: Instr[31:12] = imm[20|10:1|11|19:12]; always signed
//Immsrc cases:
//      3'b000: I-type signed
//      3'b001: I-type unsigned
//      3'b010: S-type
//      3'b011: B-type
//      3'b100: U-type
//      3'b101: J-type
always_comb begin
    case (ImmSrc)
        // I-type signed
        6'b000000: begin
        ImmExtA = {{20{ImmA[31]}}, ImmA[31:20]};
        ImmExtB = {{20{ImmB[31]}}, ImmB[31:20]};
        end

        // I-type unsigned
        6'b000001: begin
        ImmExtA = {{20{1'b0}}, ImmA[31:20]};
        ImmExtB = {{20{1'b0}}, ImmB[31:20]};
        end

        // S-type
        6'b000010:begin
        ImmExtA = {{20{ImmA[31]}}, ImmA[31:25], ImmA[11:7]};
        ImmExtB = {{20{ImmB[31]}}, ImmB[31:25], ImmB[11:7]};
        end

        // B-type
        6'b000011: begin 
        ImmExtA = {{20{ImmA[31]}}, ImmA[7], ImmA[30:25], ImmA[11:8], 1'b0};
        ImmExtB = {{20{ImmB[31]}}, ImmB[7], ImmB[30:25], ImmB[11:8], 1'b0};
        end

        // U-type
        6'b000100:begin
        ImmExtA = {ImmA[31:12], {12{1'b0}}};
        ImmExtB = {ImmB[31:12], {12{1'b0}}};
        end

        // J-type
        6'b000101: begin
        ImmExtA = {{11{ImmA[31]}}, ImmA[31], ImmA[19:12], ImmA[20], ImmA[30:21], 1'b0};
        ImmExtB = {{11{ImmB[31]}}, ImmB[31], ImmB[19:12], ImmB[20], ImmB[30:21], 1'b0};
        end

        // Custom case: different operations for A and B
        6'b010000: begin
            // Apply one type for ImmA and another for ImmB
            ImmExtA = {{20{ImmA[31]}}, ImmA[31:20]};       // I-type signed for ImmA
            ImmExtB = {{20{ImmB[31]}}, ImmB[31:25], ImmB[11:7]}; // S-type for ImmB
        end

        default: begin
            ImmExtA = 32'b0;
            ImmExtB = 32'b0;
        end
    endcase
end

endmodule
