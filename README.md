

# Single Cycle Version

## Introduction

Building up on lab 4, we implemented the single cycle version. The main challenge was implementing all the instructions.

## Design Specification

The textbook and lecture slides recommended to use the following diagram: 

![alt text](image.png)

We adapted this to the following diagram. The main changes made was the addition of a comparator, and the inputs to the following modules (insert) to implement (insert the following changes)

![alt text](images/<WhatsApp Image 2024-12-04 at 17.27.29_6be3d6e2.jpg>)

Following the project brief after lab 4, the main requirements we had were:

 - Changes in the control unit to implement all the instructions
 - coming up with the machine code to implement the F1 light cycle

 (add in any other relevant changes and sections on datamem/cu)

 ### Data Memory

 ![alt text](images/image-1.png)
 The memory map shows that the data memory goes from 0x01000 to 0x1FFFF, so we needed 17 addresses leading to the initialisation of our data memory.

 ### Control Unit

 Control unit:
 ![alt text](images/image-2.png)

Instruction list implemented:
 ![alt text](images/image-3.png)

 ### Simulation and Testing

 For our single cycle, we wrote unit testbenches (link) to ensure all the modules were working accurately.

 (did we also use industry standard GTest?)

 This allowed us to check the expected behaviour of each control/data path signal in a module. (insert picture of it passing)

 This was all ran through a doit.sh file.
