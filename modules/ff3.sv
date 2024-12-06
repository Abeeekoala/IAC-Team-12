module ff3 (
    input logic             clk,
    input logic             RegWriteE,
    input logic [1:0]       ResultSrcE,
    input logic             MemWriteE,
    input logic [31:0]      ALUoutE,
    input logic [2:0]       funct3E,
    input logic [4:0]       RdE,
    input logic [31:0]      inc_PCE,
    input logic [31:0]      rs2E,

    output logic            RegWriteM,
    output logic [1:0]      ResultSrcM,
    output logic            MemWriteM,
    output logic [31:0]     ALUoutM,
    output logic [2:0]      funct3M,
    output logic [4:0]      RdM,
    output logic [31:0]     inc_PCM,
    output logic [31:0]     rs2M
);

always_ff @ (posedge clk)
    begin
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
        ALUoutM <= ALUoutE;
        funct3M <= funct3E;
        RdM <= RdE;
        inc_PCM <= inc_PCE;
        rs2M <= rs2E;
    end

endmodule
