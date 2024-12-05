module execute (
    input logic             JumpE,
    input logic             BranchE,
    input logic             RegWriteE,
    input logic [1:0]       ResultSrcE,
    input logic             MemWriteE,
    input logic [3:0]       ALUCtrlE,
    input logic             ALUSrcAE,
    input logic             ALUSrcBE,
    input logic [31:0]      rs1E,
    input logic [31:0]      rs2E,
    input logic [31:0]      ImmExtE,
    input logic [31:0]      PCE,
    input logic [2:0]       funct3E,
    input logic [4:0]       RdE,
    input logic [31:0]      inc_PCE,
    output logic [31:0]     PCTarget,
    output logic            PCSrc,
    output logic            RegWriteM,
    output logic [1:0]      ResultSrcM,
    output logic            MemWriteM,
    output logic [31:0]     ALUoutM,
    output logic [2:0]      funct3M,
    output logic [4:0]      RdM,
    output logic [31:0]     inc_PCM
);

logic                   Relation;
wire [31:0]             SrcA;
wire [31:0]             SrcB;
wire [31:0]             ALUoutE;

Comparator Comparator_unit(
    .rs1                (rs1E),
    .rs2                (rs2E),
    .funct3             (funct3E),
    .Relation           (Relation)
);

mux SrcA_mux(
    .in0                (rs1E),
    .in1                (PCE),
    .sel                (ALUSrcAE),
    .out                (SrcA)
);

mux SrcB_mux(
    .in0                (rs2E),
    .in1                (ImmExtE),
    .sel                (ALUSrcBE),
    .out                (SrcB)
);

ALU ALU(
    .ALUop1             (SrcA),
    .ALUop2             (SrcB),
    .ALUctrl            (ALUCtrlE),
    .ALUout             (ALUoutE)
);

ff3 EM_FF(
    .clk                (clk),
    .RegWriteE          (RegWriteE),
    .ResultSrcE         (ResultSrcE),
    .MemWriteE          (MemWriteE),
    .ALUoutE            (ALUoutE),
    .funct3E            (funct3E),
    .RdE                (RdE),
    .inc_PCE            (inc_PCE),
    .RegWriteM          (RegWriteM),
    .ResultSrcM         (ResultSrcM),
    .MemWriteM          (MemWriteM),
    .ALUoutM            (ALUoutM),
    .funct3M            (funct3M),
    .RdM                (RdM),
    .inc_PCM            (inc_PCM)
);

assign PCSrc = (BranchE & Relation) | JumpE;

endmodule
