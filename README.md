# Pipelined with L1 L2 Cache implementation 

## Introduction
This Repo contains our Pipelined RISC-V Processor with and L1 L2 implementation of cache instead of the set-associative cache.

### This was mainly implemented by Charlotte with debugging by Abraham 

This was mainly implemented by Charlotte with debugging by Abraham 

## Introduction

Building up on lab 4, we implemented the single cycle version. The main challenge was implementing all the instructions.

## Design Specification

Using Hierarchical Design principals we de

 ### Data Memory
 
There were little changes to the data memory module as the writeback principal that we opted for meant that it functiojned the same as in the regular cache however the writeback signals were replaced by writeback signals from L2.

 ### Simulation and Testing

 We did not have the time to fully test and implement this design so in terms of improvement this would definitely be the next step in improving our processor. 
