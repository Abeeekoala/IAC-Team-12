module sign_ext (
    input   logic [31:0]      Instr,
    input   logic [1:0]       ImmSrc,
    output  logic [31:0]      ImmOp
);
always_comb begin
    case (Instr[6:0])
        7'b0010011: begin
            ImmOp = {{20{Instr[31]}}, Instr[31:20]};
        end
        7'b1100011: begin
            ImmOp = {{20{Instr[31]}}, Instr[7],Instr[30:25], Instr[11:8], 1'b0};
        end
        default: begin
            ImmOp = 32'b0;
        end
    endcase
end
    
endmodule
