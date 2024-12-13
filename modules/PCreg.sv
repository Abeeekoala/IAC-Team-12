//let new PC instruction be stored within registers and be implemented within next clock cycle
module PCreg (
    input logic [31:0]          next_PC,        //next program counter value
    input logic                 rst,            //rst
    input logic                 clk,            //clock signal
    input logic                 stall_in,
    output logic [31:0]         PC              //output current PC stored in reg
);

logic [31:0] sreg;                              //internal storage reg for current PC value
logic hold;                                     //internal flag for reset hold PC at 0

always_ff @(posedge clk or posedge rst)
    if (rst) begin
        sreg <= 32'b0;                        //if rst high, update to 0
        hold <= 1'b1;                         // hold PC at 0 for a cycle
    end
    else if (hold) begin
        sreg <= 32'b0;                          // keep PC at 0 for one cycle
        hold <= 1'b0;                     // clear the hold_reset flag
    end
    else if (!stall_in)
        sreg <= next_PC;                      //load next value when not Stall 
    

assign PC = sreg;                               //give output PC to value in sreg

endmodule
