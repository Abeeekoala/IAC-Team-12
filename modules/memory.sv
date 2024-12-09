module memory(
    input logic                 clk, 
    input logic                 rst,
    input logic                 RegWriteM, 
    input logic [1:0]           ResultSrcM, 
    input logic                 MemWriteM, 
    input logic [31:0]          ALUoutM_i, 
    input logic [31:0]          Rd2M, 
    input logic [2:0]           funct3M, 
    input logic [4:0]           RdM, 
    input logic [31:0]          inc_PCM,  
    input logic                 trigger, 
    output logic                RegWriteW, 
    output logic [1:0]          ResultSrcW, 
    output logic [31:0]         ALUoutW, 
    output logic [31:0]         ReadDataW,  
    output logic [4:0]          RdW, 
    output logic [31:0]         inc_PCW, 
    output logic                stall, 
    output logic                hit
);

logic [31:0]            ReadDataM;
wire  [31:0]            RD;
wire                    writeback;
wire  [31:0]            WB_addr;
wire  [31:0]            WB_DATA;
wire                    fetch;

datamemory DataMem(
    .trigger                    (trigger),
    .clk                        (clk),
    .fetch                      (fetch),
    .A                          (ALUoutM_i),
    .RD                         (RD),
    .writeback                  (writeback),
    .WB_addr                    (WB_addr),
    .WB_DATA                    (WB_DATA)
);

ff4 MW_FF(
    .clk                        (clk),
    .RegWriteM                  (RegWriteM),
    .ResultSrcM                 (ResultSrcM),
    .ALUoutM                    (ALUoutM_i),
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

setascache two_way_cache (
    .clk                        (clk),
    .WE                         (MemWriteM),
    .RD                         (RD),
    .fetch                      (fetch),        
    .A                          (ALUoutM_i),
    .WD                         (Rd2M),
    .rst                        (rst),
    .funct3                     (funct3M),
    .Read                       (ResultSrcM[0]),
    .stall                      (stall),
    .hit                        (hit),    
    .DATA_OUT                   (ReadDataM),
    .WB_DATA                    (WB_DATA),
    .WB_addr                    (WB_addr),
    .writeback                  (writeback)                    
);

endmodule
