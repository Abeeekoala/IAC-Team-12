module CU #(
)(
    input logic [31:0] instr,
    input logic EQ,
    output logic ImmSrc,
    output logic PCsrc,
    output logic ALUsrc,
    output logic [2:0] ALUctrl,
    output logic RegWrite
);

logic [2:0] funct3;
logic [6:0] opcode;

assign funct3 = instr[14:12];
assign opcode = instr[6:0];

always_comb begin
    ImmSrc = 1'b0;
    PCsrc = 1'b0;
    ALUsrc = 1'b0;
    ALUctrl = 3'b000;
    RegWrite = 1'b0;

    case(opcode)

        // r-type instructions
        7'b0110011: begin
            // to be implemented
        end
        
        // i-type instructions
        7'b0010011: begin
            RegWrite = 1'b1;
            ALUsrc = 1'b1;
            ImmSrc = 1'b0;

            case(funct3)
                // Addi
                3'b000: begin
                    ALUctrl = 3'b000;
                end
            endcase

        end

        // u-type instructions
        7'b0110111: begin
            // to be implemented
        end

        // s-type instructions
        7'b0100011: begin
            // to be implemented
        end

        // b-type instructions
        7'b1100011: begin
            RegWrite = 1'b0;
            ALUsrc = 1'b0;
            ImmSrc = 1'b0;
            case(funct3)
                //bne
                3'b001:begin
                    PCsrc = ~EQ;
                    ALUctrl = 3'b001;
                end
            endcase
        end
    
    endcase
end

endmodule
