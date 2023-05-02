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
    input branch,   // branch signal from decoder
    input [31:0] ALUBus,    // output of ALU
    output reg [31:0] GPR,  // destination of ALU bus to GPR
    output reg [31:0] RAM,  // destination of ALU bus to RAM
    output reg [31:0] PC    // destination of ALU bus to Program Counter
);
    // This module is responsible for taking the output of the ALU and passing it to the correct destination
    always @(*) begin
        case ({store, branch})
            2'b01: begin
                GPR = 0;
                RAM = 0;
                PC = ALUBus;
            end
            2'b10: begin
                GPR = 0;
                RAM = ALUBus;
                PC = 0;
            end
            default: begin
                GPR = ALUBus;
                RAM = 0;
                PC = 0;
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
    input [31:0] GPR,   // output of ALU when source is GPR
    input [31:0] RAM,   // output of ALU when source is RAM
    output reg [31:0] B // output of ALU when source is literal
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
            // register addressing
            default: begin
                B = GPR;
            end
        endcase
    end

endmodule