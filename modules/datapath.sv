module datapath #(
    parameter A_WIDTH = 5,
              D_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  write_en,
    input  logic                  regWrite,
    input  logic                  muxSelect,
    input  logic [2:0]            ALUctrl,
    input  logic [A_WIDTH-1:0]    rs1,
    input  logic [A_WIDTH-1:0]    rs2,
    input  logic [A_WIDTH-1:0]    rd,
    input  logic                  ALUsrc,
    input  logic [D_WIDTH-1:0]    ImmOp,
    output logic                  eq,
    output logic [D_WIDTH-1:0]    a0,
    output logic [D_WIDTH-1:0]    result
);

    logic [D_WIDTH-1:0] regOp2;
    logic [D_WIDTH-1:0] ALUop1;
    logic [D_WIDTH-1:0] ALUop2;
    logic [D_WIDTH-1:0] ALUout;
    logic [D_WIDTH-1:0] ReadData;

    dataMem dataMem(
        .clk    (clk),
        .write_en   (write_en),
        .write_data (rd2),
        .a      (ALUout), 
        .read_data  (ReadData),
    );

    ALU ALU (
        .ALUop1  (ALUop1),
        .ALUop2  (ALUop2),
        .ALUctrl (ALUctrl),
        .eq      (eq),
        .ALUout  (ALUout)
    );

    regfile regfile (
        .clk  (clk),
        .ad1  (rs1),
        .ad2  (rs2),
        .ad3  (rd),
        .we3  (regWrite),
        .wd3  (ALUout),
        .a0   (a0),
        .rd1  (ALUop1),
        .rd2  (regOp2)
    );

    mux muxMem(
        .in0 (ALUout),
        .in1 (ReadData),
        .sel (muxSelect),
        .out (result)
    );

    mux muxALU (
        .in0 (regOp2),
        .sel (ALUsrc),
        .in1 (ImmOp),
        .out (ALUop2)
    );

endmodule
