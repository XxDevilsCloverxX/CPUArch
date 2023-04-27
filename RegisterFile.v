`timescale 1ns / 1ps

/*
Name: Silas Rodriguez
R#: R-11679913
Assignment: Project 6
*/

/**  
    * RegisterFile.v
    * 
    * This module is responsible for keeping track of the registers and updating them
    * as well as reading from them.
    * 
    * Inputs:
    *  clk - Clock signal
    *  rw - Write enable signal
    *  d_addr - Destination address
    *  a_addr - Register A address
    *  b_addr - Register B address
    *  data - Data to be written to register
    * 
    * Outputs:
    *  a_data - Data from register A
    *  b_data - Data from register B
    *
*/
module RegisterFile(
    input clk,  //clock
    input reset,  //reset
    input rw,   //write enable
    input [4:0] d_addr,    //destination address
    input [4:0] a_addr,   //address of register A
    input [4:0] b_addr,  //address of register B
    input [31:0] data,  //data to be written to register
    output [31:0] a_data,   //data from register A
    output [31:0] b_data    //data from register B
);
    //create an array of 32 bit registers size 32
    reg [31:0] registers [31:0];

    //update the outputs to match the registers selected by A & B data
    assign a_data = registers[a_addr];
    assign b_data = registers[b_addr];

    //update every clk cycle
    always @(posedge clk) begin
        //reset the registers if reset is high
        if (reset) begin
            registers[0] <= 32'h00000000;
            registers[1] <= 32'h00000000;
            registers[2] <= 32'h00000000;
            registers[3] <= 32'h00000000;
            registers[4] <= 32'h00000000;
            registers[5] <= 32'h00000000;
            registers[6] <= 32'h00000000;
            registers[7] <= 32'h00000000;
            registers[8] <= 32'h00000000;
            registers[9] <= 32'h00000000;
            registers[10] <= 32'h00000000;
            registers[11] <= 32'h00000000;
            registers[12] <= 32'h00000000;
            registers[13] <= 32'h00000000;
            registers[14] <= 32'h00000000;
            registers[15] <= 32'h00000000;
            registers[16] <= 32'h00000000;
            registers[17] <= 32'h00000000;
            registers[18] <= 32'h00000000;
            registers[19] <= 32'h00000000;
            registers[20] <= 32'h00000000;
            registers[21] <= 32'h00000000;
            registers[22] <= 32'h00000000;
            registers[23] <= 32'h00000000;
            registers[24] <= 32'h00000000;
            registers[25] <= 32'h00000000;
            registers[26] <= 32'h00000000;
            registers[27] <= 32'h00000000;
            registers[28] <= 32'h00000000;
            registers[29] <= 32'h00000000;
            registers[30] <= 32'h00000000;
            registers[31] <= 32'h00000000;
        end

        //only allow register writes on write en
        if (rw)
            //access the specific register specified by d and write to it
            registers[d_addr] <= data;
    end

endmodule