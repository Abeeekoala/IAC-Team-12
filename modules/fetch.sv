module fetch (
    input logic             clk,
    input logic             rst,
    input logic             PCSrc,
    input logic [31:0]      PCTarget,
    input logic             Stall,
    input logic             Flush,
    output logic [31:0]     InstrD,
    output logic [31:0]     PCD,
    output logic [31:0]     inc_PCD
);

wire [31:0]         PCNext;
wire [31:0]         PC;
wire [31:0]         inc_PC;
wire [31:0]         InstrF;
wire [31:0]         Instr;

mux PC_mux(
    .in0        (inc_PC),
    .in1        (PCTarget),
    .sel        (PCSrc),
    .out        (PCNext)
);

PCreg PCreg(
    .next_PC    (PCNext),
    .rst        (rst),
    .clk        (clk),
    .Stall      (Stall),
    .PC         (PC)
);

Adder PC_inc_adder(
    .in0        (PC),
    .in1        (32'h0004),
    .out        (inc_PC)
);

InstrMem InstrMem(
    .addr       (PC),
    .instr      (InstrF)
);

mux FLush_mux(
    .in0        (InstrF),
    .in1        (32'h0000),   //nop
    .sel        (Flush),
    .out        (Instr)
);

ff1 FD_FF(
    .clk        (clk),
    .InstrF     (Instr),
    .PCF        (PC),
    .inc_PCF    (inc_PC),
    .Stall      (Stall),
    .InstrD     (InstrD),
    .PCD        (PCD),
    .inc_PCD    (inc_PCD)
);

endmodule
