#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;

class InstrMemTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->addr = 0;
    }
};

TEST_F(InstrMemTestbench, Addr0InitTest)
{
    top->addr = 0;

    top->eval();

    EXPECT_EQ(top->instr, 0x0ff00313);
}

TEST_F(InstrMemTestbench, SequenceFetchTest)
{
    std::vector<uint32_t> expected = {
        0x0ff00313,
        0x00000513,
        0x00000593,
        0x00058513,
        0x00158593,
        0xfe659ce3,
        0xfe0318e3};
    int addr = 0;
    for (uint32_t exp: expected){
        top->addr = addr;
        top->eval();
        EXPECT_EQ(static_cast<uint32_t>(top->instr), exp);
        addr += 4;
    }

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