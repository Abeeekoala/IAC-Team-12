module Comparator(
    input logic [31:0]      rs1,
    input logic [31:0]      rs2,
    input logic [2:0]       funct3,
    output logic            Relation     
);
    
always_comb begin
    case (funct3)
        3'b000: Relation = (rs1 == rs2);
        3'b001: Relation = ~(rs1 == rs2);
        3'b100: Relation = ($signed(rs1) < $signed(rs2));
        3'b101: Relation = ~($signed(rs1) < $signed(rs2));
        3'b110: Relation = (rs1 < rs2);
        3'b111: Relation = ~(rs1 < rs2);
        default: Relation = 0;
    endcase
end

endmodule
