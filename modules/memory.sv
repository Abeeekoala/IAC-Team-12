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
    output logic                fetch        
);

logic [31:0] ReadDataM;    // Data from L1 cache or memory
logic        hit;          // Cache hit signal from L1
logic        writeback;    
logic [31:0] WB_DATA;      
logic [31:0] WB_addr;

// L2 interface signals
logic L2_fetch, L2_WE;
logic [31:0] L2_DATA_OUT;
logic L2_writeback;
logic [31:0] L2_WB_DATA, L2_WB_ADDR;

//local loading signals
logic [31:0] preload_addr, preload_data;


datamemory DataMem(
    .trigger                    (trigger),
    .clk                        (clk),
    .fetch                      (fetch),
    .A                          (ALUoutM_i),
    .RD                         (ReadDataM),
    .writeback                  (writeback),
    .WB_addr                    (WB_addr),
    .WB_DATA                    (WB_DATA),
    .preload_addr               (preload_addr),
    .RDpre                      (preload_data)
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

setascache L1 (
    .clk                        (clk),
    .WE                         (MemWriteM),
    .RD                         (ReadDataM),
    .fetch                      (fetch),        
    .A                          (ALUoutM_i),
    .WD                         (Rd2M),
    .rst                        (rst),
    .funct3                     (funct3M),
    .hit                        (hit),    
    .DATA_OUT                   (ReadDataM),
    .WB_DATA                    (WB_DATA),
    .WB_addr                    (WB_addr),
    .writeback                  (writeback), 
    //L2 interface signals
    .L2_fetch                   (L2_fetch),
    .L2_hit                     (L2_hit),
    .L2_RD                      (L2_DATA_OUT),
    .L2_writeback               (L2_writeback),
    .L2_WB_DATA                 (L2_WB_DATA),
    .L2_WB_ADDR                 (L2_WB_ADDR)
);

setascacheL2 L2 (
    .clk                        (clk),
    .rst                        (rst),
    .WE                         (L2_WE),
    .RD                         (ReadDataM),
    .fetch                      (L2_fetch),        
    .A                          (ALUoutM_i),
    .WD                         (Rd2M),
    .funct3                     (funct3M),
    .stall                      (stall),
    .hit                        (L2_hit),    
    .DATA_OUT                   (L2_DATA_OUT),
    .WB_DATA                    (L2_WB_DATA),
    .WB_addr                    (L2_WB_ADDR),
    .writeback                  (L2_writeback),
    .preload_data               (preload_data),
    .preload_addr               (preload_addr)
);

always_comb begin
    fetch = hit ? 1'b0 : L2_fetch;

    // Control L2 interface based on L1 behavior
    L2_fetch = ~hit;
    L2_WE = MemWriteM && ~hit;

    writeback = ~hit && L2_writeback;
    WB_DATA = L2_WB_DATA;
    WB_addr = L2_WB_ADDR;
end

endmodule
