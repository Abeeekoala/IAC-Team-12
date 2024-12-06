module hazard_unit(      
    input logic [4:0]       Rs1E,           //reg1 to take in execution stage
    input logic [4:0]       Rs2E,           //reg2 to take in execution stage
    input logic [4:0]       RdM,            //desination reg from memory stage
    input logic [4:0]       RdW,            //destination reg from write back stage   
    input logic             RegWriteM,      //if instruction in mem/wb stage writes to reg 
    input logic             RegWriteW,
    input logic             LoadM,          //LSB of ResultSrcM
    input logic             PCsrc,          //If jump/Branch happen
    output logic [1:0]      ForwardA,      //forward signals for SrcA and SrcB inputs
    output logic [1:0]      ForwardB,        
    output logic            Stall,          //stall if data hazard
    output logic            Flush           //flush if control hazard
);

    //data hazard
always_comb begin

    //defauly outputs
    Stall = 1'b0;
    Flush = PCSrc ? 1'b1: 1'b0; // Flush if jumping happen (next PC not PC+4)
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    //forwarding for Rs1E

    if (RegWriteM && (RdM == Rs1E)) begin
        if (!LoadM)
            ForwardA = 2'b10; //forward from MEM stage if not Load; result ready as ALUoutM
        else
            Stall = 1'b1;
    end
    else if (RegWriteW && (RdW == Rs1E)) begin
        ForwardA = 2'b01; //forward from WB stage
    end

    //forward for Rs2E

    if(RegWriteM && (RdM == Rs2E)) begin
        if (!LoadM)
            ForwardB = 2'b10; //forward from MEM stage if not Load; result ready as ALUoutM
        else
            Stall = 1'b1;
    end
    else if (RegWriteM && (RdW == Rs2E)) begin
        ForwardB = 2'b01; //forward from WB stage
    end

end


endmodule
