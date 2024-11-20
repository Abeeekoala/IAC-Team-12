module top(
    input   logic           clk,
    input   logic           rst,
    output  logic           a0         
);

logic       ImmOp[31:0]     = 0;
logic       PCsrc           = 0;
logic       InstrAdd[31:0]  = 0;
logic       instr[31:0]     = 0;
logic       eq              = 0;
PC PC(
    .clk        (clk),
    .rst        (rst),
    .PCsrc      (PCsrc),
    .ImmOp      (ImmOp),
    .PC         (InstrAdd)
);

InstrMem InstrMem(
    .PC         (InstrAdd),
    .instr      (instr)
);

CU CU(
    .op         (instr[6:0]),
    .funct3     (instr[14:12]),
    .funct7     (instr[30]),
    .EQ         (eq),
    .PCsrc      (PCsrc),
    .ALUctrl    (ALUctrl),
    .ALUsrc     (ALUsrc),
    .ImmSrc     (ImmSrc),
    .RegWrite   (RegWrite)
);

SignExtend SignExtend(
    .ImmSrc     (ImmSrc),
    .Imm        ({instr[11:5], instr[4:0]}),
    .ImmOp      (ImmOp)
);

DataPath DataPath(
    .clk        (clk),
    .rs1        (instr[19:15]),
    .rs2        (instr[24:20]),
    .rd         (instr[11:7]),
    .RegWrite   (RegWrite),
    .ALUctrl    (ALUctrl),
    .ALUsrc     (ALUsrc),
    .ImmOp      (ImmOp),
    .EQ         (eq),
    .a0         (a0)
);

    
endmodule