module  PC (
    input logic                 rst,                //rst
    input logic                 clk,                //synchronous   
    input logic     [31:0]      ImmExt,              //immediate operand to calc branch target
    input logic                 PCSrc,              //control signal to choose between branch and incremented PC
    input logic     [31:0]      rs1,
    input logic                 PCTarget_sel,       //select between rs1 or PC_out
    output logic    [31:0]      PC_out,             //current PC value
    output logic    [31:0]      inc_PC,             //going into result mux
    output logic    [31:0]      PCTarget            //going into result mux
);

logic [31:0]            next_PC;                    //intermediate signal
logic [31:0]            PCTarget_in0;

Adder PCPlus4_Adder(
    .in0    (PC_out),
    .in1    (32'h0004),
    .out    (inc_PC)
);
mux PCTarget_in0_mux(
    .in0    (PC_out),
    .in1    (rs1),
    .sel    (PCTarget_sel),
    .out    (PCTarget_in0)
);

Adder PCTarget_Adder(
    .in0    (PCTarget_in0),
    .in1    (ImmExt),
    .out    (PCTarget)
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
    .next_PC    (next_PC),
    .PC         (PC_out)
);

endmodule
