#include "base_testbench.h"

class PCregTestbench : public BaseTestbench
{
protected:
    
    Vdut *top;
    VerilatedVcdC *tfp;
    unsigned int ticks = 0;

    void SetUp() override
    {
        top = new Vdut;
        tfp = new VerilatedVcdC;
        ticks = 0;

        // Enable waveform tracing
        Verilated::traceEverOn(true);
        top->trace(tfp, 99);
        tfp->open("waveform.vcd");

        initializeInputs();
        runReset();
    }

    void TearDown() override {
        // Finalize and clean up
        top->final();
        tfp->close();
        delete top;
        delete tfp;
    }

    void initializeInputs() override
    {
        top->next_PC = 0;
        top->rst = 0;
        top->clk = 0;
        // output: out
    }

    void runReset()
    {
        top->rst = 1;
        runSimulation();
        top->rst = 0;
    }

    void runSimulation()
    {
        for (int clk = 0; clk < 2; clk++)
        {
            top->eval();
            tfp->dump(2 * ticks + clk);
            top->clk = !top->clk;
        }
        ticks++;

        if (Verilated::gotFinish())
        {
            exit(0);
        }
    }
};



TEST_F(PCregTestbench, InitializationTest)
{
    top->rst = 1;
    runSimulation();

    EXPECT_EQ(top->PC, 0);
}

TEST_F(PCregTestbench, UpdatePCTest)
{
    top->rst = 0;
    top->next_PC = 0x000123EF;

    runSimulation();
    runSimulation();
    EXPECT_EQ(top->PC, 0x000123EF);
}

int main(int argc, char **argv)
{

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    return res;
}