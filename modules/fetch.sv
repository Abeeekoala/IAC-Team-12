module fetch (
    input logic             clk,
    input logic             rst,
    input logic             PCSrc,
    input logic [31:0]      PCTarget,
    output logic [31:0]     InstrD,
    output logic [31:0]     PCD,
    output logic [31:0]     inc_PCD
);

wire [31:0]         PCNext;
wire [31:0]         PC;
logic [31:0]        inc_PC;
wire [31:0]         InstrF;

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

ff1 FD_FF(
    .clk        (clk),
    .InstrF      (InstrF),
    .PCF        (PC),
    .inc_PCF    (inc_PC),
    .InstrD     (InstrD),
    .PCD        (PCD),
    .inc_PCD    (inc_PCD)
);

endmodule
