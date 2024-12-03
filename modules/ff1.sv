module ff1 #(
    parameter   ADDR_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic [DATA_WIDTH-1:0]    RD,
    input logic [DATA_WIDTH-1:0]    PC,
    input logic [DATA_WIDTH-1:0]    inc_PC,
    input logic [DATA_WIDTH-1:0]    InstrMem,
    output logic [DATA_WIDTH-1:0]   PCD,
    output logic [DATA_WIDTH-1:0]   PCPlus4D
);

always_ff @ (posedge clk)
    begin  
        InstrMem <= RD;
        PCD <= PC;
        PCPlus4D <= inc_PC;
    end

endmodule
