module  PC (
    input logic                 rst,                //rst
    input logic                 clk,                //synchronous   
    input logic                 PCSrc,              //control signal to choose between branch and incremented PC
    input logic     [31:0]      PCTarget,
    input logic                 Stall,
    output logic    [31:0]      PC_out,             //current PC value
    output logic    [31:0]      inc_PC             //going into result mux
);

wire [31:0]            next_PC;                    //intermediate signal

Adder PCPlus4_Adder(
    .in0    (PC_out),
    .in1    (32'h0004),
    .out    (inc_PC)
);

mux PCNext_mux(
    .in0    (inc_PC),
    .in1    (PCTarget),
    .sel    (PCSrc),
    .out    (next_PC)
);

PCreg PCreg(
    .clk        (clk),
    .rst        (rst),
    .Stall      (Stall)
    .next_PC    (next_PC),
    .PC         (PC_out)
);

branchprediction BPU(
    .clk        (clk),
    .rst        (rst),
    .
)

endmodule
