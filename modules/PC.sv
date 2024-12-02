module  PC (
    input logic                 rst,                //rst
    input logic                 clk,                //synchronous   
    input logic     [31:0]      ImmExt,              //immediate operand to calc branch target
    input logic                 PCsrc,              //control signal to choose between branch and incremented PC
    output logic    [31:0]      PC_out,             //current PC value
    output logic    [31:0]      inc_PC,             //going into result mux
    output logic    [31:0]      PCTarget            //going into result mux
);

logic [31:0]            next_PC;                    //intermediate signal

Adder PCPlus4(
    .in0    (PC_out),
    .in1    (32'h0004),
    .out    (inc_PC)
);

Adder PCTarget(
    .in0    (PC_out),
    .in1    (ImmExt),
    .out    (PCTarget)
);

mux PCNext_mux(
    .in0    (inc_PC),
    .in1    (PCTarget),
    .sel    (PCSrc),
    .out    (PCNext)
);


PCreg PCreg(
    .clk        (clk),
    .rst        (rst),
    .next_PC    (next_PC),
    //Outputs
    .PC         (PC_out)
);

endmodule
