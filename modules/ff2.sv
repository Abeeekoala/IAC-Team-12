module ff2 (
    input logic             clk,
    input logic             JumpD,
    input logic             BranchD,
    input logic             RegWriteD,
    input logic [1:0]       ResultSrcD,
    input logic             MemWriteD,
    input logic [3:0]       ALUCtrlD,
    input logic             ALUSrcAD,
    input logic             ALUSrcBD,
    input logic [31:0]      RD1D,
    input logic [31:0]      RD2D,
    input logic [31:0]      ImmExtD,
    input logic [31:0]      PCD,
    input logic [2:0]       funct3D,
    input logic [4:0]       RdD,
    input logic [4:0]       Rs1D,
    input logic [4:0]       Rs2D,
    input logic [31:0]      inc_PCD,
    input logic             stall_cache,

    output logic             JumpE,
    output logic             BranchE,
    output logic             RegWriteE,
    output logic [1:0]       ResultSrcE,
    output logic             MemWriteE,
    output logic [3:0]       ALUCtrlE,
    output logic             ALUSrcAE,
    output logic             ALUSrcBE,
    output logic [31:0]      RD1E,
    output logic [31:0]      RD2E,
    output logic [31:0]      ImmExtE,
    output logic [31:0]      PCE,
    output logic [2:0]       funct3E,
    output logic [4:0]       RdE,
    output logic [4:0]       Rs1E,
    output logic [4:0]       Rs2E,
    output logic [31:0]      inc_PCE
);

always_ff @(posedge clk) begin
    if (!stall_cache) begin
        JumpE <= JumpD;
        BranchE <= BranchD;
        RegWriteE <= RegWriteD; 
        ResultSrcE <= ResultSrcD;
        MemWriteE <= MemWriteD;
        ALUCtrlE <= ALUCtrlD;
        ALUSrcAE <= ALUSrcAD;
        ALUSrcBE <= ALUSrcBD;
        RD1E <= RD1D;
        RD2E <= RD2D;
        ImmExtE <= ImmExtD;
        PCE <= PCD;
        funct3E <= funct3D;
        RdE <= RdD;
        Rs1E <= Rs1D;
        Rs2E <= Rs2D;
        inc_PCE <= inc_PCD;
    end
end

endmodule
