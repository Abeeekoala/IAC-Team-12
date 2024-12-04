module ff2 (
    input logic             clk,
    input logic [31:0]      RD1D,
    input logic [31:0]      RD2D,
    input logic [2:0]       ImmExtD,
    input logic [31:0]      PCPlus4D,
    input logic [2:0]       funct3D,
    input logic             PCSrcD,
    input logic             MemWriteD,
    input logic             RegWriteD,
    input logic [3:0]       ALUctrlD,
    input logic             ALUSrcAD,
    input logic             ALUSrcBD,
    input logic [1:0]       ResultSrcD,
    input logic [5:0]      RdD,
    
    output logic [31:0]      RD1E,
    output logic [31:0]      RD2E,
    output logic [2:0]       ImmExtE,
    output logic [31:0]      PCPlus4E,
    output logic [2:0]       funct3E,
    output logic             PCSrcE,
    output logic             MemWriteE,
    output logic             RegWriteE,
    output logic [3:0]       ALUctrlE,
    output logic             ALUSrcAE,
    output logic             ALUSrcBE,
    output logic [1:0]       ResultSrcE,
    output logic [5:0]       RdE
);

always_ff @(posedge clk) begin
    RD1E <= RD1D;
    RD2E <= RD2D;
    ImmExtE <= ImmExtD;
    PCPlus4E <= PCPlus4D;
    funct3E <= funct3D;
    PCSrcE <= PCSrcD;
    MemWriteE <= MemWriteD;
    RegWriteE <= RegWriteD;
    ALUctrlE <= ALUctrlD;
    ALUSrcAE <= ALUSrcAD;
    ALUSrcBE <= ALUSrcBD;
    ResultSrcE <= ResultSrcD;
    RdE <= RdD;
end

endmodule
