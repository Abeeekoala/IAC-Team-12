module  mux4 #(
    parameter   DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH - 1: 0]     in0,
    input logic [DATA_WIDTH - 1: 0]     in1,
    input logic [DATA_WIDTH - 1: 0]     in2,
    input logic [DATA_WIDTH - 1: 0]     in3,
    input logic [1:0]                   sel,
    output logic [DATA_WIDTH - 1: 0]    out 
)

logic [DATA_WIDTH - 1: 0] mux0_out;
logic [DATA_WIDTH - 1: 0] mux1_out;

mux mux0(
    .in0    (in0)
    .in1    (in1)
    .sel    (sel[0])
    .out    (mux0_out)
);

mux mux1(
    .in0    (in2)
    .in1    (in3)
    .sel    (sel[0])
    .out    (mux1_out)
);

mux muxMSB(
    .in0    (mux0_out)
    .in1    (mux1_out)
    .sel    (sel[1])
    .out    (mux1_out)
);


endmodule