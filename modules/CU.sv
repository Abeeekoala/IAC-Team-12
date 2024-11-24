module CU #(
)(
    input logic [2:0]   funct3,
    input logic [6:0]   opcode,
    input logic         funct7,
    input logic         EQ,
    output logic [1:0]  ImmSrc,
    output logic        PCsrc,
    output logic        ALUsrc,
    output logic [2:0]  ALUctrl,
    output logic        RegWrite
);

always_comb begin
    ImmSrc = 2'b0;
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
            ImmSrc = 2'b0;

            case(funct3)
                // Addi
                3'b000: begin
                    ALUctrl = 3'b000;
                end
                default: begin
                    // to be implemented
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
            ImmSrc = 2'b0;
            case(funct3)
                //bne
                3'b001:begin
                    PCsrc = ~EQ;
                    ALUctrl = 3'b001;
                end
            endcase
        end
        default:    begin
            // to be implemented
        end
    
    endcase
end

endmodule
