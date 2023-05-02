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
    input reset    //reset
    //output wire [31:0] GPR0 //General Purpose Register 0
);

    //Pipeline Registers
    reg [48:0] fetch;
    reg [31:0] Baddr;
    reg [4:0] op, Aaddr, Daddr;
    reg [1:0] mode0;
    reg writeback, st, bra;
    
    //Wire connections
    wire [48:0] instruction;
    wire [31:0] litsrc;
    wire [4:0] opcode, dst, src;
    wire [1:0] mode;
    wire wb, branch, store;
    //create an instruction memory
    blk_mem_gen_ROM ROM(
    .clka(clk),    // input wire clka
    .ena(),      // input wire ena
    .addra(),  // input wire [5 : 0] addra
    .douta(instruction)  // output wire [48 : 0] douta
    );
    //create a data memory
    blk_mem_gen_RAM RAM(
    .clka(clk),    // input wire clka
    .ena(),      // input wire ena
    .wea(),      // input wire [0 : 0] wea
    .addra(),  // input wire [7 : 0] addra
    .dina(),    // input wire [31 : 0] dina
    .douta()  // output wire [31 : 0] douta
    );
    //create a program counter
    ProgramCounter counter (.clk(clk), .rst(reset), .branch(), .pcin(), .pcout());
    //create a decoder
    Decoder decoder(.instruction(fetch), .litsrc(litsrc),.src(src), .dst(dst), .mode(mode), .branch(branch), .op(opcode), .store(store), .writeback(wb));
    //create a register file
    RegisterFile regfile(.clk(clk), .rst(reset), .rw(), .d_addr(), .a_addr(Aaddr), .b_addr(litsrc[4:0]), .data(), .a_data(), .b_data());
    //create an ALU
    ALU alu(.a(), .b(), .op(), .out(), .zflag(), .nflag(), .sflag(), .cflag(), .hflag(), .branch(), .vflag());
    //create a bus mux
    BusMux busmux(.mode(), .litsrc(), .GPR(), .B(), .RAM());
    //create an output mux
    OutputMux outmux(.store(), .branch(), .writeback(), .ALUBus(), .GPR(), .RAM(), .PC());

    //update the Pipeline on every clock cycle
    always @(negedge clk) begin
        //flush the pipeline
        if (reset) begin
            fetch <= 0;
            op<=0;
            Aaddr<=0;
            Baddr<=0;
            Daddr<=0;
            writeback<=0;
            st <= 0;
            bra <=0;
        end
        
        //STAGE 1 - Instruction Fetch
        fetch <= instruction;
        
        //STAGE 2 - Instruction Decode & 
        bra<=branch;
        st<=store;
        mode0<=mode;
        Aaddr<=src;
        Baddr<=litsrc;  //5 LSB to reg file B
        Daddr<=dst;
        
        //STAGE 3 - Execute
        
        //STAGE 4 - Memory
        
        //STAGE 5 - Writeback
    end
endmodule