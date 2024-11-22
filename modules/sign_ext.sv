module sign_ext (
    input   [11:0]          Imm,
    input                   ImmSrc,
    output  [31:0]          ImmOp
);

always_comb
    if (ImmSrc)
        Imm32 = {{16{Imm16[15]}}, Imm16};       //sign extension of 15th bit to upper bits
    else
        Imm32 = {16'b0, Imm16};                 //else fill upper bits with 0s
    

    
endmodule
