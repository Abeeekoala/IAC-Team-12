module InstrMem #(
)(
    input logic [31:0] addr1,
    input logic [31:0] addr2,
    output logic [31:0] instr1,
    output logic [31:0] instr2,
    output logic [2:0] funct3_i1, funct3_i2,
    output logic [4:0] rs1_1, rs2_1, rd_1,
    output logic [4:0] rs1_2, rs2_2, rd_2
);

// Instruction memory for 2^12 bytes
logic [7:0] mem_array [2**12-1:0];

initial begin
    $readmemh("program.hex", mem_array);
end

// Asynchronous read for instruction fetch
always_comb begin
    instr1 = {mem_array[addr1+3], mem_array[addr1+2], mem_array[addr1+1], mem_array[addr1]};
    instr2 = {mem_array[addr2+3], mem_array[addr2+2], mem_array[addr2+1], mem_array[addr2]};
end

// Extract fields for both instructions
assign funct3_i1 = instr1[14:12];
assign rs1_1 = instr1[19:15];
assign rs2_1 = instr1[24:20];
assign rd_1 = instr1[11:7];

assign funct3_i2 = instr2[14:12];
assign rs1_2 = instr2[19:15];
assign rs2_2 = instr2[24:20];
assign rd_2 = instr2[11:7];

endmodule
