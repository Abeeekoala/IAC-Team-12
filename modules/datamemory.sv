module datamemory #(
    parameter DATA_WIDTH = 32
) (
    input logic clk,                    // Clock signal
    input logic WE,                     // Write enable for store instructions
    input logic [DATA_WIDTH-1:0] A,     // Memory address (calculated by ALU)
    input logic [DATA_WIDTH-1:0] WD,    // Data to write into memory
    input logic [2:0] funct3,           // Instruction's funct3 field
    output logic [DATA_WIDTH-1:0] RD    // Data read from memory
);

    // Memory array: 2^17 locations 0x00000000 to 0x0001FFFF, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:131072];

    initial begin
        $readmemh("../modules/data.hex", mem);
    end

    // Read logic for load instructions
    always_comb begin
        case (funct3)
            3'b000: RD = {{24{mem[A][7]}}, mem[A][7:0]};    // lb
            3'b001: RD = {{16{mem[A][15]}}, mem[A][15:0]};  // lh
            3'b010: RD = mem[A];                            // lw
            3'b100: RD = {24'b0, mem[A][7:0]};              // lbu
            3'b101: RD = {16'b0, mem[A][15:0]};             // lhu
            default: RD = 32'b0;                            // Default case
        endcase
    end

    // Write logic for store instructions
    always_ff @(posedge clk) begin
        if (WE) begin // Store instruction
            case (funct3)
                3'b000: mem[A][7:0] <= WD[7:0];    // sb
                3'b001: mem[A][15:0] <= WD[15:0];  // sh
                3'b010: mem[A] <= WD;              // sw
            endcase
        end
    end

endmodule
