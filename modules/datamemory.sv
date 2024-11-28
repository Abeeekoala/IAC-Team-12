module dataMem #(
    parameter DATA_WIDTH = 32,  
              ADDR_WIDTH = 5   // Address width (e.g., 5 bits -> 32 locations)
) (
    input logic clk,                          
    input logic write_en,                     // Write enable for store instructions
    input logic [DATA_WIDTH-1:0] addr,        // Instruction input
    input logic [DATA_WIDTH-1:0] write_data,  // Data to write into memory
    output logic [DATA_WIDTH-1:0] read_data   // Data to read from memory
);

    // Memory array: 2^ADDR_WIDTH locations, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:31];

    // Extract fields from instruction
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [4:0] rs1, rs2, rd;
    logic signed [31:0] imm;

    assign opcode = addr[6:0];
    assign funct3 = addr[14:12];
    assign rs1 = addr[19:15];
    assign rs2 = addr[24:20];
    assign rd = addr[11:7];

    // Immediate value extraction for I-type and S-type instructions
    assign imm = (opcode == 7'b0000011) ? {{20{addr[31]}}, addr[31:20]} :  // Load
                 (opcode == 7'b0100011) ? {{20{addr[31]}}, addr[31:25], addr[11:7]} : 
                 32'b0;

    // Read logic
    always_comb begin
        if (opcode == 7'b0000011) begin // Load instructions
            case (funct3)
                3'b000: read_data = {{24{mem[rs1 + imm][7]}}, mem[rs1 + imm][7:0]};  // lb
                3'b001: read_data = {{16{mem[rs1 + imm][15]}}, mem[rs1 + imm][15:0]}; // lh
                3'b010: read_data = mem[rs1 + imm];                                   // lw
                3'b100: read_data = {24'b0, mem[rs1 + imm][7:0]};                     // lbu
                3'b101: read_data = {16'b0, mem[rs1 + imm][15:0]};                    // lhu
                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

    // Write logic (store instructions)
    always_ff @(posedge clk) begin
        if (write_en && opcode == 7'b0100011) begin
            case (funct3)
                3'b000: mem[rs1 + imm][7:0] <= write_data[7:0];    // sb
                3'b001: mem[rs1 + imm][15:0] <= write_data[15:0];  // sh
                3'b010: mem[rs1 + imm] <= write_data;             // sw
            endcase
        end
    end

endmodule
