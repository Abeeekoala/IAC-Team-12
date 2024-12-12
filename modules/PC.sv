module  PC (
    input logic                 rst,                //rst
    input logic                 clk,                //synchronous   
    input logic                 PCSrc,              //control signal to choose between branch and incremented PC
    output logic    [31:0]      PC_out,             //current PC value
    output logic    [31:0]      PC_out2,            //second instruction address
    output logic    [31:0]      inc_PC             //going into result mux
);

wire [31:0]             next_PC;                    //intermediate signal
wire [31:0]             pc_plus_4;
wire [31:0]             pc_plus_8;

Adder PCPlus4_Adder(
    .in0    (PC_out),
    .in1    (32'h0004),
    .out    (pc_plus_4)
);

Adder PCPlus8_Adder(
    .in0    (PC_out),
    .in1    (32'h0008),
    .out    (pc_plus_8)
);

Adder PCIncr(
    .in0    (PC_out),
    .in1    (PC_4_or_8),
    .out    (PCIncr)
);

//choose between PC + 4 or PC + 8 (increment PC solution)
assign inc_PC = (dual_fetch) ? pc_plus_8 : pc_plus_4;

mux PCNext_mux(
    .in0    (PC_4_or_8),
    .in1    (PC_out),
    .sel    (PCSrc),
    .out    (next_PC)
);

mux PCPlus_4_or_8(
    .in0    (pc_plus_4),
    .in1    (pc_plus_8),
    .sel    (IncrSrc),
    .out    (PC_4_or_8)
);

PCreg PCreg(
    .clk        (clk),
    .rst        (rst),
    .next_PC    (next_PC),
    .PC         (PC_out)
);

assign dual_fetch = 1'b1;
//output 2nd PC value if needed for dual fetched scenario
assign PC_out2 = (dual_fetch) ? pc_plus_8 : pc_plus_4;

endmodule
