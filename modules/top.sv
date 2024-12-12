module top(
    input logic         clk,
    input logic         rst,
    output logic [31:0] a0
);

logic PCSrc;

//output of PC
wire [31:0]     InstrAdd1;
wire [31:0]     InstrAdd2;
wire [31:0]     inc_PC;

//output of InstrMem
wire [31:0]     instr;

//output of sign ext
wire [31:0]     ImmExtA;
wire [31:0]     ImmExtB;

//output of CU
wire [2:0]          ImmSrcA;
wire [2:0]          ImmSrcB;
wire                MemWrite;
wire                RegWriteA;
wire                RegWriteB;
wire [3:0]          ALUctrlA;
wire [3:0]          ALUctrlB;
wire                ALUSrcA;
wire                ALUSrcB;
wire [1:0]          ResultSrcA;
wire [1:0]          ResultSrcB;

//outputs of datapath
wire [31:0]         ALUout;


PC PC(
    .clk    (clk),
    .rst    (rst),
    .PCSrc  (PCSrc),
    .PC_out (InstrAdd1),
    .PC_out2 (InstrAdd2),
    .inc_PC (inc_PC)
);

InstrMem InstrMem (
    .addr1  (instr1),
    .addr2  (instr2),
    .instr1 (instr1),
    .instr2 (instr2),
    .funct3_i1 (funct3_i1),
    .funct3_i2 (funct3_i2),
    .rs1_1    (rs1_1),
    .rs2_1      (rs2_1),
    .rd_1   (rd_1),
    .rs1_1  (rs1_1),
    .rs1_2  (rs1_2),
    .rs2_1 (rs2_1),
    .rs2_2 (rs2_2),
    .rd_2  (rd_2)
);

CU CU(
    .funct3A    (instr1[14:12]),
    .opA        (instr1[6:0]),
    .funct7_5A  (instr1[30]),
    .funct3B    (instr2[14:12]),
    .opB        (instr2[6:0]),
    .funct7_5B  (instr2[30]),
    //outputs
    .ImmSrcA    (ImmSrcA),
    .ImmSrcB    (ImmSrcB),
    .ALUSrcA    (ALUSrcA),
    .ALUSrcB    (ALUSrcB),
    .ALUctrlA   (ALUctrlA),
    .ALUctrlB   (ALUctrlB),
    .RegWriteA  (RegWriteA),
    .RegWriteB  (RegWriteB),
    .MemWrite   (MemWrite),
    .ResultSrcA (ResultSrcA),
    .ResultSrcB (ResultSrcB)

);

sign_ext sign_ext (
    .ImmSrc         (ImmSrc),
    .ImmExtA        (ImmExtA),
    .ImmExtB        (ImmExtB),
    .ImmA           (ImmA[31:7]),
    .ImmB           (ImmB[31:7])
);

datapath datapath (
    .clk            (clk),
    .RegWriteA      (RegWriteA),
    .RegWriteB      (RegWriteB),
    .MemWrite       (MemWrite),
    .ALUctrlA       (ALUctrlA),
    .ALUctrlB       (ALUctrlB),
    .ALUSrcA        (ALUSrcA),
    .ALUSrcB        (ALUSrcB),
    .funct3_i1      (instr1[14:12]),
    .funct3_i2      (instr2[14:12]),
    .rs1_1          (instr1[19:15]),
    .rs1_2          (instr2[19:15]),
    .rs2_1          (instr1[24:20]),
    .rs2_2          (instr2[24:20]),
    .rd_1            (instr1[11:17]),
    .rd_2            (instr2[11:17]),
    .ResultSrcA     (ResultSrcA),
    .ResultSrcB     (ResultSrcB),
    .ImmExtA        (ImmExtA),
    .ImmExtB        (ImmExtB),
    .inc_PC         (inc_PC),
    .PC_out         (InstrAdd),
    .ALUoutA        (ALUoutA),
    .ALUoutB        (ALUoutB),
    .a0             (a0),
    .zero           (zero)
);

endmodule
