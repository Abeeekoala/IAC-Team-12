module top #(
    parameter WIDTH = 32
)(
    input logic clk,
    input logic rst,
    output logic [WIDTH-1:0] a0
);

    // Pipelining registers and signals

    // Fetch Stage (IF)
    logic [WIDTH-1:0] PC_F, PCnext, instr_F, PCP4_F;
    
    // Decode Stage (ID)
    logic [WIDTH-1:0] instr_D, PC_D, PCP4_D, ImmExt_D, RD1_D, RD2_D;
    logic [4:0] Rs1_D, Rs2_D, Rd_D;
    logic [2:0] ImmSrc_D, PCsrc_D, AddrMode_D;
    logic [3:0] ALUctrl_D;
    logic [1:0] ResultSrc_D;
    logic ALUsrc_D, RegWrite_D, MemWrite_D, MemRead_D;

    // Execute Stage (EX)
    logic [WIDTH-1:0] SrcA_E, SrcB_E, ALUResult_E, WriteData_E, PC_E, PCP4_E, ImmExt_E;
    logic [4:0] Rd_E, Rs1_E, Rs2_E;
    logic Zero_E, RegWrite_E, MemWrite_E, MemRead_E, ALUsrc_E;
    logic [2:0] PCsrc_E, AddrMode_E;
    logic [3:0] ALUctrl_E;
    logic [1:0] ResultSrc_E;

    // Memory Stage (MEM)
    logic [WIDTH-1:0] ALUResult_M, WriteData_M, ReadData_M, PCP4_M;
    logic [4:0] Rd_M;
    logic [2:0] AddrMode_M;
    logic [1:0] ResultSrc_M;
    logic RegWrite_M, MemWrite_M, MemRead_M;

    // Writeback Stage (WB)
    logic [WIDTH-1:0] Result_W, ALUResult_W, ReadData_W, PCP4_W;
    logic [4:0] Rd_W;
    logic [1:0] ResultSrc_W;
    logic RegWrite_W;

    // Hazard Signals
    logic [1:0] forwardA_E, forwardB_E;
    logic stall, flush, branch;

    // FETCH STAGE
    assign PCP4_F = PC_F + 4;  // PC increment by 4
    pcnext_selector #(WIDTH) pcnext_selector_inst (
        .in0(PCP4_F),                   // Default incremented PC
        .in1(PC_E + ImmExt_E),          // Branch address
        .in2(ALUResult_E),              // Jump register
        .EQ(Zero_E),
        .PCsrc(PCsrc_E),
        .branch(branch),
        .out(PCnext)                    // Chosen PC
    );

    program_counter program_counter_inst (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .PCnext(PCnext),
        .PC(PC_F)
    );

    instr_mem instr_mem_inst (
        .A(PC_F),
        .RD(instr_F)  // Instruction fetched
    );

    pipeline_IF_ID pipeline_IF_ID_inst (
        .clk(clk),
        .flush(flush),
        .stall(stall),
        .instr_F(instr_F),
        .PC_F(PC_F),
        .PCP4_F(PCP4_F),
        .instr_D(instr_D),
        .PC_D(PC_D),
        .PCP4_D(PCP4_D)
    );

    // DECODE STAGE
    control_unit control_unit_inst (
        .instr(instr_D),
        .stall(stall),
        .AddrMode(AddrMode_D),
        .RegWrite(RegWrite_D),
        .MemWrite(MemWrite_D),
        .MemRead(MemRead_D),
        .ALUctrl(ALUctrl_D),
        .ALUsrc(ALUsrc_D),
        .ImmSrc(ImmSrc_D),
        .PCsrc(PCsrc_D),
        .ResultSrc(ResultSrc_D)
    );

    sign_extend sign_extend_inst (
        .instr(instr_D),
        .ImmSrc(ImmSrc_D),
        .ImmOp(ImmExt_D)
    );

    assign Rs1_D = instr_D[19:15];
    assign Rs2_D = instr_D[24:20];
    assign Rd_D = instr_D[11:7];

    regfile regfile_inst (
        .clk(clk),
        .AD1(Rs1_D),
        .AD2(Rs2_D),
        .AD3(Rd_W),
        .WE3(RegWrite_W),
        .WD3(Result_W),
        .RD1(RD1_D),
        .RD2(RD2_D),
        .a0(a0)
    );

    pipeline_ID_EX pipeline_ID_EX_inst (
        .clk(clk),
        .flush(flush),
        .LWflush(stall),
        .RD1_D(RD1_D),
        .RD2_D(RD2_D),
        .PC_D(PC_D),
        .Rs1_D(Rs1_D),
        .Rs2_D(Rs2_D),
        .Rd_D(Rd_D),
        .ImmExt_D(ImmExt_D),
        .PCP4_D(PCP4_D),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .PC_E(PC_E),
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .Rd_E(Rd_E),
        .ImmExt_E(ImmExt_E),
        .PCP4_E(PCP4_E),
        .RegWrite_D(RegWrite_D),
        .ResultSrc_D(ResultSrc_D),
        .MemWrite_D(MemWrite_D),
        .MemRead_D(MemRead_D),
        .AddrMode_D(AddrMode_D),
        .PCsrc_D(PCsrc_D),
        .ALUctrl_D(ALUctrl_D),
        .ALUsrc_D(ALUsrc_D),
        .RegWrite_E(RegWrite_E),
        .ResultSrc_E(ResultSrc_E),
        .MemWrite_E(MemWrite_E),
        .MemRead_E(MemRead_E),
        .AddrMode_E(AddrMode_E),
        .PCsrc_E(PCsrc_E),
        .ALUctrl_E(ALUctrl_E),
        .ALUsrc_E(ALUsrc_E)
    );

    // EXECUTE STAGE
    mux4 #(WIDTH) mux_hazard_A_inst (
        .in0(RD1_E),
        .in1(Result_W),
        .in2(ALUResult_M),
        .in3(0),
        .sel(forwardA_E),
        .out(SrcA_E)
    );

    mux4 #(WIDTH) mux_hazard_B_inst (
        .in0(RD2_E),
        .in1(Result_W),
        .in2(ALUResult_M),
        .in3(0),
        .sel(forwardB_E),
        .out(WriteData_E)
    );

    mux #(WIDTH) mux_alu_inst (
        .in0(WriteData_E),
        .in1(ImmExt_E),
        .sel(ALUsrc_E),
        .out(SrcB_E)
    );

    alu alu_inst (
        .a(SrcA_E),
        .b(SrcB_E),
        .ALUctrl(ALUctrl_E),
        .EQ(Zero_E),
        .ALUout(ALUResult_E)
    );

    pipeline_EX_MEM pipeline_EX_MEM_inst (
        .clk(clk),
        .ALUResult_E(ALUResult_E),
        .WriteData_E(WriteData_E),
        .Rd_E(Rd_E),
        .PCP4_E(PCP4_E),
        .ALUResult_M(ALUResult_M),
        .WriteData_M(WriteData_M),
        .Rd_M(Rd_M),
        .PCP4_M(PCP4_M),
        .RegWrite_E(RegWrite_E),
        .MemRead_E(MemRead_E),
        .ResultSrc_E(ResultSrc_E),
        .MemWrite_E(MemWrite_E),
        .AddrMode_E(AddrMode_E),
        .RegWrite_M(RegWrite_M),
        .MemRead_M(MemRead_M),
        .ResultSrc_M(ResultSrc_M),
        .MemWrite_M(MemWrite_M),
        .AddrMode_M(AddrMode_M)
    );

    // MEMORY AND WRITEBACK OMITTED FOR SPACE
    // Extend in a similar fashion as earlier.
    
endmodule
