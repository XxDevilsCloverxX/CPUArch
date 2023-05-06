`timescale 1ns/1ps

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
    input en,                   // Enable signal - enables the program counter to increment
    input branch,               // Branch signal
    input [5:0] pcin,         // Program counter input
    output [5:0] pcout    // Program counter output
);
    
    assign pcout = addr;        // Assign the output to the address register
    reg [5:0] addr;            // Address register can address 64 locations of ROM

    always @(negedge clk) begin
        if (rst) begin
            addr <= 0;        // Reset for the address register
        end 
        if (en) begin
            if (branch) begin
                addr <= pcin; // Branch to new address
            end 
            else begin
                addr <= addr + 1; // Increment the address
            end
        end
    end
endmodule

/**
Footnote:
    This module can be used for ROMs up to 64 locations. If more locations are needed, the address register and ports
    will need to be expanded to address more locations. However, this is not needed for this implementation. 
*/