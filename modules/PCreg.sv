//let new PC instruction be stored within registers and be implemented within next clock cycle
module PCreg (
    input logic [31:0]          next_PC,        //next program counter value
    input logic                 rst,            //rst
    input logic                 clk,            //clock signal
    output logic [31:0]         PC              //output current PC stored in reg
);

logic [31:0] sreg;                              //internal storage reg for current PC value

always_ff @(posedge clk or posedge rst)
    if (rst)
        sreg <= 32'b0;                        //if rst high, update to 0
    else 
        sreg <= next_PC;                      //otherwise load next value 
    

assign PC = sreg;                               //give output PC to value in sreg

endmodule
