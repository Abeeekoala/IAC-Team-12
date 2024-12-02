module datapath #(
    parameter A_WIDTH = 5,
              D_WIDTH = 32
)(
    input logic                 clk,
    //Inputs from CU
    input logic                 MemWrite,
    input logic                 regWrite,
    input logic [3:0]           ALUctrl,
    input logic                 ALUsrc,
    input logic [1:0]           ResultSrc,
    input logic [2:0]           funct3_i,   

    //Inputs from Instruction 
    input logic [A_WIDTH-1:0]   rs1,
    input logic [A_WIDTH-1:0]   rs2,
    input logic [A_WIDTH-1:0]   rd,

    //Input from Extend
    input logic [D_WIDTH-1:0]   ImmExt,
    
    //Inputs from PC
    input logic [D_WIDTH-1:0]   inc_PC,
    input logic [D_WIDTH-1:0]   PCTarget,

    //ALU outputs
    output logic                Zero,
    output logic                Less,
    output logic                LessU,  
    output logic [D_WIDTH-1:0]  a0
);

logic [D_WIDTH-1:0] rd2;
logic [D_WIDTH-1:0] ALUop1;
logic [D_WIDTH-1:0] ALUop2;
logic [D_WIDTH-1:0] ALUout;
logic [D_WIDTH-1:0] ReadData;
logic [D_WIDTH-1:0] Result;

regfile regfile (
    .clk        (clk),
    .ad1        (rs1),
    .ad2        (rs2),
    .ad3        (rd),
    .we3        (regWrite),
    .wd3        (Result),
    .a0         (a0),
    .rd1        (ALUop1),
    .rd2        (rd2)
);

mux ALUSrcB (
    .in0        (rd2),
    .in1        (ImmExt),
    .sel        (ALUsrc),
    .out        (ALUop2)
);

ALU ALU (
    .ALUop1     (ALUop1),
    .ALUop2     (ALUop2),
    .ALUctrl    (ALUctrl),
    .Zero       (Zero),
    .Less       (Less),
    .LessU      (LessU),   
    .ALUout     (ALUout)
);

datamemory dataMem(
    .clk        (clk),
    .WE         (MemWrite),
    .WD         (rd2),
    .A          (ALUout),
    .funct3     (funct3_i), 
    .RD         (ReadData)
);

mux4 muxResult(
    .in0        (ALUout),
    .in1        (ReadData),
    .in2        (inc_PC),
    .in3        (PCTarget),
    .sel        (ResultSrc),
    .out        (Result)
);


endmodule
