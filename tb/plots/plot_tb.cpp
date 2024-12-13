#include "../obj_dir/Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../../vbuddy.cpp"



int main(int argc, char **argv, char **env){
    int i;
    int clk;

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vtop* top = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;

    top->trace(tfp, 99);
    tfp->open ("signal.vcd");

    //init Vbuddy
    if (vbdOpen() != 1) return(-1);
    vbdHeader("PDF");
    vbdSetMode(1);

    top->clk = 1;
    top->rst = 0;
    int plot = 0;
    bool to_load = false; 
    int last_a0 = -1;
    //run simulation for many clock cycles
    for (i=0; i<1000000; i++){
        for (clk=0; clk<2; clk++){
            tfp->dump (2*i+clk);
            top->clk = !top->clk;   // unit is in ps!!!
            top->eval ();
        }
        if (plot == 0 && top->a0 == 205)
        {
            plot = 1;
        }
        if (plot > 256){
            break;
        }
        if (plot > 0){
            if (top->a0 == 205){
                to_load = true;
            }
            else if (top->a0 != 205 && to_load){
                to_load = false;
                plot++;
                vbdPlot(int(top->a0), 0, 255);

            }
        }
            // either simulation finished, or 'q' is pressed
        if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) 
            exit(0);                // ... exit if finish OR 'q' pressed
        if (Verilated::gotFinish()) exit(0);

    }
    tfp->close();
    exit(0);
}