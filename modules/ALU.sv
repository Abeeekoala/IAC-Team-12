module ALU #(
    DATA_WIDTH = 32
) (
    input logic     [DATA_WIDTH-1:0]    ALUop1,
    input logic     [DATA_WIDTH-1:0]    ALUop2,
    input logic     [3:0]               ALUctrl,
    output logic    [DATA_WIDTH-1:0]    ALUout,
    output logic                        Zero,       
    output logic                        Comparator          //whether ALUop1 and 2 are equal or not
                                                            // 00 - equal, 01 - op1 > op2, 10 - op1 < op2

);

always_comb begin
    case(ALUctrl)
    4'b0000: ALUout = ALUop1 + ALUop2; // ADD
    4'b0001: ALUout = ALUop1 - ALUop2; // SUB
    4'b0010: ALUout = ALUop1 & ALUop2; // AND
    4'b0011: ALUout = ALUop1 | ALUop2; // OR
    4'b0100: ALUout = ALUop1 ^ ALUop2; // XOR
    4'b0101: ALUout = ALUop1 << ALUop2; // LSL
    4'b0110: ALUout = ALUop1 >> ALUop2; // LSR
    4'b0111: ALUout = ALUop1 >>> ALUop2; // ASR
    4'b1000: ALUout = (ALUop1 < ALUop2) ? 1 : 0; // SLT
    4'b1001: ALUout = ALUop2 << 12; // LUI
    default: ALUout = 32'b0;
    endcase

    //determine the comparison result for zero
    if (ALUop1 == ALUop2)
        Zero = 1'b0; //equal
    else if(ALUop1 > ALUop2)
        Comparator = 1'b0;
        Zero = 1'b1;
    else
        Comparator = 1'b10; //op1 < op2
        Zero = 1'b1;
end

endmodule
