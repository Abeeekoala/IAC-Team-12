module top(
    input   logic           clk,
    input   logic           rst,
    input   logic           trigger,
    output  logic [31:0]    a0
);

// transcending multiple regions signals
logic                       PCSrc;
logic [4:0]                 RdW;
logic                       RegWriteW;
logic [31:0]                ResultW;
logic [31:0]                PCTarget;
logic                       Stall;
logic                       Flush;
logic [1:0]                 ForwardA;
logic [1:0]                 ForwardB;
logic [31:0]                Rs1E;
logic [31:0]                Rs2E;

//  fetch to decode signals
logic [31:0]                InstrD;
logic [31:0]                PCD;
logic [31:0]                inc_PCD;

// decode to execute signals
logic                       JumpE;
logic                       BranchE;
logic                       RegWriteE;
logic [1:0]                 ResultSrcE;
logic                       MemWriteE;
logic [3:0]                 ALUCtrlE;
logic                       ALUSrcAE;
logic                       ALUSrcBE;
logic [31:0]                RD1E;
logic [31:0]                RD2E;
logic [31:0]                ImmExtE;
logic [31:0]                PCE;
logic [2:0]                 funct3E;
logic [4:0]                 RdE;
logic [31:0]                inc_PCE;

// execute to memory signals
logic                       RegWriteM;
logic [1:0]                 ResultSrcM;
logic                       MemWriteM;
logic [31:0]                rs2M;
logic [31:0]                ALUoutM;
logic [2:0]                 funct3M;
logic [4:0]                 RdM;
logic [31:0]                inc_PCM;

// memory to writeback signals
logic [1:0]                 ResultSrcW;
logic [31:0]                ALUoutW;
logic [31:0]                ReadDataW;
logic [31:0]                inc_PCW;

fetch fetch(
    .clk                    (clk),
    .rst                    (rst),
    .PCSrc                  (PCSrc),
    .PCTarget               (PCTarget),
    .Stall                  (Stall),
    .Flush                  (Flush),
    .InstrD                 (InstrD),
    .PCD                    (PCD),
    .inc_PCD                (inc_PCD)
);

decode decode(
    .clk                    (clk),
    .InstrD                 (InstrD),
    .PCD                    (PCD),
    .inc_PCD                (inc_PCD),
    .RegWriteW              (RegWriteW),
    .RdW                    (RdW),
    .ResultW                (ResultW),
    .Stall                  (Stall),
    .Flush                  (Flush),
    .JumpE                  (JumpE),
    .BranchE                (BranchE),
    .RegWriteE              (RegWriteE),
    .ResultSrcE             (ResultSrcE),
    .MemWriteE              (MemWriteE),
    .ALUCtrlE               (ALUCtrlE),
    .ALUSrcAE               (ALUSrcAE),
    .ALUSrcBE               (ALUSrcBE),
    .RD1E                   (RD1E),
    .RD2E                   (RD2E),
    .ImmExtE                (ImmExtE),
    .PCE                    (PCE),
    .funct3E                (funct3E),
    .Rs1E                   (Rs1E),
    .Rs2E                   (Rs2E),
    .RdE                    (RdE),
    .inc_PCE                (inc_PCE),
    .a0                     (a0)
);

execute exectue(
    .clk                    (clk),
    .JumpE                  (JumpE),
    .BranchE                (BranchE),
    .RegWriteE              (RegWriteE),
    .ResultSrcE             (ResultSrcE),
    .MemWriteE              (MemWriteE),
    .ALUCtrlE               (ALUCtrlE),
    .ALUSrcAE               (ALUSrcAE),
    .ALUSrcBE               (ALUSrcBE),
    .RD1E                   (RD1E),
    .RD2E                   (RD2E),
    .ImmExtE                (ImmExtE),
    .PCE                    (PCE),
    .funct3E                (funct3E),
    .RdE                    (RdE),
    .inc_PCE                (inc_PCE),
    .ForwardA               (ForwardA),
    .ForwardB               (ForwardB),
    .ResultW                (ResultW),
    .ALUoutM_i              (ALUoutM),
    .PCTarget               (PCTarget),
    .PCSrc                  (PCSrc),
    .RegWriteM              (RegWriteM),
    .ResultSrcM             (ResultSrcM),
    .MemWriteM              (MemWriteM),
    .rs2M                   (rs2M),
    .ALUoutM_o              (ALUoutM),
    .funct3M                (funct3M),
    .RdM                    (RdM),
    .inc_PCM                (inc_PCM)
);

memory memory(
    .clk                    (clk),
    .RegWriteM              (RegWriteM),
    .ResultSrcM             (ResultSrcM),
    .MemWriteM              (MemWriteM),
    .ALUoutM_i              (ALUoutM),
    .rs2M                   (rs2M),
    .funct3M                (funct3M),
    .RdM                    (RdM),
    .inc_PCM                (inc_PCM),
    .trigger                (trigger),
    .RegWriteW              (RegWriteW),
    .ResultSrcW             (ResultSrcW),
    .ALUoutW                (ALUoutW),
    .ReadDataW              (ReadDataW),
    .RdW                    (RdW),
    .inc_PCW                (inc_PCW)
);

writeback writeback(
    .ResultSrcW             (ResultSrcW),
    .ALUoutW                (ALUoutW),
    .ReadDataW              (ReadDataW),
    .inc_PCW                (inc_PCW),
    .ResultW                (ResultW)
);

hazard_unit hazard_unit(
    .Rs1E                   (Rs1E),
    .Rs2E                   (Rs2E),
    .RdM                    (RdM),
    .RdW                    (RdW),
    .RegWriteM              (RegWriteM),
    .RegWriteW              (RegWriteW),
    .LoadM                  (ResultSrcM[0]),
    .PCSrc                  (PCSrc),
    .ForwardA               (ForwardA),
    .ForwardB               (ForwardB),
    .Stall                  (Stall),
    .Flush                  (Flush)
);

endmodule
