module CU (
)(
<<<<<<< Updated upstream
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
=======
    input logic [2:0] funct3,
    input logic [6:0] opcode,
    input logic [6:0] funct7,
    input logic EQ,
    output logic [1:0] ImmSrc,
    output logic PCSrc,
    output logic ResultSrc,
    output logic ALUSrc,
    output logic MemWrite
    output logic [2:0] ALUctrl,
    output logic RegWrite
);

always_comb begin
    ImmSrc = 2'b00;
    PCSrc = 1'b0;
    ResultSrc = 1'b0;
    ALUSrc = 1'b0;
>>>>>>> Stashed changes
    ALUctrl = 3'b000;
    RegWrite = 1'b0;
    MemWrite = 1'b0;

    case(opcode)

        // r-type instructions
        7'b0110011: begin
            
            RegWrite = 1'b1;
            case(funct3)
                3'b000: begin
                    case(funct7)
                        // ADD rd = rs1+rs2
                        7'b0000000: begin
                            //
                        end
                        // SUB rd = rs1-rs2
                        7'b0010100: begin
                            //
                        end
                    endcase
                end
                
                // XOR
                3'b100: begin
                    //
                end

                // OR
                3'b110: begin
                    //
                end

                // AND
                3'b111: begin
                    //
                end

                // Shift Left Logical
                3'b001: begin
                    //
                end

                // Shift Right
                3'b101: begin
                    case(funct7)
                        // Logical
                        7'b0000000: begin
                            //
                        end
                        //Arith
                        7'b0010100: begin
                            //
                        end
                    endcase
                end

                // Set Less Than
                3'b010: begin
                    //
                end

                // Set Less Than (U)
                3'b011: begin
                    //
                end
            endcase
        end
        
        // i-type instructions
        7'b0010011: begin
            RegWrite = 1'b1;
<<<<<<< Updated upstream
            ALUsrc = 1'b1;
            ImmSrc = 2'b0;
=======
            ALUSrc = 1'b1;
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
            RegWrite = 1'b0;
            ALUsrc = 1'b0;
            ImmSrc = 2'b0;
=======
>>>>>>> Stashed changes
            case(funct3)
                //bne
                3'b001:begin
                    PCSrc = ~EQ;
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
