module RegFile #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5,
    parameter REG_DEPTH = 32
) (
    input  logic                    clk,
    input  logic [ADDR_WIDTH-1:0]   ad1,
    input  logic [ADDR_WIDTH-1:0]   ad2,
    input  logic [ADDR_WIDTH-1:0]   ad3,
    input  logic                    we3,
    input  logic [DATA_WIDTH-1:0]   wd3,
    output logic [DATA_WIDTH-1:0]   rd1,
    output logic [DATA_WIDTH-1:0]   rd2,
    output logic [DATA_WIDTH-1:0]   a0
);

    logic [DATA_WIDTH-1:0] registers [0:REG_DEPTH-1];

    assign rd1 = registers[ad1];
    assign rd2 = registers[ad2];
    assign a0  = registers[10];

    always_ff @(posedge clk) begin
        if (we3) begin
            registers[ad3] <= wd3;
        end
    end

endmodule
