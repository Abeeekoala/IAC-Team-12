module decode (
    input logic                 clk,
    input logic [31:0]          InstrD,
    input logic [31:0]          PCD,
    input logic [31:0]          inc_PCD,
    input logic                 RegWriteW,
    input logic [4:0]           RdW,
    input logic [31:0]          ResultW,
    output logic                JumpE,
    output logic                BranchE,
    output logic                RegWriteE,
    output logic [1:0]          ResultSrcE,
    output logic                MemWriteE,
    output logic [3:0]          ALUCtrlE,
    output logic                ALUSrcAE,
    output logic                ALUSrcBE,
    output logic [31:0]         rs1E,
    output logic [31:0]         rs2E,
    output logic [31:0]         ImmExtE,
    output logic [31:0]         PCE,
    output logic [2:0]          funct3E,
    output logic [4:0]          RdE,
    output logic [31:0]         inc_PCE,
    output logic [31:0]         a0
);

wire                JumpD;
wire                BranchD;
wire                RegWriteD;
wire [1:0]          ResultSrcD;
wire                MemWriteD;
wire [3:0]          ALUCtrlD;
wire                ALUSrcAD;
wire                ALUSrcBD;
wire [31:0]         rs1D;
wire [31:0]         rs2D;
wire [31:0]         ImmExtD;
wire [2:0]          ImmSrc;

CU control_unit(
    .funct3         (InstrD[14:12]),
    .op             (InstrD[6:0]),
    .funct7_5       (InstrD[30]),
    .ImmSrc         (ImmSrc),
    .MemWrite       (MemWriteD),
    .RegWrite       (RegWriteD),
    .ALUctrl        (ALUCtrlD),
    .ALUSrcA        (ALUSrcAD),
    .ALUSrcB        (ALUSrcBD),
    .ResultSrc      (ResultSrcD),
    .Branch         (BranchD),
    .Jump           (JumpD)
);

regfile RegFile(
    .clk            (clk),
    .A1             (InstrD[19:15]),
    .A2             (InstrD[24:20]),
    .A3             (RdW),
    .WE3            (RegWriteW),
    .WD3            (ResultW),
    .RD1            (rs1D),
    .RD2            (rs2D),
    .a0             (a0)
);

sign_ext signext(
    .Instr          (InstrD[31:7]),
    .ImmSrc         (ImmSrc),
    .ImmExt         (ImmExtD)
);

ff2 DE_FF(
    .clk            (clk),
    .JumpD          (JumpD),
    .BranchD        (BranchD),
    .RegWriteD      (RegWriteD),
    .ResultSrcD     (ResultSrcD),
    .MemWriteD      (MemWriteD),
    .ALUCtrlD       (ALUCtrlD),
    .ALUSrcAD       (ALUSrcAD),
    .ALUSrcBD       (ALUSrcBD),
    .rs1D           (rs1D),
    .rs2D           (rs2D),
    .ImmExtD        (ImmExtD),
    .PCD            (PCD),
    .funct3D        (InstrD[14:12]),
    .RdD            (InstrD[11:7]),
    .inc_PCD        (inc_PCD),
    
    .JumpE          (JumpE),
    .BranchE        (BranchE),
    .RegWriteE      (RegWriteE),
    .ResultSrcE     (ResultSrcE),
    .MemWriteE      (MemWriteE),
    .ALUCtrlE       (ALUCtrlE),
    .ALUSrcAE       (ALUSrcAE),
    .ALUSrcBE       (ALUSrcBE),
    .rs1E           (rs1E),
    .rs2E           (rs2E),
    .ImmExtE        (ImmExtE),
    .PCE            (PCE),
    .funct3E        (funct3E),
    .RdE            (RdE),
    .inc_PCE        (inc_PCE)
);

endmodule