module ff4 (
    input logic                     clk,
    input logic                     RegWriteM,
    input logic [1:0]               ResultSrcM,
    input logic [31:0]              ALUoutM,
    input logic [31:0]              ReadDataM, //datamem, fix same name from InstrMem
    input logic [4:0]               RdM,
    input logic [31:0]              inc_PCM,

    output logic                    RegWriteW,
    output logic [1:0]              ResultSrcW,
    output logic [31:0]             ALUoutW,
    output logic [31:0]             ReadDataW,
    output logic [4:0]              RdW,
    output logic [31:0]             inc_getPCW
);

always_ff @ (posedge clk)
    begin
        RegWriteW <= RegWriteM;
        ResultSrcW <= ResultSrcM;
        ALUoutW <= ALUoutM;
        ReadDataW <= ReadDataM;
        RdW <= RdM;
        inc_PCW <= inc_PCM;
    end

endmodule
