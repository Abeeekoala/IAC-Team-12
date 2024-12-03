module CU (
    input logic [2:0]       funct3,
    input logic [6:0]       op,
    input logic             funct7_5,
    input logic             Zero,
    input logic             Less,
    input logic             LessU,
    output logic [2:0]      ImmSrc,
    output logic            PCSrc,
    output logic            PCTarget_sel,
    output logic            MemWrite,
    output logic            RegWrite,
    output logic [3:0]      ALUctrl,
    output logic            ALUSrc,
    output logic [1:0]      ResultSrc
);

always_comb begin
    ImmSrc = 3'b000;
    PCSrc = 1'b0;
    PCTarget_sel = 1'b0;
    ResultSrc = 2'b00;
    ALUSrc = 1'b0;
    ALUctrl = 4'b1111; //Not occupied control signal to handle faulty command
    RegWrite = 1'b0;
    MemWrite = 1'b0;
    
    case(op)
        // r-type instructions
        7'b0110011: begin
            RegWrite = 1'b1;
            case(funct3)
                3'b000: begin
                    //Add if (funct7_5) else sub
                    ALUctrl = funct7_5 ? 4'b0001 : 4'b0000;
                end
                
                // XOR
                3'b100: begin
                    ALUctrl = 4'b0100;
                end

                // OR
                3'b110: begin
                    ALUctrl = 4'b0011;
                end

                // AND
                3'b111: begin
                    ALUctrl = 4'b0010;
                end

                // Logical Shift Left
                3'b001: begin
                    ALUctrl = 4'b0101;
                end

                // Shift Right
                3'b101: begin
                    //Arith if (funct7_5) else logical
                    ALUctrl = funct7_5 ? 4'b0111 : 4'b0110; //logical
                end

                // Set Less Than
                3'b010: begin
                    ALUctrl = 4'b1001;
                end

                // Set Less Than (U)
                3'b011: begin
                    ALUctrl = 4'b1010;
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
                    ALUctrl = 4'b0100;
                end

                // ORI
                3'b110: begin
                    ALUctrl = 4'b0011;
                end

                // ANDI
                3'b111: begin
                    ALUctrl = 4'b0010;
                end
                
                // SLLI
                3'b001: begin
                    if (~funct7_5) begin
                        ALUctrl = 4'b0101;
                        ImmSrc = 3'b001;
                    end
                end
                
                // SRLI and SRAI
                3'b101: begin
                    ALUctrl = funct7_5 ? 4'b1000 : 4'b0110;
                    ImmSrc = 3'b001;
                end

                // SLTI
                3'b010: begin
                    ALUctrl = 4'b1001;
                end

                // SLTIU
                3'b011: begin
                    ALUctrl = 4'b1010;
                    ImmSrc = 3'b001;
                end
            endcase
        end
    
        // Load instructions
        7'b0000011: begin
            ALUctrl = 4'b0000;
            ALUSrc = 1'b1;
            ResultSrc = 2'b01;
            RegWrite = 1'b1;
        end

        // Store instructions
        7'b0100011: begin
            ALUctrl = 4'b0000;
            ALUSrc = 1'b1;
            // ResultSrc = 2'b01;
            MemWrite = 1'b1;
            ImmSrc = 3'b010;
        end

        // LUI
        7'b0110111: begin
            ALUctrl = 4'b1011;
            ALUSrc = 1'b1;
            ImmSrc = 3'b100;
            RegWrite = 1'b1;
        end

        // AUIPC
        7'b0010111: begin
            ALUSrc = 1'b1;
            ImmSrc = 3'b100;
            RegWrite = 1'b1;
            ALUctrl = 4'b1011;
            ResultSrc = 2'b11;
        end

        // JAL
        7'b1101111: begin
            RegWrite = 1'b1;
            PCSrc = 1'b1;
            ImmSrc = 3'b101;
            ResultSrc = 2'b10;
        end

        // JALR
        7'b1100111: begin
            RegWrite = 1'b1;
            PCTarget_sel = 1'b1;
            PCSrc = 1'b1;
            ResultSrc = 2'b10;
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
