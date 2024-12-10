#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class HazardUnitTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->rst = 1'b0;
        top->Rs1D = 5'b00000;
        top->Rs2D = 5'b00000;
        top->Rs1E = 5'b00000;
        top->Rs2E = 5'b00000;
        top->RdE = 5'b00000;
        top->RdM = 5'b00000;
        top->RdW = 5'b00000;
        top->RegWriteM = 1'b0;
        top->RegWriteW = 1'b0;
        top->LoadE = 1'b0;
        top->PCSrc = 1'b0;
    }
};

TEST_F(HazardUnit_Testbench, ForwardA_WB)
{
    top->Rs1E = 5'b00110;
    top->RdM = 5'b00110;
    top->RegWriteM = 1'b1;
    top->eval();

    EXPECT_EQ(top->ForwardA, 2'b10);
}

TEST_F(HazardUnit_Testbench, ForwardA_MEM)
{
    top->Rs1E = 5'b00110;
    top->RdW = 5'b00110;
    top->RegWriteW = 1'b1;
    top->eval();

    EXPECT_EQ(top->ForwardA, 2'b01);
}

TEST_F(HazardUnit_Testbench, ForwardB_WB)
{
    top->Rs2E = 5'b00110;
    top->RdW = 5'b00110;
    top->RegWriteW = 1'b1;
    top->eval();

    EXPECT_EQ(top->ForwardB, 2'b01);
}

TEST_F(HazardUnit_Testbench, ForwardB_MEM)
{
    top->Rs2E = 5'b00110;
    top->RdM = 5'b00110;
    top->RegWriteW = 1'b1;
    top->eval();

    EXPECT_EQ(top->ForwardB, 2'b10);
}

TEST_F(HazardUnit_Testbench, Stall1)
{
    top->Rs1D = 5'b00110;
    top->RdE = 5'b00110;
    top->LoadE = 1'b1;
    top->eval();

    EXPECT_EQ(top->Flush, 1'b1);
}

TEST_F(HazardUnit_Testbench, Stall2)
{
    top->Rs2D = 5'b00110;
    top->RdE = 5'b00110;
    top->LoadE = 1'b1;
    top->eval();

    EXPECT_EQ(top->Stall, 1'b1);
}

TEST_F(HazardUnit_Testbench, Flush1)
{
    top->rst = 1'b1;
    top->eval();

    EXPECT_EQ(top->Flush, 1'b1);
}

TEST_F(HazardUnit_Testbench, Flush2)
{
    top->PCSrc = 1'b1;
    top->eval();

    EXPECT_EQ(top->Flush, 1'b1);
}

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

    return res;
}