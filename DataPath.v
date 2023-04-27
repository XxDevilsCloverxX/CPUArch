`timescale 1ns / 1ps

/*
Name: Silas Rodriguez
R-Number: R-11679913
Assignment: Project 6
*/

/**

    * DataPath.v
    * This module is responsible for organizing the CPU architecthure and connecting all the modules together.
    
    * Inputs:
    *  clk - External Clock signal
    *  reset - External Reset signal
    
    * Outputs:
    *  None
*/
module CPU(
    input clk,      //clock
    input reset,    //reset
);

    // define wires to connect modules
    wire [48:0] instruction;    //instruction from memory
    wire [31:0] litsrc;         //literal source
    wire [4:0] dst;             //destination
    wire [4:0] src;             //source
    wire [1:0] mode;            //mode
    wire [4:0] op;              //operation
    wire [31:0] a_data;         //data from register A
    wire [31:0] b_data;         //data from register B
    wire [31:0] a;              //ALU input A
    wire [31:0] b;              //ALU input B
    wire [31:0] result;         //ALU result
    wire zero;                  //ALU zero flag
    wire [31:0] data;           //data to be written to register
    wire rw;                    //write enable
    wire [4:0] d_addr;          //destination address
    wire [4:0] a_addr;          //address of register A
    wire [4:0] b_addr;          //address of register B
    wire [31:0] pc_in;          //program counter input
    wire [31:0] pc_out;         //program counter output
    wire branch;                //branch signal

    //create an instruction memory

    //create a program counter
    ProgramCounter counter(.clk(clk), .rst(reset), .branch(branch), .pc_in(pc_in), .pc_out(pc_out));

    //create a register file
    RegisterFile regfile(.clk(clk), .reset(reset), .rw(rw), .d_addr(d_addr), .a_addr(a_addr), .b_addr(b_addr), .data(data), .a_data(a_data), .b_data(b_data));

    //create an ALU
    ALU alu(.clk(clk), .reset(reset), .a(a), .b(b), .op(op), .result(result), .zero(zero));

    //create a decoder
    Decoder decoder(.clk(clk), .reset(reset), .instruction(instruction), .litsrc(litsrc), .dst(dst), .src(src), .mode(mode), .op(op));

endmodule