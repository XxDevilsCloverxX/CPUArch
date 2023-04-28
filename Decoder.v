`timescale 1ns / 1ps

/*
Name: Silas Rodriguez
R-Number: R-11679913
Assignment: Project 6
*/

module decoder(
    input [48:0] instruction,
    output wire [31:0] litsrc,
    output wire [4:0] dst,
    output wire [4:0] src,
    output wire [1:0] mode,
    output wire [4:0] op
    output wire branch,
    output wire store
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
    
    assign branch = ((instruction[48:44] == 5'h10)||(instruction[48:44] == 5'h11)||(instruction[48:44] == 5'h12));  // Branch is determined by the op code
    assign store = (instruction[48:44] == 5'h02);   // Store is determined by the op code
endmodule
