module Adder(
    input logic [31:0]                in0,
    input logic [31:0]                in1,
    output logic[31:0]                out 
);

always_comb begin
    out = in0 + in1;
end

endmodule
