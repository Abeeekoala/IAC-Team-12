//represent the mux switching between jump and branch

module countermux #(
    input logic [31:0]          PC,             //current PC value
    input logic [31:0]          ImmOp,          //immediate operand (offset) for branching
    input logic                 PCscr,          //control signal to select between branch and reg. increment
    output logic    [31:0]      next_PC         //output for next program counter value
);  

logic   [31:0]          branch_PC;              //intermediate signal to store calc. branch target address 
logic   [31:0]          inc_PC;                 //store next sequential PC (increment by 4)

assign branch_PC = PC_in + ImmOp;               //calc branch target address by adding ImmOp to current PC
assign inc_PC = PC_in + 32'b100;                //calc next sequential PC by incrementing current PC by 4
assign next_PC = PCscr ? branch_PC : inc_PC;    //choose between branch/inc based on PCscr
                                                //if low (0) choose inc_PC (reg increment)
endmodule