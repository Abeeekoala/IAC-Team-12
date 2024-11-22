module datapath #(
    parameter A_WIDTH = 5,
              D_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  regWrite,
    input  logic [2:0]            ALUctrl,
    input  logic [A_WIDTH-1:0]    rs1,
    input  logic [A_WIDTH-1:0]    rs2,
    input  logic [A_WIDTH-1:0]    rd,
    input  logic                  ALUsrc,
    input  logic [D_WIDTH-1:0]    ImmOp,
    output logic [D_WIDTH-1:0]    ALUout,
    output logic                  eq,
    output logic [D_WIDTH-1:0]    a0
);

    logic [D_WIDTH-1:0] regOp2;
    logic [D_WIDTH-1:0] ALUop1;
    logic [D_WIDTH-1:0] ALUop2;

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

    mux mux (
        .in0 (regOp2),
        .sel (ALUsrc),
        .in1 (ImmOp),
        .out (ALUop2)
    );

endmodule
