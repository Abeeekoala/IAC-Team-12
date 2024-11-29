module CU (
    input logic [2:0]       funct3,
    input logic [6:0]       op,
    input logic [6:0]       funct7,
    input logic             Zero,
    input logic             Less,
    input logic             LessU,
    output logic [2:0]      ImmSrc,
    output logic            PCSrc,
    output logic            ResultSrc,
    output logic            ALUSrc,
    output logic            MemWrite,
    output logic [3:0]      ALUctrl,
    output logic            RegWrite,
    output logic [2:0]      funct3O,
    output logic            MUXjump,
    output logic            JumpPRT,
    output logic            lastmuxidk
);

always_comb begin
    ImmSrc = 3'b000;
    PCSrc = 1'b0;
    ResultSrc = 1'b0;
    ALUSrc = 1'b0;
    ALUctrl = 4'b0000;
    RegWrite = 1'b0;
    MemWrite = 1'b0;
    funct3O = funct3;
    MUXjump = 1'b0;
    JumpPRT = 1'b0;
    ALUImmSelect = 1'b0;
    
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
                    ALUctrl = 4'b1000;
                    ImmSrc = 3'b001;
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
                            ImmSrc = 3'b001;
                        end
                    endcase
                end
                
                // SRLI and SRAI
                3'b101: begin
                    case(funct7)
                        // SRLI
                        7'h00: begin
                            ALUctrl = 4'b0110; // Abraham needs to implement this and change it
                            ImmSrc = 3'b001;
                        end
                        // SRAI
                        7'h20: begin
                            ALUctrl = 4'b0111; // Abraham needs to implement this and change it
                            ImmSrc = 3'b001;
                        end
                    endcase
                end

                // SLTI
                3'b010: begin
                    ALUctrl = 4'b1000;
                end

                // SLTIU
                3'b011: begin
                    ALUctrl = 4'b1001;
                    ImmSrc = 3'b001;
                end
            endcase
        end
        

        // Load instructions
        7'b0000011: begin
            ALUSrc = 1'b1;
            ResultSrc = 1'b1;
            RegWrite = 1'b1;
        end

        // Store instructions
        7'b0100011: begin
            MemWrite = 1'b1;
            ALUSrc = 1'b1;
            ImmSrc = 3'b010;
        end

        // LUI
        7'b0110111: begin
            ALUctrl = 4'b1010;
            ALUSrc = 1'b1;
            ImmSrc = 3'b100;
            RegWrite = 1'b1;
        end

        // AUIPC
        7'b0010111: begin
            PCSrc = 1'b1;
            ALUctrl = 4'b1001;
            ALUSrc = 1'b1;
            ImmSrc = 3'b100;
            RegWrite = 1'b1;
            ALUImmSelect = 1'b1;
        end

        // JAL
        7'b1101111: begin
            RegWrite = 1'b1;
            MUXjump = 1'b1;
            PCSrc = 1'b1;
            ImmSrc = 3'b101;
        end

        // JALR
        7'b1101111: begin
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            PCSrc = 1'b1;
            MUXjump = 1'b1;
            ALUSrc = 1'b1;
            JumpPRT = 1'b1;
        end     

        // B-type instructions
        7'b1100011: begin
            ImmSrc = 3'b011;
            case(funct3)
                // BEQ
                3'b000: begin
                    PCSrc = Zero;
                end
                
                // BNE
                3'b001:begin
                    PCSrc = ~Zero;  // !=
                end
                
                // BLT
                3'b100: begin
                    PCSrc = Less;   // < (signed)
                end
                
                // BGE
                3'b101: begin
                    PCSrc = ~Less;  // >= (signed) equivalent of not less than
                end

                // BLTU
                3'b110: begin
                    PCSrc = LessU;  // < (unsign)
                end

                // BGEU
                3'b111: begin
                    PCSrc = ~LessU; // >= (unsign) equivalent of not less than
                end
            endcase
        end
    
    endcase
end

endmodule
