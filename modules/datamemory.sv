module datamemory #(
    parameter DATA_WIDTH = 32,
              MEM_WIDTH  = 8
) (
    input logic                     clk,                // Clock signal
    input logic [1:0]               WE,                 // Memory write signals (port 1 and port 2)
    input logic [DATA_WIDTH-1:0]    a1,                 // Memory address (port 1)
    input logic [DATA_WIDTH-1:0]    a2,                 // Memory address (port 2)
    input logic [DATA_WIDTH-1:0]    wd1,                // Data to write into memory (port 1)
    input logic [DATA_WIDTH-1:0]    wd2,                // Data to write into memory (port 2)
    input logic [2:0]               funct3_1,           // Instruction's funct3 field for port 1
    input logic [2:0]               funct3_2,           // Instruction's funct3 field for port 2
    output logic [DATA_WIDTH-1:0]   rd1,                // Data read from memory (port 1)
    output logic [DATA_WIDTH-1:0]   rd2                 // Data read from memory (port 2)
);

    // Memory array: 2^17 locations 0x00000000 to 0x0001FFFF, each MEM_WIDTH bits wide
    logic [MEM_WIDTH-1:0] mem [0:2**17-1];

    // Memory initialization
    initial begin
        $readmemh("data.hex", mem, 32'h00010000);
    end

    // Read logic for load instructions
    always_comb begin
        // Port 1
        case (funct3_1)
            3'b000: rd1 = {{24{mem[a1][7]}}, mem[a1]};                 // lb
            3'b001: rd1 = {{16{mem[a1 + 1][7]}}, mem[a1 + 1], mem[a1]}; // lh
            3'b010: rd1 = {mem[a1 + 3], mem[a1 + 2], mem[a1 + 1], mem[a1]}; // lw
            3'b100: rd1 = {24'b0, mem[a1]};                            // lbu
            3'b101: rd1 = {16'b0, mem[a1 + 1], mem[a1]};               // lhu
            default: rd1 = 32'b0;                                      // Default case
        endcase

        // Port 2
        case (funct3_2)
            3'b000: rd2 = {{24{mem[a2][7]}}, mem[a2]};                 // lb
            3'b001: rd2 = {{16{mem[a2 + 1][7]}}, mem[a2 + 1], mem[a2]}; // lh
            3'b010: rd2 = {mem[a2 + 3], mem[a2 + 2], mem[a2 + 1], mem[a2]}; // lw
            3'b100: rd2 = {24'b0, mem[a2]};                            // lbu
            3'b101: rd2 = {16'b0, mem[a2 + 1], mem[a2]};               // lhu
            default: rd2 = 32'b0;                                      // Default case
        endcase
    end

    // Write logic for store instructions
    always_ff @(posedge clk) begin
        if (MemWrite[0]) begin // Port 1 write
            case (funct3_1)
                3'b000: mem[a1] <= wd1[7:0];                      // sb
                3'b001: begin
                    mem[a1 + 1] <= wd1[15:8];                     // sh
                    mem[a1] <= wd1[7:0];
                end
                3'b010: begin
                    mem[a1 + 3] <= wd1[31:24];                    // sw
                    mem[a1 + 2] <= wd1[23:16];
                    mem[a1 + 1] <= wd1[15:8];
                    mem[a1] <= wd1[7:0];
                end
            endcase
        end

        if (MemWrite[1]) begin // Port 2 write
            case (funct3_2)
                3'b000: mem[a2] <= wd2[7:0];                      // sb
                3'b001: begin
                    mem[a2 + 1] <= wd2[15:8];                     // sh
                    mem[a2] <= wd2[7:0];
                end
                3'b010: begin
                    mem[a2 + 3] <= wd2[31:24];                    // sw
                    mem[a2 + 2] <= wd2[23:16];
                    mem[a2 + 1] <= wd2[15:8];
                    mem[a2] <= wd2[7:0];
                end
            endcase
        end
    end

endmodule
