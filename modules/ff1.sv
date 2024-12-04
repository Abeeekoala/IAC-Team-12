module ff1 (
    input logic             clk,
    input logic [31:0]      RD,
    input logic [31:0]      PCF,
    input logic [31:0]      inc_PC,
    output logic [31:0]      Instr,
    output logic [31:0]     PCD,
    output logic [31:0]     PCPlus4D
);

always_ff @ (posedge clk)
    begin
        Instr <= RD;
        PCD <= PCF;
        PCPlus4D <= inc_PC;
    end

endmodule
