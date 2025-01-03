module ff4 (
    input logic                     clk,
    input logic                     RegWriteM,
    input logic [1:0]               ResultSrcM,
    input logic [31:0]              ALUoutM,
    input logic [31:0]              ReadDataM, //datamem, fix same name from InstrMem
    input logic [4:0]               RdM,
    input logic [31:0]              inc_PCM,
    input logic                     stall_cache,

    output logic                    RegWriteW,
    output logic [1:0]              ResultSrcW,
    output logic [31:0]             ALUoutW,
    output logic [31:0]             ReadDataW,
    output logic [4:0]              RdW,
    output logic [31:0]             inc_PCW
);

always_ff @ (posedge clk)
    begin
        if (ResultSrcM[0] && stall_cache) begin
            RegWriteW <= 0'b0;
        end
        else begin
            RegWriteW <= RegWriteM;
            ResultSrcW <= ResultSrcM;
            ALUoutW <= ALUoutM;
            ReadDataW <= ReadDataM;
            RdW <= RdM;
            inc_PCW <= inc_PCM;
        end
    end

endmodule
