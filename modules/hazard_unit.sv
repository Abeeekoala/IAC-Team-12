module hazard_unit( 
    input logic             rst,
    input logic [4:0]       Rs1D,           //reg1 to take in decode stage
    input logic [4:0]       Rs2D,           //reg2 to take in decode stage     
    input logic [4:0]       Rs1E,           //reg1 to take in execution stage
    input logic [4:0]       Rs2E,           //reg2 to take in execution stage
    input logic [4:0]       RdE,            //desination reg from execution stage    
    input logic [4:0]       RdM,            //desination reg from memory stage
    input logic [4:0]       RdW,            //destination reg from write back stage   
    input logic             RegWriteM,      //if instruction in mem/wb stage writes to reg 
    input logic             RegWriteW,
    input logic             LoadE,          //LSB of ResultSrcM
    input logic             PCSrc,          //If jump/Branch happen
    output logic [1:0]      ForwardA,      //forward signals for SrcA and SrcB inputs
    output logic [1:0]      ForwardB,        
    output logic            Stall,          //stall if data hazard
    output logic            Flush           //flush if control hazard
);

    //data hazard
always_comb begin

    //default outputs
    Stall = 1'b0;
    Flush = (PCSrc || rst) ? 1'b1: 1'b0; // Flush if jumping happen (next PC not PC+4)
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    //forwarding for Rs1E

    if (RegWriteM && (RdM == Rs1E) && (Rs1E != 5'b00000)) begin
        ForwardA = 2'b10; //forward from MEM stage if not Load; result ready as ALUoutM
    end
    else if (RegWriteW && (RdW == Rs1E) && (Rs1E != 5'b00000)) begin
        ForwardA = 2'b01; //forward from WB stage
    end

    //forward for Rs2E

    if(RegWriteM && (RdM == Rs2E) && (Rs2E != 5'b00000)) begin
        ForwardB = 2'b10; //forward from MEM stage if not Load; result ready as ALUoutM
    end
    else if (RegWriteW && (RdW == Rs2E) && (Rs2E != 5'b00000)) begin
        ForwardB = 2'b01; //forward from WB stage
    end

    if(LoadE && ((RdE == Rs1D) || (RdE == Rs2D)))
        Stall = 1'b1;
end

endmodule
