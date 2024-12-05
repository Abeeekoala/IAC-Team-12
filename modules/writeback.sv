module writeback(
    input logic [1:0]               ResultSrcW,
    input logic [31:0]              ALUoutW,
    input logic [31:0]              ReadDataW,
    input logic [31:0]              inc_PCW,
    output logic [31:0]             ResultW
);

mux4 Result_mux(
    .in0                            (ALUoutW),
    .in1                            (ReadDataW),
    .in2                            (inc_PCW),
    .in3                            (32'h0000),
    .sel                            (ResultSrcW),
    .out                            (ResultW)
);

endmodule
