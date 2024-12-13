#include "base_testbench.h"

class SignExtTestbench : public BaseTestbench
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
        top->Instr = 0;
        top->ImmSrc = 0;
    }
};

TEST_F(SignExtTestbench, ITypeSignedExtensionTest)
{
    top->ImmSrc = 0b000;
    top->Instr = 0x1FF2345; // I-type MS 12 Bits is Imm[11:0] = 0xFF9
    top->eval();
    EXPECT_EQ(static_cast<int32_t>(top->ImmExt), static_cast<int32_t>(0xFFFFFFF9)); // Sign-extended 32-bit immediate should be 0xFFFFFFF9
}

TEST_F(SignExtTestbench, ITypeUnsignedExtensionTest)
{
    top->ImmSrc = 0b001;
    top->Instr = 0x1FF2345; // I-type MS 12 Bits is Imm[11:0] = 0xFF9
    top->eval();
    EXPECT_EQ(top->ImmExt, 0x00000FF9); // Zero-extended 32-bit immediate = 0x00000FF9
}

TEST_F(SignExtTestbench, STypeExtensionTest)
{
    top->ImmSrc = 0b010;
    top->Instr = 0x1FF2345; // S-type immediate; Imm[11:0] = 0xFE5
    top->eval();
    EXPECT_EQ(static_cast<int32_t>(top->ImmExt), static_cast<int32_t>(0xFFFFFFE5)); // Sign-extended S-type immediate
}

TEST_F(SignExtTestbench, BTypeExtensionTest)
{
    top->ImmSrc = 0b011;
    top->Instr = 0x1FF2345; //  B-type immediate; Imm[12:1] = 0xFF2
    top->eval();
    EXPECT_EQ(static_cast<int32_t>(top->ImmExt), static_cast<int32_t>(0xFFFFFFE4)); // Sign-extended B-type immediate
}

TEST_F(SignExtTestbench, UTypeExtensionTest)
{
    top->ImmSrc = 0b100;
    top->Instr = 0x1FF2345; // U-type immediate; Imm[31:12] = 0xFF91A
    top->eval();
    EXPECT_EQ(top->ImmExt, 0xFF91A000); // U-type immediate with lower 12 bits set to 0
}

TEST_F(SignExtTestbench, JTypeExtensionTest)
{
    top->ImmSrc = 0b101;
    top->Instr = 0x1FF2345; //J-type immediate; Imm[20:0] = 0x11AFF8 LS21 Bits
    top->eval();
    EXPECT_EQ(static_cast<int32_t>(top->ImmExt), static_cast<int32_t>(0xFFFF1AFF8)); // Sign-extended J-type immediate
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    return res;
}
