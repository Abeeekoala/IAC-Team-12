module  PC #(
    input logic     [31:0]      ImmOp,              //immediate operand to calc branch target
    input logic                 rst,                //rst
    input logic                 PCscr,              //control signal to choose between branch and incremented PC
    input logic                 clk,                //synchronous   
    output logic    [31:0]      PC                  //current PC value
);

logic [31:0]            next_PC;                    //intermediate signal

countermux countermux(
    .PC (PC),
    .ImmOp (ImmOp),
    .next_PC (next_PC),
    .PCscr (PCscr)
);

PCreg PCreg(
    .rst(rst),
    .next_PC(next_PC),
    .PC (PC)
);

endmodule