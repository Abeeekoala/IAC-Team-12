module sign_ext (
    input   [11:0]          Imm,
    input                   ImmSrc,
    output  [31:0]          ImmOp
);

always_comb
    if (ImmSrc)
        ImmOp = {{20{Imm[11]}}, Imm};       //sign extension of 15th bit to upper bits
    else
        ImmOp = {20'b0, Imm};                 //else fill upper bits with 0s
    

    
endmodule
