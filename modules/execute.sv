module execute (
    input logic             clk,
    input logic             Stall,
    input logic             JumpE,
    input logic             BranchE,
    input logic             RegWriteE,
    input logic [1:0]       ResultSrcE,
    input logic             MemWriteE,
    input logic [3:0]       ALUCtrlE,
    input logic             ALUSrcAE,
    input logic             ALUSrcBE,
    input logic [31:0]      RD1E,
    input logic [31:0]      RD2E,
    input logic [31:0]      ImmExtE,
    input logic [31:0]      PCE,
    input logic [2:0]       funct3E,
    input logic [4:0]       RdE,
    input logic [31:0]      inc_PCE,
    input logic [1:0]       ForwardA,
    input logic [1:0]       ForwardB,
    input logic [31:0]      ResultW,
    input logic [31:0]      ALUoutM_i,
    output logic [31:0]     PCTarget,
    output logic            PCSrc,
    output logic            RegWriteM,
    output logic [1:0]      ResultSrcM,
    output logic            MemWriteM,
    output logic [31:0]     ALUoutM_o,
    output logic [2:0]      funct3M,
    output logic [4:0]      RdM,
    output logic [31:0]     Rd2M,
    output logic [31:0]     inc_PCM
);

logic                       Relation;
wire [31:0]                 SrcA;
wire [31:0]                 SrcB;
wire [31:0]                 ALUoutE;
logic [31:0]                Rd1;
logic [31:0]                Rd2;

mux4 ForwardA_mux(
    .in0                    (RD1E),
    .in1                    (ResultW),
    .in2                    (ALUoutM_i),
    .in3                    (32'd0000),
    .sel                    (ForwardA),
    .out                    (Rd1)
);

mux4 ForwardB_mux(
    .in0                    (RD2E),
    .in1                    (ResultW),
    .in2                    (ALUoutM_i),
    .in3                    (32'd0000),
    .sel                    (ForwardB),
    .out                    (Rd2)
);

mux SrcA_mux(
    .in0                    (Rd1),
    .in1                    (PCE),
    .sel                    (ALUSrcAE),
    .out                    (SrcA)
);

mux SrcB_mux(
    .in0                    (Rd2),
    .in1                    (ImmExtE),
    .sel                    (ALUSrcBE),
    .out                    (SrcB)
);

Comparator comparator_unit(
    .rs1                    (Rd1),
    .rs2                    (Rd2),
    .funct3                 (funct3E),
    .Relation               (Relation)
);

ALU ALU_unit(
    .ALUop1                 (SrcA),
    .ALUop2                 (SrcB),
    .ALUctrl                (ALUCtrlE),
    .ALUout                 (ALUoutE)
);

ff3 EM_FF(
    .clk                    (clk),
    .RegWriteE              (RegWriteE),
    .ResultSrcE             (ResultSrcE),
    .MemWriteE              (MemWriteE),
    .ALUoutE                (ALUoutE),
    .funct3E                (funct3E),
    .RdE                    (RdE),
    .Rd2E                   (Rd2),
    .inc_PCE                (inc_PCE),
    .Stall                  (Stall),

    .RegWriteM              (RegWriteM),
    .ResultSrcM             (ResultSrcM),
    .MemWriteM              (MemWriteM),
    .ALUoutM                (ALUoutM_o),
    .funct3M                (funct3M),
    .RdM                    (RdM),
    .Rd2M                   (Rd2M),
    .inc_PCM                (inc_PCM)
);

assign PCSrc = (BranchE & Relation) | JumpE;
assign PCTarget = ALUoutE;

endmodule
