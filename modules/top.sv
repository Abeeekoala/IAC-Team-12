module top(
    input   logic           clk,
    input   logic           rst,
    input   logic           trigger,
    output  logic [31:0]    a0
);

// transcending multiple regions signals
wire                        PCSrc;
wire [4:0]                  RdW;
wire                        RegWriteW;
wire [31:0]                 ResultW;
wire [31:0]                 PCTarget;
wire                        Stall;
wire                        Flush;
wire [1:0]                  ForwardA;
wire [1:0]                  ForwardB;
wire [4:0]                  Rs1D;
wire [4:0]                  Rs2D;
wire [4:0]                  Rs1E;
wire [4:0]                  Rs2E;


//  fetch to decode signals
wire [31:0]                 InstrD;
wire [31:0]                 PCD;
wire [31:0]                 inc_PCD;

// decode to execute signals
wire                        JumpE;
wire                        BranchE;
wire                        RegWriteE;
wire [1:0]                  ResultSrcE;
wire                        MemWriteE;
wire [3:0]                  ALUCtrlE;
wire                        ALUSrcAE;
wire                        ALUSrcBE;
wire [31:0]                 RD1E;
wire [31:0]                 RD2E;
wire [31:0]                 ImmExtE;
wire [31:0]                 PCE;
wire [2:0]                  funct3E;
wire [4:0]                  RdE;
wire [31:0]                 inc_PCE;

// execute to memory signals
wire                        RegWriteM;
wire [1:0]                  ResultSrcM;
wire                        MemWriteM;
wire [31:0]                 ALUoutM;
wire [31:0]                 Rd2M;
wire [2:0]                  funct3M;
wire [4:0]                  RdM;
wire [31:0]                 inc_PCM;

// memory to writeback signals
wire [1:0]                 ResultSrcW;
wire [31:0]                ALUoutW;
wire [31:0]                ReadDataW;
wire [31:0]                inc_PCW;

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
    .Rs1D                   (Rs1D),
    .Rs2D                   (Rs2D),
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
    .ALUoutM_o              (ALUoutM),
    .funct3M                (funct3M),
    .Rd2M                   (Rd2M),
    .RdM                    (RdM),
    .inc_PCM                (inc_PCM)
);

memory memory(
    .clk                    (clk),
    .RegWriteM              (RegWriteM),
    .ResultSrcM             (ResultSrcM),
    .MemWriteM              (MemWriteM),
    .ALUoutM_i              (ALUoutM),
    .Rd2M                   (Rd2M),
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
    .rst                    (rst),
    .Rs1D                   (Rs1D),
    .Rs2D                   (Rs2D),
    .Rs1E                   (Rs1E),
    .Rs2E                   (Rs2E),
    .RdE                    (RdE),
    .RdM                    (RdM),
    .RdW                    (RdW),
    .RegWriteM              (RegWriteM),
    .RegWriteW              (RegWriteW),
    .LoadE                  (ResultSrcE[0]),
    .PCSrc                  (PCSrc),
    .ForwardA               (ForwardA),
    .ForwardB               (ForwardB),
    .Stall                  (Stall),
    .Flush                  (Flush)
);

endmodule
