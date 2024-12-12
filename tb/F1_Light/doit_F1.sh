#!/bin/bash

# This script display the pdf build from different signals
# Usage: ./doit.sh signal_name
SCRIPT_DIR=$(dirname "$(realpath "$0")")
RTL_FOLDER="$SCRIPT_DIR/../../modules"
chmod +w "$SCRIPT_DIR"

rm -rf obj_dir
rm -f top.vcd

cd $SCRIPT_DIR

name="top"

verilator   -Wall --trace \
            -cc ${RTL_FOLDER}/top.sv \
            --exe F1_tb.cpp \
            -y ${RTL_FOLDER}

# Create default empty file for data memory
touch data.hex

touch program.hex

cp "$SCRIPT_DIR/F1_Light.hex" "$SCRIPT_DIR/program.hex"

#build C++ project via make automatically generated by Verilator
make -j -C obj_dir/ -f Vtop.mk Vtop

#run executable simulation file
obj_dir/Vtop