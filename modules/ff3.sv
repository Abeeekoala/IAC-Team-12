module ff3 (
    input logic                     clk,
    input logic [31:0]              PCPlus4E,
    input logic [5:0]               RdE,
    input logic [31:0]              WriteDataE, //or is this regOp2
    input logic [31:0]              ALUout,
    input logic [1:0]               ResultSrcE,
    input logic                     MemWriteE,
    input logic                     RegWriteE,
    input logic                     funct3E,

    output logic [31:0]             PCPlus4M,
    output logic [5:0]              RdM,
    output logic [31:0]             WriteDataM,
    output logic [31:0]             ALUResultM,
    output logic [1:0]              ResultSrcM,
    output logic                    MemWriteM,
    output logic                    RegWriteM,
    output logic                    funct3M
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
        funct3M <= funct3E;
    end

endmodule
