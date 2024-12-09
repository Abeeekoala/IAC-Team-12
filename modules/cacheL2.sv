module setascacheL2 #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic WE,                  // Write Enable (for stores)
    input logic [DATA_WIDTH-1:0] WD, // Write Data
    input logic [DATA_WIDTH-1:0] A,  // Address
    input logic [2:0] func3,         // func3 
    input logic  hitL1,              // Cache Data hit or miss - contained in L1
    input logic  fetchL1,            // Cache miss in L1 data to be fetched from L2 or main memory
    input logic  WEL2,
    input logic  [DATA_WIDTH-1:0] EVICT_DATA,
    input logic  
    output logic hitL2,                // Cache Hit/Miss signal
    output logic fetchL2,                                                                                                                              // Signal to fetch data from memory
    output logic writeback,          // Writeback to main memory for dirty eviction
    output logic [DATA_WIDTH-1:0] WB_DATAL2,  // Writeback data to memory
    output logic [DATA_WIDTH-1:0] DATA_OUT  // Data to the CPU
);

    typedef struct packed {
        logic U; // LRU bit -- 1 = Way 1 recently used, 0 = Way 2
        // Way 1
        logic ValitdityBit1;
        logic [27:0] tag1;
        logic [DATA_WIDTH-1:0] data1; 
        logic DB1; // Dirty bit
        // Way 2
        logic ValitdityBit2;
        logic [27:0] tag2;
        logic [DATA_WIDTH-1:0] data2; 
        logic DB2; // Dirty bit
    } CacheType;

    CacheType cache [8]; // Define 4 sets, 2-way associative cache

    // Variables
    logic [27:0] tag;
    logic [2:0] set;
    logic [DATA_WIDTH-1:0] Data;
    logic [DATA_WIDTH-1:0] RD;

    // Address breakdown
    always_comb begin
        tag = A[31:5];  // Tag from address
        set = A[4:2];   // Set index from address
    end

    // Cache Access Logic
    always_comb begin
        // Default outputs
        if (~hitL1) begin // data not located in L1 so check L2
            hitL2 = 0;
            stall = 0;
            fetchL2 = 0;
            writeback = 0;
            if (cache[set].ValitdityBit1 && (cache[set].tag1 == tag)) begin
                hitL2 = 1;
                Data = cache[set].data1;
                cache[set].U = 1; // Update LRU
            end else if (cache[set].ValitdityBit2 && (cache[set].tag2 == tag)) begin
                hitL2 = 1;
                Data = cache[set].data2;
                cache[set].U = 0; // Update LRU
            end else begin
                // Cache miss
                hitL2 = 0;
                stall = 1;  // Stall the pipeline for a miss
                fetchL2 = 1;  // Fetch data from main memory
                // Check if eviction is needed
                if (cache[set].U == 0) begin
                    // Evict way 1 if dirty
                    if (cache[set].DB1) begin
                        writeback = 1;
                        WB_DATAL2 = cache[set].data1;
                    end
                end else begin
                    // Evict way 2 if dirty
                    if (cache[set].DB2) begin
                        writeback = 1;
                        WB_DATAL2= cache[set].data2;
                    end
                end
            end
        end

        // Output data (load instructions) given hit as otherwise data hasn't loaded
        if (~WE && hitL2) begin
            DATA_OUT = Data;
        end
    end

    // Cache Write Logic
    always_ff @(posedge clk) begin
        if (hitL2 && WE) begin // Memory block alr in cache 
            if (cache[set].U == 1) begin
                // Write to way 1
                case (funct3)
                    3'b000: cache[set].data1[7:0] <= WD[7:0];      // sb
                    3'b001: cache[set].data1[15:0] <= WD[15:0];    // sh
                    3'b010: cache[set].data1 <= WD;                // sw
                endcase
                cache[set].DB1 <= 1; // Set dirty bit for way 1
            end else begin
                // Write to way 2
                case (funct3)
                    3'b000: cache[set].data2[7:0] <= WD[7:0];      // sb
                    3'b001: cache[set].data2[15:0] <= WD[15:0];    // sh
                    3'b010: cache[set].data2 <= WD;                // sw
                endcase
                cache[set].DB2 <= 1; // Set dirty bit for way 2
            end
        end

        if (~hitL2 && fetchL2) begin // Cache miss: fetch from memory
            if (cache[set].U == 0) begin
                // Evict way 1 if dirty
                if (cache[set].DB1) begin
                    cache[set].DB1 <= 0; // Clear dirty bit after writeback
                end
                cache[set].ValitdityBit1 <= 1;
                cache[set].tag1 <= tag;
                cache[set].data1 <= RD; // New data from memory
                cache[set].U <= 1;      // Update LRU
            end else begin
                // Evict way 2 if dirty
                if (cache[set].DB2) begin
                    cache[set].DB2 <= 0; // Clear dirty bit after writeback
                end
                cache[set].ValitdityBit2 <= 1;
                cache[set].tag2 <= tag;
                cache[set].data2 <= RD; // New data from memory
                cache[set].U <= 0;      // Update LRU
            end
            stall = 0;
            fetchL2 = 0;
        end
        // Cache Eviction update

        if (WEL2) begin 
            if (cache[set].U == 0) begin
                // Evict way 1 if dirty
                if (cache[set].DB1) begin
                    cache[set].DB1 <= 0; // Clear dirty bit after writeback
                end
                cache[set].ValitdityBit1 <= 1;
                cache[set].tag1 <= tag;
                cache[set].data1 <= EVICT_DATA;
                cache[set].U <= 1;      // Update LRU
            end else begin
                // Evict way 2 if dirty
                if (cache[set].DB2) begin
                    cache[set].DB2 <= 0; // Clear dirty bit after writeback
                end
                cache[set].ValitdityBit2 <= 1;
                cache[set].tag2 <= tag;
                cache[set].data2 <= EVICT_DATA;
                cache[set].U <= 0;      // Update LRU
            end
        end
    end

    // Data Memory Instance
    dataMemory datamemory (
        .clk       (clk),  
        .A         (A),        
        .fetch     (fetchL2),       // Fetch signal to load data
        .writeback (writeback),   // Writeback signal to main memory
        .WB_addr   (WB_addr),     // WB address 
        .WB_DATA   (WB_DATA),     // Writeback data to memory
        .RD        (RD)           // Data read from memory
    );

endmodule

// note to improve -- could make exclusive 