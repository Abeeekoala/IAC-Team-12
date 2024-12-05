module datapath #(
    parameter A_WIDTH = 5,
              D_WIDTH = 32
)(
    input logic                 clk,
    input logic                 trigger, 
    //Inputs from CU
    input logic                 MemWrite,
    input logic                 RegWrite,
    input logic [3:0]           ALUctrl,
    input logic                 ALUSrcA,
    input logic                 ALUSrcB,
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
    input logic [D_WIDTH-1:0]   PC_out,

    //ALU output
    output logic [D_WIDTH-1:0]  ALUout,

    //Comparator outputs
    output logic                Relation, 
    //Regfile output
    output logic [D_WIDTH-1:0]  a0
);

wire [D_WIDTH-1:0] rd1;
wire [D_WIDTH-1:0] rd2;
wire [D_WIDTH-1:0] ALUop1;
wire [D_WIDTH-1:0] ALUop2;
wire [D_WIDTH-1:0] ReadData;
wire [D_WIDTH-1:0] Result;

regfile regfile (
    .clk        (clk),
    .A1         (rs1),
    .A2         (rs2),
    .A3         (rd),
    .WE3        (RegWrite),
    .WD3        (Result),
    .a0         (a0),
    .RD1        (rd1),
    .RD2        (rd2)
);

mux ALUSrcA_mux (
    .in0        (rd1),
    .in1        (PC_out),
    .sel        (ALUSrcA),
    .out        (ALUop1)
);

mux ALUSrcB_mux (
    .in0        (rd2),
    .in1        (ImmExt),
    .sel        (ALUSrcB),
    .out        (ALUop2)
);

ALU ALU (
    .ALUop1     (ALUop1),
    .ALUop2     (ALUop2),
    .ALUctrl    (ALUctrl),  
    .ALUout     (ALUout)
);

Comparator Comparator(
    .rs1        (rd1),
    .rs2        (rd2),
    .funct3     (funct3_i),
    .Relation   (Relation)
);

datamemory dataMem(
    .clk        (clk),
    .trigger    (trigger),
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
    .in3        (32'd0),
    .sel        (ResultSrc),
    .out        (Result)
);


endmodule
