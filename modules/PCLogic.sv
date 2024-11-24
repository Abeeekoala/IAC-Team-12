module PCLogic(
    input logic         clk,
    input logic         rst,
    input logic         PCSrc,
    input logic [31:0]  ImmExt,
    output logic        PC
);

logic [31:0] PCNext, PCPlus4, PCTarget;

//PC Increment
assign PCPlus4 = PC + 4;

//branch target
assign PCNext = (PCSrc) ? PCTarget : PCPlus4;

//calculate branch/jump target
assign PCTarget = PC + ImmExt;

//PC Register
always_ff @(posedge clk or posedge rst) begin
    if(rst)
        PC <= 32'b0; //reset PC to 0
    else    
        PC <= PCNext; //update PC
end

endmodule