#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, TestNoHazard)
{
    setupTest("0_no_hazard");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 39);
}

TEST_F(CpuTestbench, TestAddiBne)
{
    setupTest("1_addi_bne");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 254);
}

TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    setData("reference/gaussian.mem");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 15363);
}

TEST_F(CpuTestbench, TestLightSequence) {
    // Run simulation with trigger signal
    setupTest("6_F1_Light");
    initSimulation();
    
    runSimulation(100); //change the cycle to get different delay cycles
    top_->trigger = 1;

    // Validate light sequence
    waitForOutput(0x0,  0x1,  500);  // S0 expect S1
    waitForOutput(0x1,  0x3,  500);  // S1 expect S2
    waitForOutput(0x3,  0x7,  500);  // S2 expect S3
    waitForOutput(0x7,  0xF,  500);  // S3 expect S4
    waitForOutput(0xF,  0x1F, 500);  // S4 expect S5
    waitForOutput(0x1F, 0x3F, 500);  // S5 expect S6
    waitForOutput(0x3F, 0x7F, 500);  // S6 expect S7
    waitForOutput(0x7F, 0xFF, 500);  // S7 expect S8
    waitForOutput(0xFF, 0x0,  500);  // S8 expect S0
    waitForOutput(0x0,  0x1,  500);  // cycle back
}

TEST_F(CpuTestbench, TestDataHazard)
{
    setupTest("7_data_hazard");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, -10);
}

TEST_F(CpuTestbench, TestDataHazardWithRest)
{
    setupTest("8_data_hazard_with_reset");
    initSimulation();
    runSimulation(3);
    reset(5); // reset for 2 cycles
    EXPECT_EQ(top_->a0, 50);
    runSimulation(30);
    EXPECT_EQ(top_->a0, -10);


}


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
