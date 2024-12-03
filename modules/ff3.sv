module ff3 #(
    parameter   ADDR_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input logic                     clk,
    //ctrl inputs
    input logic                     RegWriteE,
    input logic [1:0]               ResultSrcE,
    input logic                     MemWriteE,
    //other inputs
    input logic [DATA_WIDTH-1:0]    ALUout,
    input logic [DATA_WIDTH-1:0]    WriteDataE, //or is this regOp2
    input logic [4:0]               RdE,
    input logic [DATA_WIDTH-1:0]    PCPlus4E
    //other outputs
    output logic [DATA_WIDTH-1:0]   PCPlus4M,
    output logic [5:0]              RdM,
    output logic [DATA_WIDTH-1:0]   WriteDataM,
    output logic [DATA_WIDTH-1:0]   ALUResultM,
    //ctrl outputs
    output logic                MemWriteM,
    output logic [1:0]          ResultSrcM,
    output logic                RegWriteM       
);

always_ff @ (posedge clk)
    begin
        RegWriteM <= RegWriteE;
        ResultSrcM <= ResultSrcE;
        MemWriteM <= MemWriteE;
        WriteDataM <= WriteDataE;
        RdM <= RdE;
        PCPlus4M <= PCPlus4E;
        ALUResultM <= ALUout;
    end

endmodule
