module hazard_unit(
    input logic [4:0]       Rs1D,
    input logic [4:0]       Rs2D,
    input logic [4:0]       Rs1E,
    input logic [4:0]       Rs2E,
    input logic [4:0]       RdM,
    input logic [4:0]       RdW,
    input logic             MemRead,
    input logic             RegWriteM,
    input logic             RegWriteW,
    output logic [1:0]      ForwardAE,
    output logic [1:0]      ForwardBE,
    output logic [1:0]      Forward,
    output logic            stall,
    output logic            flush
);

    //data hazard
always_comb begin

    //initialise signals

    stall = 1'b0;
    flush = 1'b0;
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    //read after write hazard -> Forwarding
    // 00: RD2E: no forwarding
    // 01: resultW : forwarding from EX/MEM after data mem
    // 10: ALUResultM: forwarding from MEM/WB (after ALU)

    if (RegWriteM && (RdM != 0) && (RdM == Rs1E)) begin
        ForwardAE = 2'b10;
    end
    else if (RegWriteW && (RdW != 0) && (RdW == Rs1E)) begin
        ForwardAE = 2'b01;
    end
    else begin
        ForwardAE = 2'b00;
    end
    

    //forwardB
    // 00: RD2E no forwarding
    // 01: ResultW forwarding from EX/MEM (after data mem)
    // 10: ALUresultM forwarding MEM/WB after ALU

    if(RegWriteM && (RdM != 0) && (RdM == Rs2E)) begin
        ForwardBE = 2'b10;
    end
    else if (RegWriteM && (RdW != 0) && (RdW == Rs2E)) begin
        ForwardBE = 2'b01;
    end
    else begin
        ForwardBE = 2'b00;
    end

    //regwrite = regwrite
    //write reg = rd
    //registerrs = rs1
    //registerrt = rs2

    //load word data dependency hazard = stalling

    //is instruction in the execute stage a load word
    //is the instruction in the execute stage the same register as the instruction in the ID
    //if both true, then stall the pipeline

    if (MEmReadE && ((RD2E == Rs1D) | (RD2E == Rs2D))) begin
        stall = 1'b1;
    end
    else begin
        stall = 1'b0;
    end

    //control hazard
    //branch taken, JAL, JALR = flush the pipeline
    //if not taken, dont do anything

    //branch detected in the ? stage
    //assume branch is taken
    //let pipeline continue
    //if branch taken, then flush the instructions in the pipeline datapath (3-4 cycles)
    //flush by setting the control lines to 0 when they reach the execute stage 

    if (branch) begin
        flush = 1;
    end
end


endmodule
