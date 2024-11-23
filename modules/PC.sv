module  PC (
    input logic     [31:0]      ImmOp,              //immediate operand to calc branch target
    input logic                 rst,                //rst
    input logic                 PCsrc,              //control signal to choose between branch and incremented PC
    input logic                 clk,                //synchronous   
    output logic    [31:0]      PC_out              //current PC value
);

logic [31:0]            next_PC;                    //intermediate signal

countermux countermux(
    // Inputs
    .PC_in (PC_out),
    .ImmOp (ImmOp),
    .PCsrc (PCsrc),
    // Outputs
    .next_PC (next_PC)
    
);

PCreg PCreg(
    .clk        (clk),
    .rst        (rst),
    .next_PC    (next_PC),
    //Outputs
    .PC         (PC_out)
);

endmodule
