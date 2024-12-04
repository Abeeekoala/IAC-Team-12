module ALU #(
    DATA_WIDTH = 32
) (
    input logic     [DATA_WIDTH-1:0]    ALUop1,
    input logic     [DATA_WIDTH-1:0]    ALUop2,
    input logic     [3:0]               ALUctrl,
    output logic    [DATA_WIDTH-1:0]    ALUout   
);

always_comb begin
    case(ALUctrl)
        4'b0000: ALUout = ALUop1 + ALUop2;          // ADD
        4'b0001: ALUout = ALUop1 - ALUop2;          // SUB
        4'b0010: ALUout = ALUop1 & ALUop2;          // AND
        4'b0011: ALUout = ALUop1 | ALUop2;          // OR           
        4'b0100: ALUout = ALUop1 ^ ALUop2;          // XOR
        4'b0101: ALUout = ALUop1 << ALUop2;         // LSL
        4'b0110: ALUout = ALUop1 >> ALUop2;         // LSR    
        4'b0111: ALUout = ALUop1 >>> ALUop2;        // ASR for register
        4'b1000: ALUout = ALUop1 >>> ALUop2[4:0];    // ASR for Imm
        4'b1001: ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? 32'd1 : 32'd0; // set less than
        4'b1010: ALUout = (ALUop1 < ALUop2) ? 32'd1 : 32'd0; // set less than (U)
        4'b1011: ALUout = ALUop2;
        default: begin
            ALUout = 32'b0;
        end
    endcase

end

endmodule
