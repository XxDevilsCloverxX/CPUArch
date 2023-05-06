`timescale 1ns / 1ps

/*
Name: Silas Rodriguez
R-Number: R-11679913
Assignment: Project 6
*/

/**
* This module is responsible for decoding the instructions and passing them to the data path.
* The decoder takes in the instruction and passes it to the data path on seperate busses.
* The decoder also determines if the instruction is a branch or store instruction.
* The decoder is a combinational circuit.
* @param instruction is the instruction to be decoded.
* @param litsrc is the literal or source of the instruction.
* @param dst is the destination register of the instruction.
* @param src is the source register of the instruction.
* @param mode is the addressing mode of the instruction.
* @param op is the operation of the instruction for the ALU.
* @param branch is the branch signal.
* @param store is the store signal.
*/
module Decoder(
    input [48:0] instruction,
    output wire [31:0] litsrc,
    output wire [4:0] dst,
    output wire [4:0] src,
    output wire [1:0] mode,
    output wire [4:0] op,
    output wire branch,
    output wire store,
    output wire writeback
);

    /*
    All the instruction decoder needs to do is take incoming instructions 
    and pass them to the data path on seperate busses to be handled.
    */
    assign op = instruction[48:44];
    assign mode = instruction[43:42];
    assign src = instruction[41:37];
    assign dst = instruction[36:32];
    assign litsrc = instruction[31:0];
    
    assign branch = (instruction[48:44]== 5'h10 ||instruction[48:44]== 5'h11||instruction[48:44]== 5'h12);
    assign store = (instruction[48:44] == 5'h02);   // Store is determined by the op code
    assign writeback = ~branch & ~store;            // This allows the GPR writeback
endmodule
