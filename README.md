# SuperScalar Model

## Overview

This repo contains our design for a superscaled version of the single cycle RISC-V processor. This mainly involved doubling up the number of read and write ports, as well as an out of order processor. This replicated a modern CPU much more accurately.

**Authors**
Shreeya Agarwal

## Introduction
To make our CPU even faster, we implemented a superscaled model which carries out 2 instructions at a time. This takes all the same modules as before, with double the read and write ports, 2 ALUs, and an out of order processor. 

## Design Specifications
![alt text](image.png)

This image outlines the followin acrhitecture. 

This could mainly follow our single cycle CPU design with additional modifications, as outlined in Shreeya's personal statement.

## Simulatoin and Testing

Due to time constraints, we weren't able to fully implement and test this model. Furture work will ensure on rigorous simulation and testing to see if we achieved our desired perfromance and improvements.

## Potential Improvements

1) Thorough testing
2) Cleaner Implementation
3) Optimsation once this all occured.
