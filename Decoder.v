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
    
    /*
        Immediately, all instructions are going to pipeline registers to be executed properly
        op -> Eventually ALU so that the ALU executes the operation
        mode -> MUX right before ALU and after in order to pass allow the correct data into the ALU on A and B bus
                and store to the correct address
        src -> register file to get the select register
        dst -> register file / POST ALU mux to store outputs to right location
        litsrc ->  generate this number in Hex, and register file, a mux will select which to use.
    */
endmodule
