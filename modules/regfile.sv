module regfile #(
    parameter ADDR_WIDTH = 16,
    DATA_WIDTH = 32
)(
    input logic                     clk,
    input logic [ADDR_WIDTH-1:0]    A1,
    input logic [ADDR_WIDTH-1:0]    A2,
    input logic [ADDR_WIDTH-1:0]    A3,
    input logic                     WE3, //write enable
    input logic [DATA_WIDTH-1:0]    WD3,
    output logic [DATA_WIDTH-1:0]   RD1,
    output logic [DATA_WIDTH-1:0]   RD2,
    output logic [DATA_WIDTH-1:0]   a0
);

logic [DATA_WIDTH-1:0] regfile_array [2**ADDR_WIDTH-1:0]

//read ports should be asynchronous
always_ff @ *
    begin
        RD1 = regfile_array[A1];
        RD2 = regfile_array[A2];
    end

always_ff @(posedge clk)
    begin
        if(WE3 == 1'b1)
            regfile_array[A3] <= WD3;
    end

    //synchronous
    assign a0 = regfile_array[{16'b01010}];

endmodule

