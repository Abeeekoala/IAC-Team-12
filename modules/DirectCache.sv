module DirectCache #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic WE, // Data to be written to cache
    input logic  [DATA_WIDTH-1:0] CacheMissData_RMM, // Cache Misses so is returned data from main memory
    input logic [DATA_WIDTH-1:0 ]address, 


    output logic [DATA_WIDTH-1:0] CacheData, // Cache Data
    output logic hit, //Cache Hit/Miss signal 
);

typedef struct packed {
    logic ValitdityBit;
    logic [26:0] tag;
    logic [DATA_WIDTH-1:0] data; 
    
} CacheType;

CacheType cache [8]; // define 8 set cache

//cache read

logic [DATA_WIDTH-1:0] RD;
logic [26:0] tag;
logic [2:0] set;

always_comb begin
    tag = address[31:5];
    set = address[4:2];

end

//cache write
    
endmodule
