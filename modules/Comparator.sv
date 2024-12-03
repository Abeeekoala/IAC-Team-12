module Comparator(
    input logic [31:0]      rs1,
    input logic [31:0]      rs2,
    output logic            Zero,
    output logic            Less,
    output logic            LessU     
);
    
always_comb begin
    Zero = (rs1 == rs2);
    Less = ($signed(rs1) < $signed(rs2));
    LessU = (rs1 < rs2);
end

endmodule