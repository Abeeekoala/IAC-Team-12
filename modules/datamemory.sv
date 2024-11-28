module dataMem #(
    parameter DATA_WIDTH = 32,  
              ADDR_WIDTH = 5   // Address width (e.g., 5 bits -> 32 locations)
) (
    input logic clk,                           // Clock signal
    input logic WE,                      // Write enable for store instructions
    input logic [DATA_WIDTH-1:0] A,         // Memory address (calculated by ALU)
    input logic [DATA_WIDTH-1:0] WD,   // Data to write into memory
    input logic [2:0] funct3,                  // Instruction's funct3 field
    input logic [6:0] opcode,                  // Instruction's opcode field
    output logic [DATA_WIDTH-1:0] RD    // Data read from memory
);

    // Memory array: 2^ADDR_WIDTH locations, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:31];

    // Read logic for load instructions
    always_comb begin
        if (opcode == 7'b0000011) begin // Load instructions
            case (funct3)
                3'b000: read_data = {{24{mem[A][7]}}, mem[A][7:0]};  // lb
                3'b001: read_data = {{16{mem[A][15]}}, mem[A][15:0]}; // lh
                3'b010: read_data = mem[A];                              // lw
                3'b100: read_data = {24'b0, mem[A][7:0]};                // lbu
                3'b101: read_data = {16'b0, mem[A][15:0]};               // lhu
                default: read_data = 32'b0;                                 // Default case
            endcase
        end else begin
            read_data = 32'b0; // No load operation
        end
    end

    // Write logic for store instructions
    always_ff @(posedge clk) begin
        if (write_en && opcode == 7'b0100011) begin // Store instructions
            case (funct3)
                3'b000: mem[A][7:0] <= WD[7:0];    // sb
                3'b001: mem[A][15:0] <= WD[15:0];  // sh
                3'b010: mem[A] <= WD;              // sw
            endcase
        end
    end

endmodule
