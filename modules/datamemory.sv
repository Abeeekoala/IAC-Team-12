module datamemory #(
    parameter DATA_WIDTH = 32,
              MEM_WIDTH  = 8
) (
    input logic trigger,                // Input trigger (MMIO)
    input logic clk,                    // Clock signal
    input logic WE,                     // Write enable for store instructions
    input logic [DATA_WIDTH-1:0] A,     // Memory address (calculated by ALU)
    input logic [DATA_WIDTH-1:0] WD,    // Data to write into memory
    input logic [2:0] funct3,           // Instruction's funct3 field
    output logic [DATA_WIDTH-1:0] RD    // Data read from memory
);

    // Memory array: 2^17 locations 0x00000000 to 0x0001FFFF, each DATA_WIDTH bits wide
    logic [MEM_WIDTH-1:0] mem [0:2**17-1];

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
        if (A == 32'h000000FC) begin
            // MMIO read from trigger address
            RD = {31'b0, trigger};  // Return trigger in LSB
        end 
        else begin
            // Regular memory read 
            case (funct3)
                3'b000: RD = {{24{mem[A][7]}}, mem[A]};                 // lb
                3'b001: RD = {{16{mem[A+1][7]}}, mem[A+1], mem[A]};    // lh
                3'b010: RD = {mem[A+3], mem[A+2], mem[A+1], mem[A]};    // lw
                3'b100: RD = {24'b0, mem[A]};                           // lbu
                3'b101: RD = {16'b0, mem[A+1], mem[A]};                 // lhu
                default: RD = 32'b0;                                    // Default case
            endcase
        end
    end

    // Write logic for store instructions
    always_ff @(posedge clk) begin
        if (WE) begin // Store instruction
            case (funct3)
                3'b000: mem[A] <= WD[7:0];      // sb
                3'b001: begin
                    mem[A + 1] <= WD[15:8];     // sh
                    mem[A] <= WD[7:0];
                end
                3'b010: begin
                    mem[A + 3] <= WD[31:24];    // sw
                    mem[A + 2] <= WD[23:16];
                    mem[A + 1] <= WD[15:8];
                    mem[A] <= WD[7:0];
                end
            endcase
        end
    end

endmodule
