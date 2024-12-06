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
    input logic [31:0]      rs1D,
    input logic [31:0]      rs2D,
    input logic [31:0]      ImmExtD,
    input logic [31:0]      PCD,
    input logic [2:0]       funct3D,
    input logic [4:0]       RdD,
    input logic [31:0]      inc_PCD,
    input logic             Stall,
    input logic             Flush,

    output logic             JumpE,
    output logic             BranchE,
    output logic             RegWriteE,
    output logic [1:0]       ResultSrcE,
    output logic             MemWriteE,
    output logic [3:0]       ALUCtrlE,
    output logic             ALUSrcAE,
    output logic             ALUSrcBE,
    output logic [31:0]      rs1E,
    output logic [31:0]      rs2E,
    output logic [31:0]      ImmExtE,
    output logic [31:0]      PCE,
    output logic [2:0]       funct3E,
    output logic [4:0]       RdE,
    output logic [31:0]      inc_PCE
);

always_ff @(posedge clk) begin
    if (!Stall) begin
        JumpE <= JumpD;
        BranchE <= BranchD;
        RegWriteE <= (Flush) ? 1'b0 : RegWriteD; // Ensure that regfile & memory are unchanged when Flushed
        ResultSrcE <= ResultSrcD;
        MemWriteE <= (Flush) ? 1'b0 : MemWriteD; // Ensure that regfile & memory are unchanged when Flushed
        ALUCtrlE <= ALUCtrlD;
        ALUSrcAE <= ALUSrcAD;
        ALUSrcBE <= ALUSrcBD;
        rs1E <= rs1D;
        rs2E <= rs2D;
        ImmExtE <= ImmExtD;
        PCE <= PCD;
        funct3E <= funct3D;
        RdE <= RdD;
        inc_PCE <= inc_PCD;
    end
end

endmodule
