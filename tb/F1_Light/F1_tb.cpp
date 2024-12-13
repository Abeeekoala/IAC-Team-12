#include "../obj_dir/Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../../vbuddy.cpp"
#define MAX_CYC 100000


uint16_t intToBCD(int decimal) {
    uint16_t bcd = 0;
    int shift = 0;

    // Process each decimal digit and store it in the BCD representation
    while (decimal > 0 && shift < 16) {
        int digit = decimal % 10;                  // Get the last decimal digit
        bcd |= (digit << shift);                   // Place the BCD digit in the correct position
        decimal /= 10;                             // Move to the next decimal digit
        shift += 4;                                // Move 4 bits for the next BCD digit
    }

    return bcd;
}

int main(int argc, char **argv, char **env){
    int clk;
    uint16_t time;
    bool pressed;
    bool timing = 0;

    Verilated::commandArgs(argc, argv);

    Vtop* top = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("F1_light.vcd");

    //init Vbuddy
    if (vbdOpen() != 1) return(-1);
    vbdHeader("F1 Light");
    vbdSetMode(1);

    top->clk = 1;
    top->rst = 1;

    for (int cycle = 0; cycle < MAX_CYC; cycle++){
        // dump variable into VCD file and toggle clock
        for (int tick = 0; tick < 2; tick ++){
            tfp->dump (2*cycle + tick);
            top->clk = !top->clk;
            top->eval ();
        }
        if (cycle > 10){
            top->rst = 0;
        }

        vbdBar(top->a0 & 0xFF);
        top->trigger = vbdFlag();

        if (!timing) {
            if(top->a0 == 0b11111111){
                timing = 1;
            }
        }
        if (top->a0 == 0 && timing){
            vbdInitWatch();
            while (timing){
                if (vbdFlag()){
                    time = intToBCD(vbdElapsed());
                    timing = 0;
                } 
            }
            vbdHex(4, (int(time)>>16) & 0xF);
            vbdHex(3, (int(time)>>8) & 0xF);
            vbdHex(2, (int(time)>>4) & 0xF);
            vbdHex(1, int(time) & 0xF);
        }
        // either simulation finished, or 'q' is pressed
        if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) 
            exit(0);
    }
}