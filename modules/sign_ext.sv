module sign_ext (
    input   logic [31:0]      Instr,
    input   logic [1:0]       ImmSrc,
    output  logic [31:0]      ImmExt
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
        3'b000: ImmExt = {{20{Instr[31]}}, Instr[31:20]};

        // I-type unsigned
        3'b001: ImmExt = {{20{1'b0}}, Instr[31:20]};

        // S-type
        3'b010: ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};

        // B-type
        3'b011: ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};

        // U-type
        3'b100: ImmExt = {Instr[31:12], {12{1'b0}}};

        // J-type
        3'b101: ImmExt = {{12{Instr[31]}}, Instr[31], Instr[19:12], Instr[20], Instr[30:21], 1'b0};

        default: begin
            ImmExt = 32'b0;
        end
    endcase
end
    
endmodule
