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

TEST_F(HazardUnit_Testbench, ForwardA_WB)
{
    top->Rs1E = 29;
    top->RdM = 29;
    top->RegWriteM = 1;
    top->eval();

    EXPECT_EQ(top->ForwardA, 2);
}

TEST_F(HazardUnit_Testbench, ForwardA_MEM)
{
    top->Rs1E = 29;
    top->RdW = 29;
    top->RegWriteW = 1;
    top->eval();

    EXPECT_EQ(top->ForwardA, 1);
}

TEST_F(HazardUnit_Testbench, ForwardB_WB)
{
    top->Rs2E = 29;
    top->RdW = 29;
    top->RegWriteW = 1'b1;
    top->eval();

    EXPECT_EQ(top->ForwardB, 1);
}

TEST_F(HazardUnit_Testbench, ForwardB_MEM)
{
    top->Rs2E = 29;
    top->RdM = 29;
    top->RegWriteW = 1;
    top->eval();

    EXPECT_EQ(top->ForwardB, 2);
}

TEST_F(HazardUnit_Testbench, Stall1)
{
    top->Rs1D = 29;
    top->RdE = 29;
    top->LoadE = 1;
    top->eval();

    EXPECT_EQ(top->Flush, 1);
}

TEST_F(HazardUnit_Testbench, Stall2)
{
    top->Rs2D = 29;
    top->RdE = 29;
    top->LoadE = 1;
    top->eval();

    EXPECT_EQ(top->Stall, 1);
}

TEST_F(HazardUnit_Testbench, Flush1)
{
    top->rst = 1;
    top->eval();

    EXPECT_EQ(top->Flush, 1);
}

TEST_F(HazardUnit_Testbench, Flush2)
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