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
    input memen,    //memory enable signal -> half speed of clk
    input reset,    //reset
    output [5:0] counter //counter for debugging
);

    assign counter = pcout; //counter for debugging what ROM address is being accessed

    // Wires - outputs from the modules
    wire [48:0] instruction; //instruction from ROM
    wire [31:0] litsrc; //literal or source from instruction
    wire [31:0] RAMout; //data from RAM
    wire [31:0] RAMaddr;
    wire [31:0] agpr, bgpr, A, B; //data from registers
    wire [31:0] ALUoutput; //ALU output
    wire [31:0] PortForward; //forwarded data from hazard detection unit
    wire [31:0] GPRwriteback, RAMwriteback, PCwriteback; //writeback data
    wire [5:0] pcout; //program counter output
    wire [4:0] src; //source register
    wire [4:0] dst; //destination register
    wire [4:0] op;  //operation
    wire [1:0] mode, modeout;    //modes
    wire branch, store, writeback; //control signals
    wire zflag, nflag, sflag, cflag, hflag, vflag; //flags
    wire wea, stall, flush, rw, modeA;
    
    // Pipeline registers - inputs to the modules
    reg [48:0] decode; //instruction from ROM -
    reg [31:0] litsrc2, litsrc3; //literal or source from instruction -
    reg [31:0] Adata3, Bdata3; //data from registers -
    reg [31:0] ALUoutput4; //ALU output -
    reg [4:0] src2; //source register -
    reg [4:0] dst2, dst3,dst4; //destination register- 
    reg [4:0] op2, op3;  //operation-
    reg [1:0] mode2;    //modes-
    reg store2, writeback2, store3, writeback3, branch4, store4, writeback4; //control signals
    reg zin4, nin4, sin4, cin4, hin4, vin4; //flags
    reg wave, stall4, flush4; //control signals    
    
    //update the Pipeline on every clock cycle
    always @(negedge clk) begin
        wave = ~wave;   //this times the instructions coming from ROM with pipeline
        
        //Pipeline registers - cleared on resets or flushes
        if (reset | flush4) begin
            //control signals
            wave <= 0;
            flush4 <=0;
            stall4 <=0;
            //stage 1 pipeline
            decode <= 0;
            //stage 2 pipeline
            litsrc2 <= 0;
            src2 <= 0;
            dst2 <= 0;
            op2 <= 0;
            store2 <= 0;
            writeback2 <= 0;
            mode2 <= 0;
            //stage 3 pipeline
            litsrc3 <= 0;
            Adata3 <= 0;
            Bdata3 <= 0;
            dst3 <= 0;
            op3 <= 0;
            store3 <= 0;
            writeback3 <= 0;
            //stage 4 pipeline            
            ALUoutput4 <= 0;
            branch4 <= 0;
            store4 <= 0;
            writeback4 <= 0;
            zin4 <= 0;
            nin4 <= 0;
            sin4 <= 0;
            cin4 <= 0;
            hin4 <= 0;
            vin4 <= 0;
            dst4 <= 0;
            end

        // Stage 1-4 only completes if not stalled by hazard detection unit "Stage Changes"
        else if (wave) begin
            
            if(~stall4) begin
                // Stage 1 - Fetch
                decode <= instruction;
    
                // Stage 2 - Decode
                litsrc2 <= litsrc;
                src2 <= src;
                dst2 <= dst;
                op2 <= op;
                mode2 <= mode;
                store2 <= store;
                writeback2 <= writeback;
                
                // Stage 3 - Register Fetch
                Adata3 <= A;
                Bdata3 <= B;
                litsrc3 <= litsrc2; //forwarding for hazard detector
                dst3 <= dst2;
                op3 <= op2;
                store3 <= store2;
                writeback3 <= writeback2;
            end
        // Stage 4 - Execute & Hazard Detection
            dst4 <= dst3;
            branch4 <= branchflag; //ALU output for if a branch instruction was taken
            store4 <= store3;
            writeback4 <= writeback3;
            zin4 <= zflag;
            nin4 <= nflag;
            sin4 <= sflag;
            cin4 <= cflag;
            hin4 <= hflag;
            vin4 <= vflag;
            ALUoutput4 <= ALUoutput;
            stall4 <= stall; // this is used to stall the pipeline, but also to unstall it
            flush4 <= flush;
        // Stage 5 - Writeback - "Commit changes"
        /*
            This section does not need to be timed with the pipeline, as it is not dependent on the previous stages.
            It is only dependent on the control signals from the previous stages.
            This section is executed every clock cycle via the register file, Program counter, RAM and output mux modules.
        */
    end
end
    //create a program counter sequential logic
    ProgramCounter Pcounter (.clk(memen), .rst(reset), .pcin(PCwriteback), .branch(branch4), .en(~stall4),
    .pcout(pcout)
    );

    //create an instruction memory
    blk_mem_gen_ROM ROM(
    .clka(clk),     // input wire clka
    .ena(memen),         // input wire ena
    .addra(pcout),  // input wire [5 : 0] addra
    .douta(instruction)  // output wire [48 : 0] douta
    );

    //create a data memory
    blk_mem_gen_RAM RAM(
    .clka(clk),     // input wire clka
    .ena(memen),       // input wire ena
    .wea(wea),       // input wire [0 : 0] wea
    .addra(RAMaddr),       // input wire [7 : 0] addra
    .dina(RAMwriteback),        // input wire [31 : 0] dina
    .douta(RAMout)    // output wire [31 : 0] douta
    );
    
    //create a decoder combinational logic
    Decoder decoder(.instruction(decode),
    .litsrc(litsrc),.src(src), .dst(dst), .mode(mode), .op(op), .branch(branch), .store(store), .writeback(writeback)
    );

    //create a register file sequential & combinational logic
    RegisterFile regfile(.clk(clk), .rst(reset), .rw(rw), .d_addr(dst4), .a_addr(src2), .b_addr(litsrc2[4:0]), .data(GPRwriteback),
    .a_data(agpr), .b_data(bgpr));

    //create a mux for A bus
    Amux abusmux(.mode(modeA), .Agpr(agpr),.ALU(PortForward),
    .A(A));

    //create a bus mux combinational logic
    BusMux busmux(.mode(modeout), .litsrc(litsrc2), .GPR(bgpr), .RAM(RAMout), .Overwrite(PortForward),
    .B(B)
    );

    //create an ALU combinational logic
    ALU alu(.a(Adata3), .b(Bdata3), .op(op3), .zin(zin4), .cin(cin4), .vin(vin4), .hin(hin4), .sin(sin4), .nin(nin4),
    .out(ALUoutput), .zflag(zflag), .nflag(nflag), .sflag(sflag), .cflag(cflag), .hflag(hflag), .branch(branchflag), .vflag(vflag));
    
    //create an output mux combinational logic
    OutputMux outmux(.store(store4), .branch(branch4), .writeback(writeback4), .ALUBus(ALUoutput4),
    .GPR(GPRwriteback), .RAM(RAMwriteback), .PC(PCwriteback), .wea(wea), .rw(rw));

    // create a hazard detection unit
    HazardDetector hazard(.srcRegA(src2), .srcRegB(litsrc2[4:0]), .dstwb(dst3), .modein(mode2), .ALUoutput(ALUoutput),.branch(branchflag), .store(store3), .RAMaddr0(litsrc2), .RAMaddr1(litsrc3),
    .modeB(modeout), .Forward(PortForward), .stalled(stall4), .stall(stall), .RAMout(RAMaddr), .flush(flush), .modeA(modeA));

endmodule

/**
    A note about this module:
    This module is responsible for organizing the CPU architecthure and connecting all the modules together.
    The CPU module is the top level module that connects all the other modules together. It is responsible for
    creating the pipeline registers and connecting the modules together. Pipeline registers are used to store
    the outputs of the modules and are updated on every clock cycle. The CPU writeback occurs every clock cycle
    regardless of whether the pipeline is stalled or not. This is because the writeback is done in the output mux,
    which is a combinational logic. The register updated as a result of the writeback is determined by the register file,
    which is a sequential logic. The register file is updated on every clock cycle, but the register file only updates
    the register if the rw signal is set. The rw signal is set by the output mux, which is a combinational logic.
*/ 