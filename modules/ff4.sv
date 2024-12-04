module ff4 (
    input logic                     clk,
    input logic                     RegWriteM,
    input logic [1:0]               ResultSrcM,
    input logic [31:0]              ALUResultM,
    input logic [31:0]              ReadDataM, //datamem, fix same name from InstrMem
    input logic [4:0]               RdM,
    input logic [31:0]              PCPlus4M,

    output logic                    RegWriteW,
    output logic [1:0]              ResultSrcW,
    output logic [31:0]             ALUResultW,
    output logic [31:0]             ReadDataW,
    output logic [4:0]              RdW,
    output logic [31:0]             inc_PC
);

always_ff @ (posedge clk)
    begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ALUResultW <= ALUResultM;
        RdW <= RdM;
        inc_PC <= PCPlus4M;
        ReadDataW <= ReadDataM;
    end

endmodule
