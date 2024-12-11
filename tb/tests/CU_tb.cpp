#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

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
};

// Test for R-Type instructions
TEST_F(CU_Testbench, ADD) {
    // Test ADD

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000;
    top->funct7_5 = 0b1;
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0001);
}

TEST_F(CU_Testbench, SUB){

    // Test SUB
    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000;
    top->funct7_5 = 0b0;
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b000);
}

TEST_F(CU_Testbench, XOR){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b100;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0100);
}

TEST_F(CU_Testbench, OR){
    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b110;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0011);
}

TEST_F(CU_Testbench, AND){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b111;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0010);
}

TEST_F(CU_Testbench, LSL){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b001;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0101);
}

TEST_F(CU_Testbench, LSR){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b101;
    top->funct7_5 = 0b0;
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0111);

}

TEST_F(CU_Testbench, ASR){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b111;
    top->funct7_5 = 0b1; 
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0110);
}

TEST_F(CU_Testbench, SLT){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b010;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1001);
}

TEST_F(CU_Testbench, SLTU){

    top->op = 0b0110011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b011;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1010);
    EXPECTED_EQ(top->ImmSrc = 0b001);

}

// Test for I-Type instructions
TEST_F(CU_Testbench, ADDI) {

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0000);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

TEST_F(CU_Testbench, XORI){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0; //do i need this line explicityl mentioned
    top->funct3 = 0b100;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0100);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);

}

TEST_F(CU_Testbench, ORI){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b110;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0011);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

EXPECTED_F(CU_Testbench, ANDI){
    
    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b111;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0010);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

EXPECTED_F(CU_Testbench, SLLI){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b001;
    top->funct7_5 = 0b0; 
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0101);
    EXPECTED_EQ(top->ImmSrc = 0b001);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

TEST_F(CU_Testbench, SRLI){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000;
    top->funct7_5 = 0b0; 
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1000);
    EXPECTED_EQ(top->ImmSrc = 0b001);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

TEST_F(CU_Testbench, SRAI){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000;
    top->funct7_5 = 0b1; 
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0110);
    EXPECTED_EQ(top->ImmSrc = 0b001)
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

TEST_F(CU_Testbench, SLTI){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b010;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1001);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

TEST_F(CU_Testbench, SLTIU){

    top->op = 0b010011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000;
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1010);
    EXPECTED_EQ(top-ImmSrc = 0b001);
    EXPECTED_EQ(top->RegWrite = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
}

// Test for LW and SW instructions
TEST_F(CU_Testbench, LoadInstruction) {
    top->op = 0b0000011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0000);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ImmSrc = 0b010);
    EXPECTED_EQ(top->MemWrite = 0b1);

}


TEST_F(CU_Testbench, StoreInstruction){
    top->op = 0b0100011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b0000);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ImmSrc = 0b010);
    EXPECTED_EQ(top->MemWrite = 0b1);
}

TEST_F(CU_Testbench, LUI){

    top->op = 0b0110111;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1011);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ImmSrc = 0b100);
    EXPECTED_EQ(top->RegWrite = 0b1);
}

TEST_F(CU_Testbench, AUIPC){

    top->op = 0b0010111;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUctrl = 0b1011);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ALUSrcA = 0b1);
    EXPECTED_EQ(top->ImmSrc = 0b100);
    EXPECTED_EQ(top->RegWrite = 0b1);
}

TEST_F(CU_Testbench, JAL) {

    top->op = 0b1101111;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ALUSrcA = 0b1);
    EXPECTED_EQ(top->ImmSrc = 0b101);
    EXPECTED_EQ(top->ResultSrc = 0b10);
    EXPECTED_EQ(top->Jump = 0b1);
}

TEST_F(CU_Testbench, JALR){

    top->op = 0b1100111;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ALUSrcA = 0b0);
    EXPECTED_EQ(top->ResultSrc = 0b10);
}

TEST_F(CU_Testbench, B_type){

    top->op = 0b1100011;
    top->Stall = 0b0;
    top->Flush = 0b0;
    top->funct3 = 0b000; //do i need this line mentioned
    top->funct7_5 = 0b0; //do i need this line explicitily mentioned
    top->eval();

    EXPECTED_EQ(top->Branch = 0b1);
    EXPECTED_EQ(top->ALUSrcA = 0b1);
    EXPECTED_EQ(top->ALUSrcB = 0b1);
    EXPECTED_EQ(top->ImmSrc = 0b011);
}

// " Test for Flush and Stall behavior
/* TEST_F(CU_Testbench, FlushAndStallBehavior) {
    /// Test with Flush
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
} */

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    