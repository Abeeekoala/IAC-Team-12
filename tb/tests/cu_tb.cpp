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
        top->ImmSrc = 0; 
        top->MemWrite = 0; 
        top->RegWrite = 0; 
        top->ALUctrl = 0; 
        top->ALUSrcA = 0; 
        top->ALUSrcB = 0; 
        top->ResultSrc = 0; 
        top->Branch = 0; 
        top->Jump = 0; 
        top->eval();

    }

    void initialiseCUInputs (ControlUnitTestbench* tb,
        int funct3,
        int op,
        bool funct7_5,
        bool Flush,
        bool Stall,
    )

    tb->top->funct3 = 0b101; //3 bits for funct3
    tb->top->op = 0b0110011; //7 bits for opcode
    tb->top->funct7_5 = 0;  //1 bit for funct7[5]
    tb->top->Flush = 1;     //1 bit flush signal
    tb->top->Stall = 0;     //1-bit stall signal
    top->eval();

};

TEST_F(CU_Testbench, RTypeInstructions) {
    // Test ADD
    setInputs(OPCODE_R, 0b000, 0);
    EXPECT_EQ(top->ALUctrl, 0b0000);
    EXPECT_EQ(top->RegWrite, 1);

    // Test SUB
    setInputs(OPCODE_R, 0b000, 1);
    EXPECT_EQ(top->ALUctrl, 0b0001);

    // Test AND
    setInputs(OPCODE_R, 0b111);
    EXPECT_EQ(top->ALUctrl, 0b0010);

    // Test OR
    setInputs(OPCODE_R, 0b110);
    EXPECT_EQ(top->ALUctrl, 0b0011);

    // Test XOR
    setInputs(OPCODE_R, 0b100);
    EXPECT_EQ(top->ALUctrl, 0b0100);

    // Test SLL
    setInputs(OPCODE_R, 0b001);
    EXPECT_EQ(top->ALUctrl, 0b0101);

    // Test SRL
    setInputs(OPCODE_R, 0b101, 0);
    EXPECT_EQ(top->ALUctrl, 0b0110);

    // Test SRA
    setInputs(OPCODE_R, 0b101, 1);
    EXPECT_EQ(top->ALUctrl, 0b0111);

    // Test SLT
    setInputs(OPCODE_R, 0b010);
    EXPECT_EQ(top->ALUctrl, 0b1001);

    // Test SLTU
    setInputs(OPCODE_R, 0b011);
    EXPECT_EQ(top->ALUctrl, 0b1010);
}

TEST_F(CU_Testbench, ITypeInstructions) {
    // Test ADDI
    setInputs(OPCODE_I, 0b000);
    EXPECT_EQ(top->ALUctrl, 0b0000);
    EXPECT_EQ(top->RegWrite, 1);
    EXPECT_EQ(top->ALUSrcB, 1);

    // Test XORI
    setInputs(OPCODE_I, 0b100);
    EXPECT_EQ(top->ALUctrl, 0b0100);

    // Test ORI
    setInputs(OPCODE_I, 0b110);
    EXPECT_EQ(top->ALUctrl, 0b0011);

    // Test ANDI
    setInputs(OPCODE_I, 0b111);
    EXPECT_EQ(top->ALUctrl, 0b0010);
}

TEST_F(CU_Testbench, LWAndSWInstructions) {
    // Test LW
    setInputs(OPCODE_LW, 0b010);
    EXPECT_EQ(top->MemWrite, 0);
    EXPECT_EQ(top->ALUSrcB, 1);
    EXPECT_EQ(top->RegWrite, 1);

    // Test SW
    setInputs(OPCODE_SW, 0b010);
    EXPECT_EQ(top->MemWrite, 1);
    EXPECT_EQ(top->RegWrite, 0);
}

TEST_F(CU_Testbench, BranchInstructions) {
    // Test BEQ
    setInputs(OPCODE_BEQ, 0b000);
    EXPECT_EQ(top->Branch, 1);
    EXPECT_EQ(top->ALUctrl, 0b0001); // SUB for comparison
}

TEST_F(CU_Testbench, JumpInstructions) {
    // Test JAL
    setInputs(OPCODE_JAL, 0);
    EXPECT_EQ(top->Jump, 1);
    EXPECT_EQ(top->ResultSrc, 2);
}

TEST_F(CU_Testbench, FlushAndStallBehavior) {
    // Test with Flush
    top->Flush = 1;
    setInputs(OPCODE_R, 0b000);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->MemWrite, 0);

    // Test with Stall
    top->Flush = 0;
    top->Stall = 1;
    setInputs(OPCODE_R, 0b000);
    EXPECT_EQ(top->RegWrite, 0);
    EXPECT_EQ(top->MemWrite, 0);
}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();