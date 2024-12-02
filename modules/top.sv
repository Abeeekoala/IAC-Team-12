module top(
    input   logic           clk,
    input   logic           rst,
    input   logic           TRIGGERSEL,
    output  logic [31:0]    a0         
);

logic [31:0]        ImmOp;
logic               PCsrc ;
logic [31:0]        InstrAdd;
logic [31:0]        instr;
logic               Zero;
logic               Less;
logic               LessU;
logic [3:0]         ALUctrl;
logic               ALUsrc;
logic               MemWrite;
logic               ResultSrc;
logic [2:0]         ImmSrc;
logic               RegWrite;  

PC PC(
    .clk        (clk),
    .rst        (rst),
    .PCsrc      (PCsrc),
    .ImmOp      (ImmOp),
    .PC_out     (InstrAdd)
);

InstrMem InstrMem(
    .addr       (InstrAdd),
    .instr      (instr)
);

CU CU(
    .funct3     (instr[14:12]),
    .op         (instr[6:0]),
    .funct7_5   (instr[30]),
    .Zero       (Zero),
    .Less       (Less),
    .LessU      (LessU),
    .ImmSrc     (ImmSrc),
    .PCSrc      (PCsrc),
    .ResultSrc  (ResultSrc),
    .ALUsrc     (ALUsrc),
    .MemWrite   (MemWrite),
    .ALUctrl    (ALUctrl),
    .RegWrite   (RegWrite)
);

sign_ext sign_ext(
    .ImmSrc     (ImmSrc),
    .Instr      (instr),
    .ImmOp      (ImmOp)
);

regfile regfile_instance(
    .clk(clk),
    .A1 (instr[19:15]),
    .A2 (instr[24:20]),
    .A3 (instr[11:7]),
    .WE3 (RegWrite),
    .WD3 (result),
    .RD1 (ALUop1),
    .RD2 (regOp2),
    .a0 (a0)
);

assign ALUop2 = ALUsrc ? ImmOp : regOp2;

datapath datapath(
    .clk        (clk),
    .rs1        (instr[19:15]),
    .rs2        (instr[24:20]),
    .rd         (instr[11:7]),
    .regWrite   (RegWrite),
    .ALUctrl    (ALUctrl),
    .ALUsrc     (ALUsrc),
    .ImmOp      (ImmOp),
    .Zero       (Zero),
    .a0         (a0)
);

datamemory data_memory_instance(
    .clk (clk),
    .WE (MemWrite),
    .A (ALUout),
    .WD (regOp2),
    .RD (ReadData)
);

assign TriggerOutput = TRIGGERSEL ? ReadData : ALUout; //trigger mux
assign Result = ResultSrc ? TriggerOutput : ALUout; //mux for data memory

endmodule
