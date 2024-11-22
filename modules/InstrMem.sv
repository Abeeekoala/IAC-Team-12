module InstrMem #(
)(
    input logic [31:0] addr,
    output logic [31:0] instr
);

logic [7:0] mem_array [2**12-1:0];

initial begin
        $display("Loading rom.");
        $readmemh("/home/abraham/EIE2_IAC/IAC-Team-12/modules/instructions.mem", mem_array);
end;

always_comb begin
    instr = {mem_array[addr], mem_array[addr+1], mem_array[addr+2], mem_array[addr+3]};
end

endmodule
