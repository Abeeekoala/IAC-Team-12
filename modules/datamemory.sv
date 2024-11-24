module dataMem #(
    parameter DATA_WIDTH = 32,  
              ADDR_WIDTH = 5   // Address width (e.g., 5 bits -> 32 locations)
) (
    input logic clk,                          
    input logic write_en,                    
    input logic [ADDR_WIDTH-1:0] a,           
    input logic [DATA_WIDTH-1:0] write_data,  // Data to write into memory
    output logic [DATA_WIDTH-1:0] read_data   
);

    // Memory array: 2^ADDR_WIDTH locations, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];


    assign read_data = mem[a];

    always_ff @(posedge clk) begin
        if (write_en) begin
            mem[a] <= write_data;
        end
    end

endmodule
