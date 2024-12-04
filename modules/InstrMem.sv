module InstrMem #(
)(
    input logic [31:0] addr,
    output logic [31:0] instr
);

logic [7:0] mem_array [2**12-1:0];

initial begin
        $display("Loading rom.");
        $readmemh("program.hex", mem_array);
        $display("Instruction Memory Contents After Initialization:");
        $display("mem[0] = %h", mem_array[0]);
        $display("mem[1] = %h", mem_array[1]);
        $display("mem[2] = %h", mem_array[2]);
        $display("mem[3] = %h", mem_array[3]);
end;

always_comb begin
    instr = {mem_array[addr+3], mem_array[addr+2], mem_array[addr+1], mem_array[addr]};
end

endmodule
