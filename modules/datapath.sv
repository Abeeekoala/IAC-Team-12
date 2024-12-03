module datapath #(
    parameter A_WIDTH = 5,
              D_WIDTH = 32
)(
    input logic                 clk,
    //Inputs from CU
    input logic                 MemWrite,
    input logic                 RegWrite,
    input logic [3:0]           ALUctrl,
    input logic                 ALUSrc,
    input logic [1:0]           ResultSrc,   

    //Inputs from Instruction
    input logic [2:0]           funct3_i, 
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
    output logic [D_WIDTH-1:0]  reg1,  
    output logic [D_WIDTH-1:0]  a0
);

logic [D_WIDTH-1:0] rd2;
logic [D_WIDTH-1:0] ALUop1;
logic [D_WIDTH-1:0] ALUop2;
logic [D_WIDTH-1:0] ALUout;
logic [D_WIDTH-1:0] ReadData;
logic [D_WIDTH-1:0] Result;

assign reg1 = ALUop1;

regfile regfile (
    .clk        (clk),
    .A1        (rs1),
    .A2        (rs2),
    .A3        (rd),
    .WE3        (RegWrite),
    .WD3        (Result),
    .a0         (a0),
    .RD1        (ALUop1),
    .RD2        (rd2)
);

mux ALUSrcB (
    .in0        (rd2),
    .in1        (ImmExt),
    .sel        (ALUSrc),
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
