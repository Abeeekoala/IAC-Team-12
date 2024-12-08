module setascache #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic WE,                  // Write Enable (for stores)
    input logic [DATA_WIDTH-1:0] RD  // Read Date from memory
    input logic [DATA_WIDTH-1:0] WD, // Write Data
    input logic [DATA_WIDTH-1:0] A,  // Address
    input logic [2:0] funct3,        // Load/Store type
    output logic stall,              // Pipeline stall for cache miss
    output logic hit,                // Cache Hit/Miss signal
    output logic fetch,              // Signal to fetch data from memory
    output logic writeback,          // Writeback to main memory for dirty eviction
    output logic [DATA_WIDTH-1:0] WB_DATA,  // Writeback data to memory
    output logic [DATA_WIDTH-1:0] WB_addr,
    output logic [DATA_WIDTH-1:0] DATA_OUT  // Data to the CPU
);

    typedef struct packed {
        logic U; // LRU bit -- 1 = [Way 0 recently used]; 0 = [Way 1 recently used] => should write to the other way
        // Way 1
        logic ValitdityBit1;
        logic DB1; // Dirty bit
        logic [27:0] tag1;
        logic [DATA_WIDTH-1:0] data1; 

        // Way 0
        logic ValitdityBit0;
        logic DB0; // Dirty bit
        logic [27:0] tag0;
        logic [DATA_WIDTH-1:0] data0; 
    } CacheType;

    CacheType cache [4]; // Define 4 sets, 2-way associative cache

    // Variables
    logic [27:0] tag;
    logic [1:0] set;
    logic [DATA_WIDTH-1:0] Data;
    logic MMIO_access;
    logic way_hit;

    // Address breakdown
    always_comb begin
        tag = A[31:5];  // Tag from address
        set = A[4:3];   // Set index from address
    end

    // Cache Access Logic
    always_comb begin
        // Default outputs
        hit = 0;
        stall = 0;
        fetch = 0;
        writeback = 0;
        MMIO_access = (A == 32'h000000FC);
        WB_DATA = '0;
        WB_addr = '0;
        
        if (MMIO_access) begin
            hit = 1;
            stall = 0;
            DATA_OUT = RD;
        end
        else begin
            // Check for a cache hit in either way
            // Way 0
            if (cache[set].ValitdityBit0 && (cache[set].tag0 == tag)) begin
                hit = 1;
                Data = cache[set].data0;
                way_hit = 0; // Update LRU
            end 
            // Way 1
            else if (cache[set].ValitdityBit1 && (cache[set].tag1 == tag)) begin
                hit = 1;
                Data = cache[set].data1;
                way_hit = 1; // Update LRU
            end 
            // Cache miss
            else begin
                hit = 0;
                stall = 1;  // Stall the pipeline for a miss
                fetch = 1;  // Fetch data from main memory
                // Check if eviction is needed
                if (cache[set].U == 0) begin
                    // Evict way 0 if dirty
                    if (cache[set].DB0) begin
                        writeback = 1;
                        WB_addr = {cache[set].tag0, set, 3'b000};
                        WB_DATA = cache[set].data0;

                    end
                end else begin
                    // Evict way 1 if dirty
                    if (cache[set].DB1) begin
                        writeback = 1;
                        WB_addr = {cache[set].tag1, set, 3'b000};
                        WB_DATA = cache[set].data1;
                    end
                end
            end
            // Output data (load instructions) given hit as otherwise data hasn't loaded
            if (!WE && hit) begin
                case (funct3)
                    3'b000: DATA_OUT = {{24{Data[7]}}, Data[7:0]};    // lb
                    3'b001: DATA_OUT = {{16{Data[15]}}, Data[15:0]};  // lh
                    3'b010: DATA_OUT = Data;                          // lw
                    3'b100: DATA_OUT = {24'b0, Data[7:0]};            // lbu
                    3'b101: DATA_OUT = {16'b0, Data[15:0]};           // lhu
                    default: DATA_OUT = 32'b0;                        // Default case
                endcase
            end
        end
    end

    // Write Policy: Write-back scheme with write-allocate
    // Cache Write Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all sets in the cache
            for (int i = 0; i < 4; i++) begin
                cache[i].U <= 0;
                cache[i].ValitdityBit0 <= 0;
                cache[i].ValitdityBit1 <= 0;
                cache[i].DB0 <= 0;
                cache[i].DB1 <= 0;
                cache[i].tag0 <= '0;
                cache[i].tag1 <= '0;
            end
        end 
        else begin
            //Update LRU bit
            if (hit) begin
                cache[set].U <= !(way_hit);
            end 

            if (hit && WE) begin // Memory block alr in cache either first time or write-allocate (stall & fetch & write -> hit & update/store)
                if (way_hit == 0) begin 
                    // Hit at Way 0; Write to way 0
                    case (funct3)
                        3'b000: cache[set].data0[7:0] <= WD[7:0];      // sb
                        3'b001: cache[set].data0[15:0] <= WD[15:0];    // sh
                        3'b010: cache[set].data0 <= WD;                // sw
                    endcase
                    cache[set].DB0 <= 1; // Set dirty bit for Way 0
                    cache[set].U <= 1;
                end else begin
                    // Hit at Way 1; Write to Way 1
                    case (funct3)
                        3'b000: cache[set].data1[7:0] <= WD[7:0];      // sb
                        3'b001: cache[set].data1[15:0] <= WD[15:0];    // sh
                        3'b010: cache[set].data1 <= WD;                // sw
                    endcase
                    cache[set].DB1 <= 1; // Set dirty bit for Way 1
                    cache[set].U <= 0;
                end
            end

            if (~hit && fetch) begin //Fetch from memory and write to Cache
                // Cache miss: fetch from memory 
                // Write to the Least recently used Way
                // Way 0
                if (cache[set].U == 0) begin
                    // Clear dirty bit after writeback
                    if (cache[set].DB0) begin
                        cache[set].DB0 <= 0; 
                    end
                    cache[set].ValitdityBit0 <= 1;
                    cache[set].tag0 <= tag;
                    cache[set].data0 <= RD; // New data from memory
                    cache[set].U <= 1;      // Update LRU
                end 
                // Way 1
                else begin
                    // Clear dirty bit after writeback
                    if (cache[set].DB1) begin
                        cache[set].DB1 <= 0; 
                    end
                    cache[set].ValitdityBit1 <= 1;
                    cache[set].tag1 <= tag;
                    cache[set].data1 <= RD; // New data from memory
                    cache[set].U <= 0;      // Update LRU
                end
            end
        end
    end

endmodule
