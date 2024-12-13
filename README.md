# Pipelined Processor with L1 and L2 Cache Implementation

## Overview
This repository contains a pipelined RISC-V processor featuring an implementation of hierarchical L1 and L2 caches. The L1 and L2 caches are designed to improve hit rates by leveraging their respective capacities and spatial localities. Unlike a traditional set-associative cache, this implementation adopts a write-back strategy with specific eviction policies.

### Authors
- **Primary Implementation:** Charlotte
- **Debugging and Support:** Abraham

## Introduction
To enhance the efficiency and hit rate of the cache, we implemented a hierarchical L1-L2 cache structure. Both caches are set-associative, with the L2 cache offering greater capacity and improved spatial locality. This hierarchical approach aims to reduce memory latency and improve overall processor performance.

## Design Specifications
### High-Level Design
The processor and cache design follow hierarchical design principles. The diagram below outlines the system's architecture:

![WhatsApp Image 2024-12-11 at 01 50 46_290c75ea](https://github.com/user-attachments/assets/9c0aeaf6-5a59-4e00-bb27-3db7623e392c)

### Cache Policies
- **Write-Back Policy:**
  - When a block is evicted from L1, it is written to L2 instead of directly to the data memory.
  - Data is written back to main memory only when a block is evicted from L2.
- **Direct Data Memory Access:**
  - While the initial design aimed for strict communication between adjacent cache levels, L1 also has direct access to the data memory for simplicity and efficiency.

### Data Memory Module
The data memory module required minimal modifications:
- The write-back signals are sourced from L2 instead of L1.
- Other functionalities remain consistent with standard cache implementations.

## Simulation and Testing
Due to time constraints, the design has not been fully tested and validated. Future work will focus on rigorous simulation and testing to ensure the implementation functions as intended and achieves the desired performance improvements.

## Potential Improvements
1. **Thorough Testing:**
   - Conduct comprehensive testing to verify the functionality of the hierarchical cache.
   - Evaluate performance metrics, including hit rates, latency, and energy consumption.
2. **Optimization:**
   - Explore alternative policies for eviction and write-back to further enhance performance.
   - Implement advanced features like prefetching or adaptive cache sizing.
---

We hope this implementation serves as a strong foundation for future enhancements and experimentation with cache architectures.


