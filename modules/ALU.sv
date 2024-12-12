module ALU #(
    DATA_WIDTH = 32
) (
    input logic     [DATA_WIDTH-1:0]    ALUop1,
    input logic     [DATA_WIDTH-1:0]    ALUop2,
    input logic     [7:0]               ALUctrl,
    output logic    [DATA_WIDTH-1:0]    ALUout
);

always_comb begin
    case(ALUctrl)
        4'b0000: ALUout = ALUop1 + ALUop2;          // ADD
        4'b0001: ALUout = ALUop1 - ALUop2;          // SUB
        4'b0010: ALUout = ALUop1 & ALUop2;          // AND
        4'b0011: ALUout = ALUop1 | ALUop2;          // OR           
        4'b0100: ALUout = ALUop1 ^ ALUop2;          // XOR
        4'b0101: ALUout = ALUop1 << ALUop2;         // LSL
        4'b0110: ALUout = ALUop1 >> ALUop2;         // LSR    
        4'b0111: ALUout = ALUop1 >>> ALUop2;        // ASR for register
        4'b1000: ALUout = ALUop1 >>> ALUop2[4:0];    // ASR for Imm
        4'b1001: ALUout = ($signed(ALUop1) < $signed(ALUop2)) ? 32'd1 : 32'd0; // set less than
        4'b1010: ALUout = (ALUop1 < ALUop2) ? 32'd1 : 32'd0; // set less than (U)
        4'b1011: ALUout = ALUop2;
        default: begin
            ALUout = 32'b0;
        end
    endcase 

    //zero = 1'b1;
    //negative = 1'b0;

    /* case (ALUctrl)
        8'b0000_0000: begin
            ALUoutA = ALUop1A + ALUop1B;   // ADD
            ALUoutB = ALUop2A + ALUop2B;
        end
        8'b0001_0001: begin
            ALUoutA = ALUop1A - ALUop1B;   // SUB
            ALUoutB = ALUop2A - ALUop2B;
        end
        8'b0010_0010: begin
            ALUoutA = ALUop1A & ALUop1B;   // AND
            ALUoutB = ALUop2A & ALUop2B;
        end
        8'b0011_0011: begin
            ALUoutA = ALUop1A | ALUop1B;   // OR
            ALUoutB = ALUop2A | ALUop2B;
        end
        8'b0100_0100: begin
            ALUoutA = ALUop1A ^ ALUop1B;   // XOR
            ALUoutB = ALUop2A ^ ALUop2B;
        end
        8'b0101_0101: begin
            ALUoutA = ALUop1A << ALUop1B[4:0];  // LSL
            ALUoutB = ALUop2A << ALUop2B[4:0];
        end
        8'b0110_0110: begin
            ALUoutA = ALUop1A >> ALUop1B[4:0];  // LSR
            ALUoutB = ALUop2A >> ALUop2B[4:0];
        end
        8'b0111_0111: begin
            ALUoutA = ALUop1A >>> ALUop1B[4:0];  // ASR for ALUop1A
            ALUoutB = ALUop2A >>> ALUop2B[4:0];  // ASR for ALUop1B
        end
        8'b1000_1000: begin
            ALUoutA = ALUop1A >>> ALUop1B[4:0];  // ASR for Imm
            ALUoutB = ALUop2A >>> ALUop2B[4:0];  // ASR for Imm
        end
        8'b1001_1001: begin
            ALUoutA = ($signed(ALUop1A) < $signed(ALUop1B)) ? 32'd1 : 32'd0; // SLT
            ALUoutB = ($signed(ALUop2A) < $signed(ALUop2B)) ? 32'd1 : 32'd0;
        end
        8'b1010_1010: begin
            ALUoutA = (ALUop1A < ALUop1B) ? 32'd1 : 32'd0; // SLTU
            ALUoutB = (ALUop2A < ALUop2B) ? 32'd1 : 32'd0;
        end
        8'b1011_1011: begin
            ALUoutA = ALUop1B;  // MOV
            ALUoutB = ALUop2B;  // MOV
        end
        default: begin
            ALUoutA = 32'b0;
            ALUoutB = 32'b0;
        end 
    endcase */

end

endmodule
