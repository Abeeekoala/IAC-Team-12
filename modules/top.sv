module top(
    input   logic           clk,
    input   logic           rst,
    input   logic           TRIGGERSEL,
    output  logic [31:0]    a0         
);

//Output of PC
logic [31:0]        InstrAdd;
logic [31:0]        inc_PC;
logic [31:0]        PCTarget;

//Output of Instr mem  
logic [31:0]        instr;

//Output of sign_ext     
logic [31:0]        ImmExt;

//Output of CU
logic               PCsrc;  
logic [2:0]         ImmSrc;    
logic               MemWrite;
logic               RegWrite;
logic [3:0]         ALUctrl;
logic               ALUsrc;
logic [1:0]         ResultSrc;

//Ouputs of Datapath
logic               Zero;   
logic               Less;
logic               LessU;  

PC PC(
    .clk        (clk),
    .rst        (rst),
    .PCsrc      (PCsrc),
    .ImmExt     (ImmExt),
    .PC_out     (InstrAdd),
    .inc_PC     (inc_PC),
    .PCTarget   (PCTarget)
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
    //Outputs
    .ImmSrc     (ImmSrc),
    .PCSrc      (PCsrc),
    .ALUsrc     (ALUsrc),
    .ALUctrl    (ALUctrl),
    .RegWrite   (RegWrite),
    .MemWrite   (MemWrite),
    .ResultSrc  (ResultSrc)
);

sign_ext sign_ext(
    .ImmSrc     (ImmSrc),
    .Instr      (instr),
    .ImmExt     (ImmExt)
);

datapath datapath(
    .clk        (clk),
    //Inputs from CU
    .RegWrite   (RegWrite),
    .MemWrite   (MemWrite),
    .ALUctrl    (ALUctrl),
    .ALUsrc     (ALUsrc),
    .funct3_i   (instr[14:12]),
    .rs1        (instr[19:15]),
    .rs2        (instr[24:20]),
    .rd         (instr[11:7]),
    //Inputs from sign_ext
    .ImmExt     (ImmExt),
    //Inputs from PC
    .inc_PC     (inc_PC),
    .PCTarget   (PCTarget),
    //Ouputs
    .Zero       (Zero),
    .Less       (Less),
    .LessU      (LessU),
    .a0         (a0)
);


assign TriggerOutput = TRIGGERSEL ? ReadData : ALUout; //trigger mux

endmodule
