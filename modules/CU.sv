module CU (
    input logic [2:0] funct3,
    input logic [6:0] op,
    input logic [6:0] funct7,
    input logic Zero,
    output logic [2:0] ImmSrc,
    output logic PCSrc,
    output logic ResultSrc,
    output logic ALUSrc,
    output logic MemWrite,
    output logic [3:0] ALUctrl,
    output logic RegWrite
);

always_comb begin
    ImmSrc = 3'b000;
    PCSrc = 1'b0;
    ResultSrc = 1'b0;
    ALUSrc = 1'b0;
    ALUctrl = 4'b0000;
    RegWrite = 1'b0;
    MemWrite = 1'b0;

    case(op)
        // r-type instructions
        7'b0110011: begin
            RegWrite = 1'b1;
            case(funct3)
                3'b000: begin
                    case(funct7)
                        // ADD rd = rs1+rs2
                        7'h00: begin
                            ALUctrl = 4'b0000;
                        end
                        // SUB rd = rs1-rs2
                        7'h20: begin
                            ALUctrl = 4'b0001;
                        end
                    endcase
                end
                
                // XOR
                3'b100: begin
                    ALUctrl = 4'b0010;
                end

                // OR
                3'b110: begin
                    ALUctrl = 4'b0011;
                end

                // AND
                3'b111: begin
                    ALUctrl = 4'b0100;
                end

                // Logical Shift Left
                3'b001: begin
                    ALUctrl = 4'b0101;
                end

                // Shift Right
                3'b101: begin
                    case(funct7)
                        // Logical
                        7'h00: begin
                            ALUctrl = 4'b0110;
                        end
                        //Arith
                        7'h20: begin
                            ALUctrl = 4'b0111;
                        end
                    endcase
                end

                // Set Less Than
                3'b010: begin
                    ALUctrl = 4'b1000;
                end

                // Set Less Than (U)
                3'b011: begin
                    ALUctrl = 4'b1001;
                end
            endcase
        end
        
        // i-type instructions
        7'b0010011: begin

            RegWrite = 1'b1;
            ALUSrc = 1'b1;

            case(funct3)
                // ADDI
                3'b000: begin
                    ALUctrl = 4'b0000;
                end

                // XORI
                3'b100: begin
                    ALUctrl = 4'b0010;
                end

                // ORI
                3'b110: begin
                    ALUctrl = 4'b0011;
                end

                // ANDI
                3'b111: begin
                    ALUctrl = 4'b0100;
                end
                
                // SLLI
                3'b001: begin
                    case(funct7)
                        7'h00: begin
                            ALUctrl = 4'b0101;
                        end
                    endcase
                end
                
                // SRLI and SRAI
                3'b101: begin
                    case(funct7)
                        // SRLI
                        7'h00: begin
                            ALUctrl = 4'b0110;
                        end
                        // SRAI
                        7'h20: begin
                            ALUctrl = 4'b0111;
                        end
                    endcase
                end

                // SLTI
                3'b010: begin
                    ALUctrl = 4'b1000;
                end

                // SLTIU
                3'b011: begin
                    ImmSrc = 3'b001;
                    ALUctrl = 4'b1001;

                end
            endcase
        end
        

        // load instructions
        7'b0000011: begin
            ImmSrc = 3'b000;
            ResultSrc = 1'b1;
            RegWrite = 1'b1;
            // need some other component to implement these
        end

        // u-type: lui
        7'b0110111: begin
            ImmSrc = 3'b100;
            // to be implemented
        end
        // u-type: auipc
        7'b0010111: begin
            ImmSrc = 3'b100;
            // to be implemented
        end

        // J-type instructions
        7'b110111: begin
            ImmSrc = 3'b101;
            // to be implemented
        end

        // s-type instructions
        7'b0100011: begin
            ImmSrc = 3'b010;
            // to be implemented
        end

        // b-type instructions
        7'b1100011: begin
            ImmSrc = 3'b011;
            case(funct3)
                // BEQ
                3'b000: begin
                    PCSrc = Zero;
                end
                
                // BNE
                3'b001:begin
                    PCSrc = ~Zero;
                    ALUctrl = 3'b001;
                end
                
                // BLT
                3'b100: begin
                    // need more info from Zero
                end
                
                // BGE
                3'b101: begin
                    // need more info from Zero
                end

                // BLTU
                3'b110: begin
                    // need more info from Zero
                end

                // BGEU
                3'b111: begin
                    // need more info from Zero
                end
            endcase
        end
    
    endcase
end

endmodule
