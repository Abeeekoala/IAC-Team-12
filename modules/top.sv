module top(
    input   logic           clk,
    input   logic           rst,
    output  logic [31:0]    a0         
);

logic [31:0]        ImmOp;
logic               PCsrc ;
logic [31:0]        InstrAdd;
logic [31:0]        instr;
logic               eq;
logic [2:0]         ALUctrl;
logic               ALUsrc;
logic [1:0]         ImmSrc;
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
    .opcode     (instr[6:0]),
    .funct3     (instr[14:12]),
    .funct7     (instr[30]),
    .EQ         (eq),
    .PCsrc      (PCsrc),
    .ALUctrl    (ALUctrl),
    .ALUsrc     (ALUsrc),
    .ImmSrc     (ImmSrc),
    .RegWrite   (RegWrite)
);

sign_ext sign_ext(
    .ImmSrc     (ImmSrc),
    .Instr      (instr),
    .ImmOp      (ImmOp)
);

datapath datapath(
    .clk        (clk),
    .rs1        (instr[19:15]),
    .rs2        (instr[24:20]),
    .rd         (instr[11:7]),
    .regWrite   (RegWrite),
    .ALUctrl    (ALUctrl),
    .ALUsrc     (ALUsrc),
    .ImmOp      (ImmOp),
    .eq         (eq),
    .a0         (a0)
);

endmodule
