module ff4 #(
    parameter ADDR_WIDTH = 32,
              DATA_WIDTH = 32
)(
    input logic                     clk,
    //ctrl inputs
    input logic                     RegWriteM,
    input logic [1:0]               ResultSrcM,
    //other inputs
    input logic [DATA_WIDTH-1:0]    ALUResultM,
    input logic [DATA_WIDTH-1:0]    ReadData,             //datamem, fix same name from InstrMem
    input logic [4:0]               RdM,
    input logic [DATA_WIDTH-1:0]    PCPlus4M,
    //ctrl outputs
    output logic                    RegWriteW,
    output logic [1:0]              ResultSrcW,
    //other outputs
    output logic [DATA_WIDTH-1:0]   ReadDataW,
    output logic [4:0]              RdW,
    output logic [DATA_WIDTH-1:0]   PCPlus4W,
    output logic [DATA_WIDTH-1:0]   ALUResultW   
);

always_ff @ (posedge clk)
    begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ALUResultW <= ALUResultM;
        RdW <= RdM;
        PCPlus4W <= PCPlus4M;
        ALUResultW <= ALUResultM;
        ReadDataW <= ReadData;
    end

endmodule
