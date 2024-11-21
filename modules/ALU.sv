module ALU #(
    DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0]   ALUop1,
    input logic [DATA_WIDTH-1:0]     ALUop2,
    input logic [2:0]    ALUctrl,
    output logic [DATA_WIDTH-1:0]    ALUout,
    output logic    eq

);

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
