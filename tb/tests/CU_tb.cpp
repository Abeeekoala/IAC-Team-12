#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;

class CUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->funct3 = 0;
        top->op = 0;
        top->funct7_5 = 0;
        top->Flush = 0; 
        top->Stall = 0; 
        top->eval();

    }

    void setInputs(uint32_t op, uint32_t funct3 = 0, uint32_t funct7_5 = 0, uint32_t Flush = 0, uint32_t = Stall = 0){
        top->op = op;
        top->funct3 = funct3;
        top->funct7_5 = funct7_5;
        top->Flush = Flush;
        top->Stall = Stall;
        top->eval();

    }

    tb->top->funct3 = 0b101; //3 bits for funct3
    tb->top->op = 0b0110011; //7 bits for op
    tb->top->funct7_5 = 0;  //1 bit for funct7[5]
    tb->top->Flush = 1;     //1 bit flush signal
    tb->top->Stall = 0;     //1-bit stall signal
    top->eval();

};

// Test for R-Type instructions
TEST_F(CU_Testbench, RTypeInstructions) {
    // Test ADD
    setInputs(b0110011, b000, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0000);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test SUB
    setInputs(b0110011, b000, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0001);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test XOR
    setInputs(b0110011, b100, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0100);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test OR
    setInputs(b0110011, b110, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0011);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test AND
    setInputs(b0110011, b111, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0010);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);    

    // Test LSL
    setInputs(b0110011, b001, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0101);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test LSR
    setInputs(b0110011, b101, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0110);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test SLT
    setInputs(b0110011, b010, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0111);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test SLTU
    setInputs(b0110011, b011, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b1001);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test SLTU
    setInputs(b0110011, b011, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b1010);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 0);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);
}

// Test for I-Type instructions
TEST_F(CU_Testbench, ITypeInstructions) {
    // Test ADDI
    setInputs(b0010011, b000, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0000);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test XORI
    setInputs(b0010011, b100, 0b000000, 0, 0);
    EXPECT_EQ(top->ALUctrl, 0b0100);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test ORI
    setInputs(b0010011, b110, 0b000000, 0, 0);
    EXPECT_EQ(top->ALUctrl, 0b0011);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // Test ANDI
    setInputs(b0010011, b111);
    EXPECT_EQ(top->ALUctrl, 0b0010);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    //TEST SLLI
    setInputs(b0010011, b001, b0, b0, b0)
    EXPECT_EQ(top->ALUctrl, 0b0101)
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0b001);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // TEST SRLI
    setInputs (b0010011, b101, b0, b0, b0)
    EXPECT_EQ(top->ALUctrl, b0110)
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0b001);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // TEST SRAI
    setInputs (b0010011, b101, b1, b0, b0)
    EXPECT_EQ(top->ALUctrl, b1000)
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // TEST SLTI
    setInputs (b0010011, b010, b0, b0, b0)
    EXPECT_EQ(top->ALUctrl, 0b1001)
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);

    // TEST SLTIU
    setInputs (b0010011, b011, b0, b0, b0)
    EXPECT_EQ(top->ALUctrl, 0b1010)
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0b001);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);
}

// Test for LW and SW instructions
TEST_F(CU_Testbench, LWAndSWInstructions) {
    // Test LW
    setInputs(b0000011, b000, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0000);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 0);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 1);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);


    // Test SW
    setInputs(b0000011, b000, b0, b0, b0);
    EXPECT_EQ(top->ALUctrl, 0b0000);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->ImmSrc, 0b010);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcA, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 0);
    EXPECT_EQ(top->Branch, 0);
    EXPECT_EQ(top->Jump, 0);
}

// Test for Jump instructions
TEST_F(CU_Testbench, JumpInstructions) {
    // Test JAL
    setInputs(0b1101111);
    EXPECT_EQ(top->ALUctrl, 0b0010);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 1);
    EXPECT_EQ(top->MemWrite, 1);
    EXPECT_EQ(top->ALUSrcA, 1);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 1);
    EXPECT_EQ(top->Branch, 1);
    EXPECT_EQ(top->Jump, 1);
}

    // Test JALR
    setInputs(0b1100111);
    EXPECT_EQ(top->ALUctrl, 0b0010);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 1);
    EXPECT_EQ(top->MemWrite, 1);
    EXPECT_EQ(top->ALUSrcA, 1);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 1);
    EXPECT_EQ(top->Branch, 1);
    EXPECT_EQ(top->Jump, 1);
}

// Test for Flush and Stall behavior
TEST_F(CU_Testbench, FlushAndStallBehavior) {
    // Test with Flush
    top->Flush = 1;
    setInputs(0b000);
    EXPECT_EQ(top->ALUctrl, 0b0010);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 1);
    EXPECT_EQ(top->MemWrite, 1);
    EXPECT_EQ(top->ALUSrcA, 1);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 1);
    EXPECT_EQ(top->Branch, 1);
    EXPECT_EQ(top->Jump, 1);

    // Test with Stall
    top->Flush = 0;
    top->Stall = 1;
    setInputs(0b000);
    EXPECT_EQ(top->ALUctrl, 0b0010);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ImmSrc, 1);
    EXPECT_EQ(top->MemWrite, 1);
    EXPECT_EQ(top->ALUSrcA, 1);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->ResultSrc, 1);
    EXPECT_EQ(top->Branch, 1);
    EXPECT_EQ(top->Jump, 1);
}