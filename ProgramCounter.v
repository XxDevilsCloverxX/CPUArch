`timescale 1ns / 1ps
/*
    Name: Silas Rodriguez
    R-Number: R-11679913
    Assignment: Project 6
*/

/**
    * ProgramCounter.v
    * 
    * This module is responsible for keeping track of the program counter and incrementing it
    * as well as branching to a new address if the branch signal is asserted.
    * 
    * Inputs:
    *  clk - Clock signal
    *  rst - Reset signal
    *  branch - Branch signal
    *  pc_in - Program counter input
    * 
    * Outputs:
    *  pc_out - Program counter output
    *
*/
module ProgramCounter (
    input clk,                  // Clock signal
    input rst,                  // Reset signal
    input branch,               // Branch signal
    input [5:0] pcin,         // Program counter input
    output reg [5:0] pcout    // Program counter output
);
    
    reg [5:0] addr;            // Address register can address 64 locations of ROM

    always @(negedge clk) begin
        if (rst) begin
            pcout <= 0;      // Reset for the program counter
            addr <= 0;        // Reset for the address register
        end 
        else if (branch) begin
            pcout <= pcin;   // Branch to the address being passed in
            addr <= pcin;     // Set the address register to the address being passed in
        end
        else begin
            pcout <= addr;    // Increment the program counter
            addr <= addr + 1;  // Increment the address register
        end
    end
endmodule

/**
Footnote:
    This module can be used for ROMs up to 64 locations. If more locations are needed, the address register and ports
    will need to be expanded to address more locations. However, this is not needed for this implementation. 
*/