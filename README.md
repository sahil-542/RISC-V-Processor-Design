# 32-bit RISC-V Processor Design

A Verilog/SystemVerilog-based implementation of a 32-bit RISC-V processor, progressing from a basic CPU datapath to a five-stage pipelined architecture. The project explores processor design, instruction execution, digital logic, pipeline control, and hardware verification.

## Project Overview

This project consists of two development stages:

- **Stage 1 – Basic RISC-V CPU:** Implementation of core processor components, including instruction fetching, instruction decoding, ALU operations, register file, memory interface, and branch handling. Also includes UART-based instruction reception.
- **Stage 5 – Five-Stage Pipelined CPU:** Implementation of a pipelined processor architecture consisting of Instruction Fetch, Instruction Decode, Execute, Memory Access, and Write Back stages, with hazard detection and forwarding logic.

## Architecture

### Stage 1 – Basic CPU

Core components:
- ALU for arithmetic and logical operations.
- Control Unit for instruction decoding and control signal generation.
- Register File for storing processor registers.
- Instruction Fetch and Program Counter modules.
- Branch Unit for branch handling.
- Sign Extension Unit for immediate generation.
- Data Memory and Write Back Multiplexer.
- UART Receiver for serial instruction reception.

### Stage 5 – Pipelined CPU

The processor is organized into five stages:

| Stage | Description |
|---|---|
| IF | Instruction Fetch |
| ID | Instruction Decode |
| EX | Execute / ALU Operations |
| MEM | Memory Access |
| WB | Write Back |

Additional components:
- Hazard Detection Unit
- Data Forwarding Logic
- Branch Comparator
- Pipeline Control Logic
- Register File and ALU

## Repository Structure

```text
RISC-V-Processor-Design/
│
├── riscvstage1/
│   ├── alu.v
│   ├── branch_unit.v
│   ├── controlunit.v
│   ├── cpu.v
│   ├── data_memory.v
│   ├── definitions.vh
│   ├── fetch.v
│   ├── imem.v
│   ├── pc.v
│   ├── prog2.mem
│   ├── register_file.v
│   ├── sign_ext.v
│   ├── tb_cpu.sv
│   ├── top_cpu_uart.v
│   ├── uart_rx.sv
│   └── wb_mux.v
│
└── stage5-riscv/
    ├── alu.v
    ├── branch_unit.v
    ├── comparator.v
    ├── control_unit.v
    ├── data_memory.v
    ├── decode.v
    ├── definitions.vh
    ├── execute_stage.v
    ├── fetch.v
    ├── hazard_unit.v
    ├── inst_mem.mem
    ├── mem_stage.v
    ├── register_file.v
    ├── sign_ext.v
    ├── top.v
    ├── wb_mux.v
    └── write_back.v
```

## Technologies Used

- Verilog
- SystemVerilog
- RISC-V Instruction Set Architecture (ISA)
- Digital Logic Design
- Computer Architecture
- RTL Design
- UART Communication
- Hardware Simulation and Verification

## Key Learning Outcomes

- Understanding processor datapath and control unit design.
- Implementing arithmetic and logical operations using Verilog.
- Understanding
