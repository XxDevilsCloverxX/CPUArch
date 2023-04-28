# CPUArch - CPU Architecture ECE 4375 TTU

## CPU Architecture Implementation | Verilog Layout

### Introduction

This is a CPU architecture implementation for the ECE 4375 course at Texas Tech University. The CPU is a 32-bit architecture with 49-bit instructions. The CPU is a 5-stage pipeline with a 49-bit instruction fetch, 49-bit instruction decoder, and a 49x64 bit ROM memory access with a 1KB RAM. The CPU has 32 32-bit general purpose registers (GPRs), 6-bit program counter, ALU. The CPU has 14 instructions in the instruction set.

### Register File

This module provides access to read and write from and to the General Purpose Registers. The register file is 32 32-bit registers. The registers are written to by setting the write enable signal and the passing a register address to the destination bus. The register file is read from by sending a 5 bit code to the multiplexers attached to the address lines of A and B. The register file is implemented as a 32x32 bit register array.

### ALU

This module defines the ALU for the CPU. The ALU is a 32-bit ALU with 14 instructions. The ALU is implemented as a case statement with the 14 instructions. The ALU has a 32-bit input and a 32-bit output. The ALU has a 5-bit control signal that is used to select the operation to be performed. The ALU has a status register that is set after every instruction with the following flags:

- Zero Flag, Z

- Negative Flag, N

- Overflow Flag, V

- Carry Flag, C

- Sign Flag, S

- Half Carry Flag, H

### ROM & RAM

These modules define the ROM and RAM for the CPU. The ROM is a 64x49 bit ROM that is used to store the instructions for the CPU. The RAM is a 1KB RAM that is used to store data for the CPU. The RAM is implemented as a 1024x32 bit RAM. The ROM is implemented as a 64x49 bit ROM. These modules are created using Vivado IP core generator and wizard.

### Program Counter

This module acts as the instruction fetch for the CPU. It contains an `address` register that is the width needed to index each of the 64 ROM locations. The `address` register is incremented by 1 after each instruction fetch. The `address` register is set to 0 after a reset or overflow. If a `branch` flag is passed, the address bus is passed to the output instead of the `address` register. Then the `address` register is also updated to this value.

### Instruction Decoder

This module decodes the instruction from the instruction fetch. The instruction decoder takes the 49-bit instruction and decodes it into seperate busses and flags that are used to control the CPU. The instruction decoder has the following outputs:

- Opcode

> The opcode is the 5-bit instruction code that is used to select the operation to be performed by the ALU.

- Addressing Mode

> The addressing mode is the 2-bit addressing mode that is used to select the addressing mode for the instruction.

- Source Address

> The source address is the 5-bit address of the source register.

- Destination Address

> The destination address is the 5-bit address of the destination register.

- Literal / Source

> The literal / source is the 32-bit literal or source register value.

- Branch Flag

> The branch flag is a 1-bit flag that is set if the instruction is a branch instruction.

- Store Flag

> The store flag is a 1-bit flag that is set if the instruction is a store instruction.

- Writeback Flag

> The writeback flag is a 1-bit flag that is set if the instruction is a arithmetic operation or load instruction.

These outputs are used to control the flow of data in the CPU. Instructions are decoded by the instruction decoder and then passed to the ALU, register file, and program counter through pipeline registers and multiplexers.

### Instruction Set Architecture

The CPU has a 49-bit instruction set. The instruction set is broken up into 5-bit opcodes 2-bit modes, 32-bit literal/src, 5-bit source, and 5-bit destination blocks. The instruction organization is defined as follows:

- op-code             = instruction[48:44];

- Addressing mode     = instruction[43:42];

- Source Address      = instruction[41:37];

- Destination Address = instruction[36:32];

- Literal / Source    = instruction[31:0];

### Instruction Set

0x00: `NOP` - No Operation

0x01: `LD` - Load

0x02: `ST` - Store

0x03: `ADD` - Add

0x04: `SUB` - Subtract

0x05: `AND` - Bitwise AND

0x06: `OR` - Bitwise OR

0x07: `XOR` - Bitwise XOR

0x08: `NOT` - Bitwise NOT

0x09: `SL` - Shift Left

0x0A: `SR` - Shift Right

0x10: `BZ` - Branch if Zero

0x11: `BNZ` - Branch if Not Zero

0x12: `BRA` - Branch

### MUXFile

This module defines the multiplexers used in the CPU. The multiplexers are used destination from the ALU and the input for bus B of the ALU. The multiplexers are implemented as a case statement that updates the output busses based on the control signal.

> For the input multiplexer, the control signal is the 2-bit addressing mode.

> For the output multiplexer, the control signal is the 2-bits of branch flag and store flag. If neither is set, the default is to writeback to GPR.