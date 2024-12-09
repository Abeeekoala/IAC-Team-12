module dataMemory #(
    parameter DATA_WIDTH = 32,  
) (
    input logic clk,                    // Clock signal
    input logic trigger,
    input logic fetch,                  // Fetch data from main memory
    input logic writeback,              // Write-back from cache to main memory
    input logic [DATA_WIDTH-1:0] A,     // Memory read address
    input logic [DATA_WIDTH-1:0] WB_addr.
    input logic [DATA_WIDTH-1:0] WB_DATA, // Data to write back to memory
    output logic [DATA_WIDTH-1:0] RD    // Read data output
);

    // Memory array: 2^18 locations, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:2**18-1];

    initial begin
        $readmemh("data.hex", mem, 32'h00010000);
        $display("Data Memory Contents After Initialization:");
        $display("mem[0] = %h", mem[32'h00010000]);
        $display("mem[1] = %h", mem[32'h00010001]);
        $display("mem[2] = %h", mem[32'h00010002]);
        $display("mem[3] = %h", mem[32'h00010003]);
    end

    // Read logic for load instructions
    always_comb begin
        RD = '0;
        if (A == 32'h000000FC) begin
            // Direct MMIO read, ignore "fetch" in this case.
            RD = {31'b0, trigger};
        end
        else if (fetch) begin
            RD = mem[A];  // Fetch whole data from memory
        end
    end

    // Write logic for store and write-back instructions
    always_ff @(posedge clk) begin
        if (writeback) begin
            mem[WB_addr] <= WB_DATA;  // Write-back to main memory
        end
    end

endmodule
