module dataMemory #(
    parameter DATA_WIDTH = 32,  
              ADDR_WIDTH = 5   // Address width (e.g., 5 bits -> 32 locations)
) (
    input logic clk,                           // Clock signal
    input logic WE,                      // Write enable for store instructions
    input logic [DATA_WIDTH-1:0] A,         // Memory address (calculated by ALU)
    input logic [DATA_WIDTH-1:0] WD,   // Data to write into memory
    input logic [2:0] funct3,                  // Instruction's funct3 field
    input logic CH,                     //Cache Hit
    input logic [DATA_WIDTH-1:0] CD,    //Data returned from Cache
    output logic CE,            //Cache Enable
    output logic [DATA_WIDTH-1:0] CW, //Cache Write Data
    output logic [DATA_WIDTH-1:0] RD,    // Data read from memory
);

    // Memory array: 2^18 locations 0x00000000 to 0x0001FFFF, each DATA_WIDTH bits wide
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
        if (A == 32'h000000FC) begin
            // MMIO read from trigger address
            RD = {31'b0, trigger};  // Return trigger in LSB
        end 
        else begin
            // Regular memory read
            if (CH) begin
                case (funct3)
                    3'b000: RD = {{24{CD[7]}}, CD[7:0]};    // lb
                    3'b001: RD = {{16{CD[15]}}, CD[15:0]};  // lh
                    3'b010: RD = CD;                            // lw
                    3'b100: RD = {24'b0, CD[7:0]};              // lbu
                    3'b101: RD = {16'b0, CD[15:0]};             // lhu
                    default: RD = 32'b0;                            // Default case
                endcase
                CE = 0;
            end
            else begin
                case (funct3)
                    3'b000: RD = {{24{mem[A][7]}}, mem[A][7:0]};    // lb
                    3'b001: RD = {{16{mem[A][15]}}, mem[A][15:0]};  // lh
                    3'b010: RD = mem[A];                            // lw
                    3'b100: RD = {24'b0, mem[A][7:0]};              // lbu
                    3'b101: RD = {16'b0, mem[A][15:0]};             // lhu
                    default: RD = 32'b0;                            // Default case
                endcase
                CW = RD;
                CE = 1;
            end
        end
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

setascache Cache (
    .clk (clk),
    .WE  (CE),
    .WD  (CW),
    .A   (A),
    .hit (CH),
    .DATA_OUT (CD)
);

endmodule
