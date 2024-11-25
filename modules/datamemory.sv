module dataMem #(
    parameter DATA_WIDTH = 32,  
              ADDR_WIDTH = 5   // Address width (e.g., 5 bits -> 32 locations)
) (
    input logic clk,                          
    input logic write_en,                    
    input logic [DATA_WIDTH-1:0] a,           
    input logic [DATA_WIDTH-1:0] write_data,  // Data to write into memory
    output logic [DATA_WIDTH-1:0] read_data   
);

    // Memory array: 2^ADDR_WIDTH locations, each DATA_WIDTH bits wide
    logic [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];
    logic rd = a[11:7]
    logic opcode = a[6:0]
    logic funct3 = a[14:12]
    logic rs1 = a[19:15]
    logic rs2 = a[24:20]

    always_comb begin
        if (opcode == 7'b0000011) begin
            case(funct3) // Load instructions
            3'b000: read_data = mem[rs1+rd][0:7];//lb
            3'b001: read_data = mem[rs1+rd][0:15];//lh
            3'b010: read_data = mem[rs1+rd][0:31];//lw
            3'b100: read_data = mem[rs1+rd][0:7];//lbu
            3'b101: read_data = mem[rs1+rd][0:15];//lhu
            default read_data = mem[rd];
            endcase
        end
        if (opcode == 7'b0100011) begin
            case(funct3) // Store instructions
            3'b000: mem[rs1+rd] = mem[rs2][0:7];// sb
            3'b001: mem[rs1+rd] = mem[rs2][0:15];// sh
            3'b010: mem[rs1+rd] = mem[rs2][0:31];// sw
            endcase 
        end
    end

    always_ff @(posedge clk) begin
        if (write_en) begin
            mem[a] <= write_data;
        end
    end

endmodule
