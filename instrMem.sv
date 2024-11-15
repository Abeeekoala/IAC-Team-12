module instrMem #(
)(
    input logic [31:0] addr,
    output logic [31:0] instr
);

logic [31:0] mem_array [2**32-1:0];

initial begin
        $display("Loading.rom");
        $readmemh("instructions.mem", mem_array);
end;

always_ff @(posedge addr)
    instr <= mem_array[addr];

endmodule
