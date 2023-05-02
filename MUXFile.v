`timescale 1ns / 1ps

/*
* Name: Silas Rodriguez
* R-Number: R-11679913
* Assignment: Project 6
*/

/**
* This module is responsible for taking the output of the ALU and passing it to the correct destination
* @param store - This is the store signal from the decoder
* @param branch - This is the branch signal from the decoder
* @param ALUBus - This is the output of the ALU
* @param GPR - This is the output of the ALU when the destination is a GPR
* @param RAM - This is the output of the ALU when the destination is RAM
* @param PC - This is the output of the ALU when the destination is PC
*/
module OutputMux(
    input store,    // store signal from decoder
    input branch,   // branch signal from decoder & alu
    input writeback,
    input [31:0] ALUBus,    // output of ALU
    output reg [31:0] GPR,  // destination of ALU bus to GPR
    output reg [31:0] RAM,  // destination of ALU bus to RAM
    output reg [31:0] PC,    // destination of ALU bus to Program Counter
    output wea,
    output rw
);    
    // This module is responsible for taking the output of the ALU and passing it to the correct destination
    always @(*) begin
        case ({store, branch, writeback})
            3'b001: begin
                RAM = 0;
                PC = 0;
                GPR = ALUBus;
                rw = 1;
                wea = 0;
            end
            3'b010: begin
                RAM = 0;
                PC = ALUBus;
                GPR = 0;
                wea = 0;
                rw = 0;
            end
            3'b100: begin 
                RAM = ALUBus;
                PC = 0;
                GPR = 0;
                wea = 1;
                rw = 0;
            end
        endcase
    end
endmodule

/**
* This module is responsible for taking the output of the Decoder and selecting the correct source for the B bus of the ALU (RAM, GPR, or litsrc) 
combinational logic is used to select the correct source

* @param mode - This is addressing mode from the decoder
* @param litsrc - This is the literal source from the decoder
* @param GPR - This is the output of the ALU when the source is a GPR
* @param RAM - This is the output of the ALU when the source is RAM
* @param litsrc - This is the output of the ALU when the source is a literal
*/
module BusMux(
    input [1:0] mode,   // addressing mode from decoder
    input [31:0] litsrc,    // literal source from decoder
    input [31:0] GPR,   // output to ALU when source is GPR
    input [31:0] Overwrite,   // output to ALU when hazard detected
    input [31:0] RAM,   // output to ALU when source is RAM
    output reg [31:0] B // output to ALU when source is literal
);

    always @(*) begin
        case (mode)
            // immediate addressing
            2'b00: begin
                B = litsrc;
            end
            // direct addressing
            2'b01: begin
                B = RAM;
            end
            // Overwrite addressing (for data hazards)
            2'b11: begin
                B = Overwrite;
            end
            // register addressing
            default: begin
                B = GPR;
            end
        endcase
    end

endmodule

/**
    * This module is responsible for monitoring the datapath and detecting hazards and correcting them while minimizing impact on performance
    * @param srcexe - This is the source register from the execute stage
    * @param dstwb - This is the destination register from the writeback stage
    * @param modein - This is the addressing mode from the decoder at execute stage
    * @param modeout - This is the mux select output to the execute stage
    * @param ALUoutput - This is the output of the ALU
    * @param Forward - This is the output of the forward bus
    * @param RAMaddr0 - This is the RAM address to be accessed
    * @param RAMaddr1 - This is the RAM address to be written to
    * @param store - This is the store signal from the decoder
    * @param stall - This is the stall signal
    * @param RAMout - This is the RAM output to be written to
    * @param branch - This is the branch signal from the decoder
    * @param flush - This is the flush signal
*/
module HazardDetector (
    input [4:0] srcexe,        //source register
    input [4:0] dstwb,        //destination register

    input [1:0] modein,     //Mux select input
    output reg [1:0] modeout,   //mux select overwrite
    
    input [31:0] ALUoutput, //ALU output
    output reg [31:0] Forward,        // forward the ALU output to the execute stage
    
    input [31:0] RAMaddr0,   //RAM address to be accessed to
    input [31:0] RAMaddr1,   //RAM address to be written to
    input store,            //store signal
    output reg stall,       //stall signal
    output reg [31:0] RAMout,   //RAM output to be written to

    input branch,     //branch enable signal
    output flush            //flush signal
);
    
    always @(*) begin
        // data dependency hazard detection -> forward ALU output before writeback failure
        if (srcexe == dstwb) begin
            modeout = 2'b11;     //mode override for B mux
            Forward = ALUoutput; //update the forward bus
        end 
        else begin
            modeout = modein;   //normal operation
        end

        // RAM writeback hazard detection -> forward RAM output before writeback failure
        if (store) begin
            stall = 1'b1;       //stall the pipeline from advancing
            RAMout = RAMaddr1;  //forward the RAM address to be written to
        end
        else begin
            stall = 1'b0;       //normal operation
            RAMout = RAMaddr0;  //forward the RAM address to be read from
        end

        // branch hazard detection -> flush the pipeline
        if (branch) begin
            flush = 1'b1;       //flush the pipeline
        end
        else begin
            flush = 1'b0;       //normal operation
        end
    end

endmodule

module Amux(
    input [31:0] Agpr,
    input [31:0] ALU,
    input mode,
    output [31:0] A
);

    always @(*) begin
        case (mode)
            1'b1: begin
                A = ALU;   // hazard detected, forward ALU
            end
            default: begin
                A = Agpr;
            end
        endcase
    end

endmodule