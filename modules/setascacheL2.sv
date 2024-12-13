module setascacheL2 #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic WE,                  // Write Enable (for stores)
    input logic [DATA_WIDTH-1:0] RD,  // Read Date from memory
    input logic [DATA_WIDTH-1:0] WD, // Write Data
    input logic [DATA_WIDTH-1:0] A,  // Address
    input logic Read,
    input logic [DATA_WIDTH-1:0] preload_data,  // for preloading data from main memory, for spacial locality
    input logic [2:0] funct3,        // Load/Store type
    output logic stall,              // Pipeline stall for cache miss
    output logic hit,                // Cache Hit/Miss signal
    output logic fetch,              // Signal to fetch data from memory
    output logic [DATA_WIDTH-1:0] preload_addr,          // preload addr
    output logic writeback,          // Writeback to main memory for dirty eviction
    output logic [DATA_WIDTH-1:0] WB_DATA,  // Writeback data to memory
    output logic [DATA_WIDTH-1:0] WB_addr,  
    output logic [DATA_WIDTH-1:0] DATA_OUT,  // Data to the CPU
    //L2 Control signals
    input logic L2_fetch,
    input logic L2_writeback,
    input logic [DATA_WIDTH-1:0] L2_WB_DATA,
    input logic [DATA_WIDTH-1:0] L2_WB_ADDR
);

    typedef struct packed {
        logic U; // LRU bit -- 1 = [Way 0 recently used]; 0 = [Way 1 recently used] => should write to the other way
        // Way 1
        logic ValitdityBit1;
        logic DB1; // Dirty bit
        logic [26:0] tag1;
        logic [DATA_WIDTH-1:0] data1; 

        // Way 0
        logic ValitdityBit0;
        logic DB0; // Dirty bit
        logic [26:0] tag0;
        logic [DATA_WIDTH-1:0] data0; 
    } CacheType;

    CacheType cache [8]; // Define 8 sets, 2-way associative cache

    // Variables
    logic [26:0] tag;
    logic [2:0] set;
    logic [DATA_WIDTH-1:0] Data;
    logic MMIO_access;
    logic way_hit;

    // Address breakdown
    always_comb begin
        tag = A[31:5];  // Tag from address
        set = A[4:2];   // Set index from address
    end
    
    // register the fetch signal to prevent RD latching
    // use negative clock to insure We update cache on the next CLK posedge if miss
    logic fetch_reg;

    always_ff @(negedge clk or posedge rst) begin
        if (rst) begin
            fetch_reg <= 0;
        end else if (!hit && (Read || WE)) begin
            fetch_reg <= 1;
        end else begin
            fetch_reg <= 0; // clear fetch once the data is ready
        end
    end

    assign fetch = fetch_reg;

    // Cache Access Logic
    always_comb begin
        // Default outputs
        hit = 0;
        way_hit = 0;
        stall = 0;
        writeback = 0;
        MMIO_access = (A == 32'h000000FC);
        WB_DATA = '0;
        WB_addr = '0;
        DATA_OUT = '0;
        Data = '0;
        //local loading default
        preload_addr = A + 8; // add 8 as 8 cache blocks
        preloadE = 0;
        if (MMIO_access) begin
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
            else if (Read || WE) begin
                hit = 0;
                stall = 1;  // Stall the pipeline for a miss
                // Check if eviction is needed
                if (cache[set].U == 0) begin
                    // Evict way 0 if dirty
                    if (cache[set].DB0) begin
                        writeback = 1;
                        WB_addr = {cache[set].tag0, set, 2'b00};
                        WB_DATA = cache[set].data0;

                    end
                end else begin
                    // Evict way 1 if dirty
                    if (cache[set].DB1) begin
                        writeback = 1;
                        WB_addr = {cache[set].tag1, set, 2'b00};
                        WB_DATA = cache[set].data1;
                    end
                end
            end
        end
        // Output data (load instructions) given hit as otherwise data hasn't loaded
        if (Read && hit) begin
            DATA_OUT = Data; // Don't need case here as it will be written to L1 where load/store case logic handled
            end
    end

    // Write Policy: Write-back scheme with write-allocate
    // Cache Write Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all sets in the cache
            for (int i = 0; i < 8; i++) begin
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
            if (L2_writeback) begin
                if(way_hit==0)begin
                    cache[L2_WB_ADDR[4:2]].data0 <= L2_WB_DATA;
                    cache[L2_WB_ADDR[4:2]].DB0 <= 1;
                    cache[L2_WB_ADDR[4:2]].U <= 1
                end else begin
                    cache[L2_WB_ADDR[4:2]].data1 <= L2_WB_DATA;
                    cache[L2_WB_ADDR[4:2]].DB1 <= 1;
                    cache[L2_WB_ADDR[4:2]].U <= 0
                end
            end 
            if (hit) begin
                cache[set].U <= !(way_hit);
            end 

            if (hit && WE) begin // Memory block alr in cache either first time or write-allocate (stall & fetch & write -> hit & update/store)
                if (way_hit == 0) begin 
                    // Hit at Way 0; Write to way 0
                    case (funct3)
                        3'b000: begin // sb
                            case (A[1:0])
                                2'b00: cache[set].data0[7:0] <= WD[7:0];
                                2'b01: cache[set].data0[15:8] <= WD[7:0];
                                2'b10: cache[set].data0[23:16] <= WD[7:0];
                                2'b11: cache[set].data0[31:24] <= WD[7:0];       
                            endcase
                        end
                        3'b001: begin
                            if (A[1]) begin
                                cache[set].data0[31:16] <= WD[15:0];    // sh
                            end
                            else begin
                                cache[set].data0[15:0] <= WD[15:0];
                            end
                        end
                        3'b010: cache[set].data0 <= WD;                // sw
                    endcase
                    cache[set].DB0 <= 1; // Set dirty bit for Way 0
                    cache[set].U <= 1;
                end else begin
                    // Hit at Way 1; Write to Way 1
                    case (funct3)
                        3'b000: begin // sb
                            case (A[1:0])
                                2'b00: cache[set].data1[7:0] <= WD[7:0];
                                2'b01: cache[set].data1[15:8] <= WD[7:0];
                                2'b10: cache[set].data1[23:16] <= WD[7:0];
                                2'b11: cache[set].data1[31:24] <= WD[7:0];       
                            endcase
                        end
                        3'b001: begin
                            if (A[1]) begin
                                cache[set].data1[31:16] <= WD[15:0];    // sh
                            end
                            else begin
                                cache[set].data1[15:0] <= WD[15:0];
                            end
                        end
                        3'b010: cache[set].data1 <= WD;                // sw
                    endcase
                    cache[set].DB1 <= 1; // Set dirty bit for Way 1
                    cache[set].U <= 0;
                end
            end

            if (fetch) begin //Fetch from memory and write to Cache
                // Cache miss: fetch from memory 
                // Write to the Least recently used Way
                // Way 0
                if (fetch && ~hit) begin
                    preload_data = RDpre;
                end
                if (cache[set].U == 0) begin
                    // Clear dirty bit after writeback
                    if (cache[set].DB0) begin
                        cache[set].DB0 <= 0; 
                    end
                    cache[set].ValitdityBit0 <= 1;
                    cache[set].tag0 <= tag;
                    cache[set].data0 <= RD; // New data from memory
                    cache[set].U <= 1;      // Update LRU

                    //preload 
                    cache[set].ValitdityBit1 <= 1;
                    cache[set].tag1 <= tag + 1;
                    cache[set].data1 <= preload_data; // New data from memory
                    cache[set].U <= 1;
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
                    
                    //preload
                    cache[set].ValitdityBit0 <= 1;
                    cache[set].tag0 <= tag;
                    cache[set].data0 <= preload_data; // New data from memory
                    cache[set].U <= 1; 
                end
            end
        end
    end

endmodule


/// To change:

""" Current writeback logic insufficient add compatabilities with the L2 write logic defined in L1 for eviction and write to L2
Also add fetch logic to define a fetch from Datamem and have compatabilities with L2-fetch to decide when to fetch from data mem
"""