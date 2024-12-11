#!/bin/bash

# Translate Verilog -> C++ including testbench
verilator   -Wall --trace \
            -cc ../../modules/CU.sv \
            --exe CU_tb.cpp \
            --prefix "Vdut" \
            -y ../../modules \
            -o Vdut \
            -LDFLAGS "-lgtest -lgtest_main -lpthread" \

# Build C++ project with automatically generated Makefile
make -j -C obj_dir/ -f Vdut.mk

# Run executable simulation file
./obj_dir/Vdut
    