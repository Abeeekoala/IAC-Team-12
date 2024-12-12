module regfile #(
    parameter   ADDR_WIDTH = 5,          //a0_width = 5
                DATA_WIDTH = 32
)(
    input logic [ADDR_WIDTH-1:0]    ra1A, ra2A, ra1B , ra2B,     //read addresses
    input logic [ADDR_WIDTH-1:0]    waA, waB,             //data address
    input logic                WEA,            //write enable
    input logic                WEB,            //write enable
    input logic                WD3,           //write data
    input logic                WD6,           //write data
    output logic [DATA_WIDTH-1:0]   RD1A, RD2A, RD1B, RD2B,  //read data
    output logic                    a0
);

logic [DATA_WIDTH-1:0] regfile_array [2**ADDR_WIDTH-1:0];

//read ports should be asynchronous
always_comb begin
        RD1A = regfile_array[ra1A];
        RD2A = regfile_array[ra2A];
        RD1B = regfile_array[ra1B];
        RD2B = regfile_array[ra2B];
        a0 = regfile_array[{5'b00000}];         //hardcoded for register a0
    end

always_ff @(posedge clk)
    begin
        if(WEA == 1'b1 && waA != 5'b00000)   //write to A3 if enabled and not register 0
            regfile_array[waA] <= WD3;

        if(WEB ==1'b1 && waB != 5'b00000)    //write to A6 if enabled and not register 0
            regfile_array[waB] <= WD6;
    end

endmodule

