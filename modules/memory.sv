module memory(
    input logic                 clk,
    input logic                 RegWriteM,
    input logic [1:0]           ResultSrcM,
    input logic                 MemWriteM,
    input logic [31:0]          ALUoutM,
    input logic [31:0]          rs2M,
    input logic [2:0]           funct3M,
    input logic [4:0]           RdM,
    input logic [31:0]          inc_PCM,
    input logic                 trigger,
    output logic                RegWriteW,
    output logic [1:0]          ResultSrcW,
    output logic [31:0]         ALUoutW,
    output logic [31:0]         ReadDataW,
    output logic [4:0]          RdW,
    output logic [31:0]         inc_PCW
);

logic [31:0]             ReadDataM;

datamemory DataMem(
    .trigger                    (trigger),
    .clk                        (clk),
    .WE                         (MemWriteM),
    .A                          (ALUoutM),
    .WD                         (rs2M),
    .funct3                     (funct3M),
    .RD                         (ReadDataM)
);

ff4 MW_FF(
    .clk                        (clk),
    .RegWriteM                  (RegWriteM),
    .ResultSrcM                 (ResultSrcM),
    .ALUoutM                    (ALUoutM),
    .ReadDataM                  (ReadDataM),
    .RdM                        (RdM),
    .inc_PCM                    (inc_PCM),
    .RegWriteW                  (RegWriteW),
    .ResultSrcW                 (ResultSrcW),
    .ALUoutW                    (ALUoutW),
    .ReadDataW                  (ReadDataW),
    .RdW                        (RdW),
    .inc_PCW                    (inc_PCW)
);

endmodule
