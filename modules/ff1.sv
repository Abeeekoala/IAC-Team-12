module ff1 (
    input logic             clk,
    input logic [31:0]      RD,
    input logic [31:0]      PC,
    input logic [31:0]      inc_PC,
    input logic [31:0]      InstrMem,
    output logic [31:0]     PCD,
    output logic [31:0]     PCPlus4D
);

always_ff @ (posedge clk)
    begin  
        InstrMem <= RD;
        PCD <= PC;
        PCPlus4D <= inc_PC;
    end

endmodule
