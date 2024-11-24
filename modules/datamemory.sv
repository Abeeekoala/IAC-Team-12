module datamemory #(
    parameter DATA_WIDTH = 32,  
              ADDR_WIDTH = 5   // Address width (e.g., 5 bits -> 32 locations)
) (
    input logic clk,                          
    input logic WE,                    
    input logic [ADDR_WIDTH-1:0] A,           
    input logic [DATA_WIDTH-1:0] WD,  // Data to write into memory
    output logic [DATA_WIDTH-1:0] RD   
);

    // Memory array: 2^ADDR_WIDTH locations, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];


    assign read_data = mem[A];

    always_ff @(posedge clk) begin
        if (WE) begin
            mem[A] <= WD;
        end
    end

endmodule
