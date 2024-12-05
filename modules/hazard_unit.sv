module hazard_unit(
    input logic [4:0]       Rs1D,            //decode
    input logic [4:0]       Rs2D,            //decode
    input logic [4:0]       Rs1E,            //execute
    input logic [4:0]       Rs2E,            //execute
    input logic [4:0]       RdM,             //desination reg from memory stage
    input logic [4:0]       RdW,             //destination reg from write back stage   
    input logic             MemRead,         //if current instr in MEM stage is a load
    input logic             RegWriteM,       //if instruction in mem/wb stage writes to reg 
    input logic             RegWriteW,
    output logic [1:0]      ForwardAE,        //forward signal for SrcA and SrcB input
    output logic [1:0]      ForwardBE,        
    output logic            stall,            //stall if hazard
    output logic            flush             //flush if branch or control hazard
);

    //data hazard
always_comb begin

    //initialise signals to default (no forwarding no stall)

    stall = 1'b0;
    flush = 1'b0;
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;


    //forwarding for Rs1E

    if (RegWriteM && (RdM != 5'b00000) && (RdM == Rs1E)) begin
        ForwardAE = 2'b10; //forward from MEM stage
    end
    else if (RegWriteW && (RdW != 5'b00000) && (RdW == Rs1E)) begin
        ForwardAE = 2'b01; //forward from WB stage
    end
    else begin
        ForwardAE = 2'b00;
    end
    

    //forward for Rs2E

    if(RegWriteM && (RdM != 5'b00000) && (RdM == Rs2E)) begin
        ForwardBE = 2'b10; // forward from MEM stage
    end
    else if (RegWriteM && (RdW != 0) && (RdW == Rs2E)) begin
        ForwardBE = 2'b01; //forward from WB stage
    end
    else begin
        ForwardBE = 2'b00;
    end

    //load word data dependency hazard = stalling

    //is instruction in the execute stage a load word
    //is the instruction in the execute stage the same register as the instruction in the decode stage
    //if both true, then stall the pipeline

    //MemRead originates from control unit during decode stage
    //when control unit detectes load instruction, asserts MemRead signal
    //passes through registers from decode to execute, becoming MemReadE
    //MemReadE determines if current instruction in execute stage is a load, and could cause a load use hazard with instruction in decode stage

    if (MEmReadE && ((RD2E == Rs1D) | (RD2E == Rs2D))) begin //MEMReadE = load in execute stage
        stall = 1'b1; //if RD2E is source in decode stage then stall
    end
    else begin
        stall = 1'b0;
    end

    //control hazard
    //if branch taken, JAL, JALR = flush the pipeline
    //if not taken, dont do anything

    //branch detected in the ? stage
    //assume branch is taken
    //let pipeline continue
    //if branch taken, then flush the instructions in the pipeline datapath (3-4 cycles)
    //flush by setting the control lines to 0 when they reach the execute stage 

    if (branch) begin
        flush = 1;        //flush in branching to make sure pipeline doesn't execute wrong instr
    end
end


endmodule
