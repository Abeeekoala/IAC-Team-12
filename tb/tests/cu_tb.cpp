#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;

class CUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->funct3 = 0;
        top->opcode = 0;
        top->funct7 = 0;
        top->EQ     = 0; 
    }


};

TEST_F(CUTestbench, DefaultOutputTest)
{
    top->sel = 0;
    top->in0 = 1;
    top->in1 = 0;

    top->eval();

    EXPECT_EQ(top->out, 1);
}