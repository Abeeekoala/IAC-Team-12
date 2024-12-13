module setascache #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst,
    input logic WE,                  // Write Enable (for stores)
    input logic [DATA_WIDTH-1:0] RD,  // Read Data from memory
    input logic [DATA_WIDTH-1:0] WD, // Write Data
    input logic [DATA_WIDTH-1:0] A,  // Address
    input logic Read,
    input logic [2:0] funct3,        // Load/Store type
    output logic stall,
    output logic hit,                // Cache Hit/Miss signal
    output logic fetch,              // Signal to fetch data from memory
    output logic [DATA_WIDTH-1:0] DATA_OUT,  // Data to the CPU

    // L2 interface signals  // Eviction policy : First write back to L2 then once evicted from L2 write to main memory
     
    output logic L2_fetch,
    input logic [DATA_WIDTH-1:0] L2_RD, // Read data from L2
    input logic L2_hit,  // Data contained within L2
    output logic L2_writeback, // Writeback to L2
    output logic [DATA_WIDTH-1:0] L2_WB_DATA,
    output logic [DATA_WIDTH-1:0] L2_WB_ADDR
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

    // State machine states
    typedef enum logic [2:0] {
        IDLE, CHECK_HIT, FETCH_FROM_L2, FETCH_FROM_MEMORY, WRITE_TO_L2
    } state_t;

    state_t current_state, next_state;

    // Address breakdown
    always_comb begin
        tag = A[31:4];  // Tag from address
        set = A[3:2];   // Set index from address
    end

    // State machine logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        // Default values
        next_state = current_state;
        hit = 0;
        stall = 0;
        fetch = 0;
        L2_fetch = 0;
        L2_writeback = 0;
        DATA_OUT = '0;

        case (current_state)
            IDLE: begin
                if (Read || WE) begin
                    next_state = CHECK_HIT;
                end
            end

            CHECK_HIT: begin
                if (cache[set].ValitdityBit0 && (cache[set].tag0 == tag)) begin
                    hit = 1;
                    way_hit = 0;
                    next_state = IDLE;
                end else if (cache[set].ValitdityBit1 && (cache[set].tag1 == tag)) begin
                    hit = 1;
                    way_hit = 1;
                    next_state = IDLE;
                end else begin
                    hit = 0;
                    stall = 1;
                    if (L2_hit) begin
                        next_state = FETCH_FROM_L2;
                    end else begin
                        next_state = FETCH_FROM_MEMORY;
                    end
                end
            end

            FETCH_FROM_L2: begin
                L2_fetch = 1;
                if (L2_hit) begin
                    next_state = IDLE;
                end
            end

            FETCH_FROM_MEMORY: begin
                fetch = 1;
                next_state = WRITE_TO_L2;
            end

            WRITE_TO_L2: begin
                if (cache[set].U == 0) begin
                    if (cache[set].DB0) begin
                        L2_writeback = 1;
                        L2_WB_ADDR = {cache[set].tag0, set, 2'b00};
                        L2_WB_DATA = cache[set].data0;
                    end
                end else begin
                    if (cache[set].DB1) begin
                        L2_writeback = 1;
                        L2_WB_ADDR = {cache[set].tag1, set, 2'b00};
                        L2_WB_DATA = cache[set].data1;
                    end
                end
                next_state = IDLE;
            end
        endcase
    end

    // Output data (load instructions) given hit as otherwise data hasn't loaded
    always_comb begin
        if (Read && hit) begin
            case (funct3)
                3'b000: begin                                           // lb
                    case (A[1:0])
                        2'b00: DATA_OUT = {{24{Data[7]}}, Data[7:0]};
                        2'b01: DATA_OUT = {{24{Data[15]}}, Data[15:8]};
                        2'b10: DATA_OUT = {{24{Data[23]}}, Data[23:16]};
                        2'b11: DATA_OUT = {{24{Data[31]}}, Data[31:24]};      
                    endcase
                end 
                3'b001: begin                                           // lh
                    if (A[1]) begin
                        DATA_OUT = {{16{Data[31]}}, Data[31:16]};
                    end 
                    else begin
                        DATA_OUT = {{16{Data[15]}}, Data[15:0]};
                    end
                end          
                3'b010: DATA_OUT = Data;                                // lw
                3'b100: begin                                           // lbu
                    case (A[1:0])
                        2'b00: DATA_OUT = {{24{1'b0}}, Data[7:0]};
                        2'b01: DATA_OUT = {{24{1'b0}}, Data[15:8]};
                        2'b10: DATA_OUT = {{24{1'b0}}, Data[23:16]};
                        2'b11: DATA_OUT = {{24{1'b0}}, Data[31:24]};      
                    endcase
                end
                3'b101: begin                                           // lhu
                    if (A[1]) begin
                        DATA_OUT = {{16{1'b0}}, Data[31:16]};
                    end 
                    else begin
                        DATA_OUT = {{16{1'b0}}, Data[15:0]};
                    end
                end           
                default: DATA_OUT = 32'b0;                        // Default case
            endcase
        end
    end

    // Write Policy: Write-back scheme with write-allocate
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 4; i++) begin
                cache[i].U <= 0;
                cache[i].ValitdityBit0 <= 0;
                cache[i].ValitdityBit1 <= 0;
                cache[i].DB0 <= 0;
                cache[i].DB1 <= 0;
                cache[i].tag0 <= '0;
                cache[i].tag1 <= '0;
            end
        end else begin
            if (current_state == FETCH_FROM_MEMORY) begin
                if (cache[set].U == 0) begin
                    cache[set].data0 <= RD;
                    cache[set].tag0 <= tag;
                    cache[set].ValitdityBit0 <= 1;
                    cache[set].U <= 1;
                end else begin
                    cache[set].data1 <= RD;
                    cache[set].tag1 <= tag;
                    cache[set].ValitdityBit1 <= 1;
                    cache[set].U <= 0;
                end
            end else if (current_state == WRITE_TO_L2) begin
                if (cache[set].U == 0 && cache[set].DB0) begin
                    cache[set].DB0 <= 0;
                end else if (cache[set].U == 1 && cache[set].DB1) begin
                    cache[set].DB1 <= 0;
                end
            end
        end
    end

endmodule
