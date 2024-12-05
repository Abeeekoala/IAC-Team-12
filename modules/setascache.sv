module setascache #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic WE,//Write Enable
    input logic [DATA_WIDTH-1:0] WD,//Write Data
    input logic [DATA_WIDTH-1:0] A, //Address
    output logic hit, //Cache Hit/Miss signal 
    output logic [DATA_WIDTH-1:0] DATA_OUT; // read data
);

typedef struct packed {
    logic U; // least recently used bit --1 = way 1 0 = way 2
    //way 1 
    logic ValitdityBit1;
    logic [27:0] tag1;
    logic [DATA_WIDTH-1:0] data1; 
    //way 2
    logic ValitdityBit2;
    logic [27:0] tag2;
    logic [DATA_WIDTH-1:0] data2; 
} CacheType;

CacheType cache [4]; // define 4 set 2 way associative cache

//vars
logic [27:0] tag;
logic [1:0] set;

always_comb begin
    tag = A[31:5];
    set = A[4:3];

    if(cache[set].ValitdityBit1 && (cache[set].tag1 == tag) ) begin
        hit = 1;
        DATA_OUT = cache[set].data1;
        cache[set].U = 1;
    end
    else if(cache[set].ValitdityBit2 && (cache[set].tag2 == tag) ) begin
        hit = 1;
        DATA_OUT = cache[set].data2;
        cache[set].U = 1;
    end
    else begin
        hit = 0;
        DATA_OUT = 32b'0; //placeholder as won't be used due to hit = 0
    end

end

//cache write
always_ff @(posedge clk) begin
        if (WE && !hit) begin
            if (cache[set].U == 0) begin
                cache[set].ValidityBit1 <= 1;
                cache[set].tag1 <= tag;
                cache[set].data1 <= RD;
                cache[set].U <= 1;                   
            end else begin
                cache[set].ValidityBit2 <= 1;
                cache[set].tag2 <= tag;
                cache[set].data2 <= RD;
                cache[set].U <= 0;                   
            end
        end
    end

endmodule
