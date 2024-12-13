#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class HazardUnitTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->rst = 0;
        top->Rs1D = 0;
        top->Rs2D = 0;
        top->Rs1E = 0;
        top->Rs2E = 0;
        top->RdE = 0;
        top->RdM = 0;
        top->RdW = 0;
        top->RegWriteM = 0;
        top->RegWriteW = 0;
        top->LoadE = 0;
        top->PCSrc = 0;
    }
};

TEST_F(HazardUnitTestbench, ForwardA_WB)
{
    top->Rs1E = 0b00101;
    top->RdM = 0b00101;
    top->RegWriteM = 1;
    top->eval();

    EXPECT_EQ(top->ForwardA, 2);
}

TEST_F(HazardUnitTestbench, ForwardA_MEM)
{
    top->Rs1E = 0b00101;
    top->RdM = 0b00101;
    top->RegWriteM = 1;
    top->eval();

    EXPECT_EQ(top->ForwardA, 2);
}

TEST_F(HazardUnitTestbench, ForwardB_WB)
{
    top->Rs2E = 0b00101;
    top->RdW = 0b00101;
    top->RegWriteW = 1;
    top->eval();

    EXPECT_EQ(top->ForwardB, 1);
}

TEST_F(HazardUnitTestbench, ForwardB_MEM)
{
    top->Rs2E = 0b00101;
    top->RdM = 0b00101;
    top->RegWriteM = 1;
    top->eval();

    EXPECT_EQ(top->ForwardB, 2);
}

TEST_F(HazardUnitTestbench, Stall1)
{
    top->Rs1D = 0b00101;
    top->RdE = 0b00101;
    top->LoadE = 1;
    top->eval();

    EXPECT_EQ(top->Stall, 1);
}

TEST_F(HazardUnitTestbench, Stall2)
{
    top->Rs2D = 0b00101;
    top->RdE = 0b00101;
    top->LoadE = 1;
    top->eval();

    EXPECT_EQ(top->Stall, 1);
}

TEST_F(HazardUnitTestbench, Flush1)
{
    top->rst = 1;
    top->eval();

    EXPECT_EQ(top->Flush, 1);
}

TEST_F(HazardUnitTestbench, Flush2)
{
    top->PCSrc = 1;
    top->eval();

    EXPECT_EQ(top->Flush, 1);
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