module datapath #(
        parameter A_WIDTH = 5,
                  D_WIDTH = 32

)(
    input logic         clk,
    input logic         regWrite,
    output logic        a0,
    input logic         ALUop1,
    input logic         ALUctrl,
    output logic        ALUout,
    output logic        eq,
    input logic         rs1,
    input logic         rs2,
    input logic         rd,
    input logic         ALUsrc
);

    logic     regOp2;
    logic     ALUop2;
    logic     ALUop1;

ALU ALU (
    .ALUop1 (ALUop1),
    .ALUop2 (ALUop2),
    .ALUctrl (ALUctrl),
    .eq (eq)
    .ALUout (ALUout)
);

regfile regfile (
    .clk (clk),
    .ad1 (rs1),
    .ad2 (rs2),
    .ad3 (rd),
    .we3 (regWrite),
    .wd3 (ALUout),
    .a0 (a0),
    .rd1 (ALUop1),
    .rd2 (regOp2),
);

ALUmux ALUmux (
    .in0 (clk),
    .sel (address),
    .in1 (tick),
    .out (dout)
);

endmodule 
