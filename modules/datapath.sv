module datapath #(
    parameter A_WIDTH = 5,
              D_WIDTH = 32
)(
    input logic                 clk,
    //Inputs from CU
    input logic                 MemWrite,
    input logic                 RegWriteA,
    input logic                 RegWriteB,
    input logic [3:0]           ALUctrlA,
    input logic [3:0]           ALUctrlB,
    input logic                 ALUSrcA,
    input logic                 ALUSrcB,
    input logic [1:0]           ResultSrcA,   
    input logic [1:0]           ResultSrcB,   

    //Inputs from Instruction
    input logic [2:0]           funct3_i1, funct3_i2, 
    input logic [A_WIDTH-1:0]   rs1_1, rs2_1, rd_1,
    input logic [A_WIDTH-1:0]   rs1_2, rs2_2, rd_2,

    //Input from Extend
    input logic [D_WIDTH-1:0]   ImmExtA,
    input logic [D_WIDTH-1:0]   ImmExtB,
    
    //Inputs from PC
    input logic [D_WIDTH-1:0]   inc_PC,
    input logic [D_WIDTH-1:0]   PC_out,

    //ALU output
    output logic [D_WIDTH-1:0]  ALUoutA,
    output logic [D_WIDTH-1:0]  ALUoutB,

    //Regfile output
    output logic [D_WIDTH-1:0]  a0,

    //control unit output
    output logic                zero
);

wire [D_WIDTH-1:0] rd1;
wire [D_WIDTH-1:0] rd2;
wire [D_WIDTH-1:0] rd4;
wire [D_WIDTH-1:0] rd5;
wire [D_WIDTH-1:0] ALUop1;
wire [D_WIDTH-1:0] ALUop2;
wire [D_WIDTH-1:0] ReadData1;
wire [D_WIDTH-1:0] ReadData2;
wire [D_WIDTH-1:0] Result;

regfile regfile (
    .ra1A         (rs1_1),
    .ra2A         (rs2_1),
    .ra1B         (rs1_2),
    .ra2B         (rs2_2),
    .WEA           (RegWriteA),
    .WEB           (RegWriteB),
    .WD3            (WD3),
    .WD6            (WD6),
    .waA          (rd),
    .waB          (ALUop2A),
    .RD1A         (rd1A),
    .RD2A         (rd2A),
    .a0             (a0)
);

mux ALUout2A_mux (
    .in0        (RD2A),
    .in1        (ImmExtA),
    .sel        (ALUSrc),
    .out        (ALUop2A)
);

mux ALUout2B_mux (
    .in0        (RD2B),
    .in1        (ImmExtB),
    .sel        (ALUSrc),
    .out        (ALUop2B)
);

ALU ALU (
    .ALUop1A     (ALUop1A),
    .ALUop1B     (ALUop1B),
    .ALUop2A     (ALUop2A),
    .ALUop2B     (ALUop2B),
    .ALUctrl     (ALUctrl),  
    .ALUoutA     (ALUoutA),
    .ALUoutB     (ALUoutB)
);

datamemory dataMem(
    .clk        (clk),
    .WE         (MemWrite),
    .wd1        (rd1),
    .wd2        (rd2),
    .a1         (ALUoutA),
    .a2         (ALUoutB),
    .rd_1        (ReadData1),
    .rd_2        (ReadData2)
);

mux4 muxResult(
    .in0        (ALUoutA),
    .in1        (rd1),
    .in2        (ALUoutB),
    .in3        (rd2),
    .sel        (ResultSrc),
    .out        (Result)
);

mux Data1 (
    .in0 (ALUoutA),
    .in1 (rd1),
    .sel (ResultSrcA),
    .out (WD3)
);

mux Data2 (
    .in0 (ALUoutB),
    .in1 (rd2),
    .sel (ResultSrcB),
    .out (WD6)
);


endmodule
