module ff2 #(
    parameter   ADDR_WIDTH = 32,
                DATA_WIDTH = 32
)(
    input logic                 clk,
    //input other signals
    input logic [DATA_WIDTH-1:0]    RD1,
    input logic [DATA_WIDTH-1:0]    RD2,
    input logic [DATA_WIDTH-1:0]    PCD,
    input logic [4:0]               RdD,
    input logic [DATA_WIDTH-1:0]    ImmExtD,
    input logic [DATA_WIDTH-1:0]    PCPlus4D,
    //input ctrl signals
    input logic                     RegWriteD,
    input logic [1:0]               ResultSrcD,
    input logic                     MemWriteD,
    input logic                     JumpD,
    input logic                     BranchD,
    input logic [2:0]               ALUControlD,
    input logic                     ALUSrcD,
    //output ctrl signals
    output logic [2:0]              ALUControlE,
    output logic                    ALUSrcE,
    output logic                    BranchE,
    output logic                    JumpE,
    output logic                    MemWriteE,
    output logic [1:0]              ResultSrcE,
    output logic                    RegWriteE,
    //other outputs
    output logic [DATA_WIDTH-1:0]   RD1E,
    output logic [DATA_WIDTH-1:0]   RD2E,
    output logic [DATA_WIDTH-1:0]   PCE,
    output logic [4:0]              RdE,
    output logic [DATA_WIDTH-1:0]   ImmExtE,
    output logic [DATA_WIDTH-1:0]   PCPlus4E,
);

always_ff @ (posedge clk)
    begin
        RegWriteE <= RegWriteD;
        ResultSrcE <= ResultSrcD;
        MemWriteE <= MemWriteD;
        JumpE <= JumpD;
        BranchE <= BranchE;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        RD1E <= RD1;
        RD2E <= RD2E;
        PCE <= PCD;
        RdE <= RdD;
        ImmExtE <= ImmExtD;
        PCPlus4E <= PCPlus4D;  
    end

endmodule
