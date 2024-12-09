module setascache #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic WE,                  // Write Enable (for stores)
    input logic [DATA_WIDTH-1:0] WD, // Write Data
    input logic [DATA_WIDTH-1:0] A,  // Address
    input logic [2:0] funct3,        // Load/Store type
    input logic [DATA_WIDTH-1:0] RD;
    input logic hitL2,               // Data Hit/Miss signal in L2 cache level 
    output logic hitL1,                // Cache Hit/Miss signal
    output logic fetchL1,              // Signal to fetch data from memory
    output logic writeback,          // Writeback to main memory for dirty eviction
    output logic WEL2,            // Logic to enable evicted data from L1 to be written to L1 instead 
    output logic [DATA_WIDTH-1:0] WB_DATAL1,  // Writeback data to memory
    output logic [DATA_WIDTH-1:0] EVICT_DATA,  // Evict Data to L2
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

    CacheType cache [4]; // Define 4 sets, 2-way associative cache

    // Variables
    logic [27:0] tag;
    logic [1:0] set;
    logic [DATA_WIDTH-1:0] Data;

    // Address breakdown
    always_comb begin
        tag = A[31:5];  // Tag from address
        set = A[4:3];   // Set index from address
    end

    // Cache Access Logic
    always_comb begin
        // Default outputs
        hitL1 = 0;
        stall = 0;
        fetchL1 = 0;
        writeback = 0;
        writeL2 = 0; 

        // Check for a cache hit in either way
        if (cache[set].ValitdityBit1 && (cache[set].tag1 == tag)) begin
            hitL1 = 1;
            Data = cache[set].data1;
            cache[set].U = 1; // Update LRU
        end else if (cache[set].ValitdityBit2 && (cache[set].tag2 == tag)) begin
            hitL1= 1;
            Data = cache[set].data2;
            cache[set].U = 0; // Update LRU
        end else begin
            // Cache miss
            hitL1 = 0;
            stall = 1;  // Stall the pipeline for a miss
            fetchL1 = 1;  // Fetch data from main memory
            // Check if eviction is needed
            if (cache[set].U == 0) begin
                // Evict way 1 if dirty
                if (cache[set].DB1) begin
                    writeback = 1;
                    WB_DATA = cache[set].data1;
                    EVICT_DATA = cache[set].data1;
                    WEL2 = 1; // move data to L2
                end
            end else begin
                // Evict way 2 if dirty
                if (cache[set].DB2) begin
                    writeback = 1;
                    WB_DATA = cache[set].data2;
                    EVICT_DATA = cache[set].data2;
                    writeL2 = 1;
                end
            end
        end

        // Output data (load instructions) given hit as otherwise data hasn't loaded
        if (~WE && hitL1) begin
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

    // Cache Write Logic
    always_ff @(posedge clk) begin
        if (hitL1 && WE) begin // Memory block alr in cache 
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

        if (~hit && fetchL1) begin // Cache miss: fetch from either L2 or memory
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
            fetchL1 = 0;
        end
    end

// initiate 2nd level of cache

setascacheL2 L2(
    .clk (clk),
    .WE  (WE),
    .WEL2 (WEL2),
    .WD  (WD), 
    .A   (A),
    .func3 (func3),
    .hitL1 (hitL1), 
    .fetchL1 (fetchL1),
    .writeback (writeback),
    .EVICT_DATA (EVICT_DATA),
    .WB_DATAL1 (WB_DATA),
    .DATA_OUT (RD),
);

endmodule
