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
    input pcclk,    //program counter clock 2x faster than clk (for ROM)
    input memclk,   //memory clock 1/2 speed than clk (for RAM)
    input reset    //reset
);

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
    wire zflag, nflag, sflag, cflag, hflag, vflag, branchflag; //flags
    wire wea, stall, flush, rw, modeA;
    
    // Pipeline registers - inputs to the modules
    reg [48:0] decode; //instruction from ROM
    reg [31:0] litsrc2, litsrc3, litsrc4; //literal or source from instruction
    reg [31:0] Adata2, Bdata2, Adata3, Bdata3; //data from registers
    reg [31:0] ALUoutput3, ALUoutput4, ALUoutput5; //ALU output
    reg [4:0] src2; //source register
    reg [4:0] dst2, dst3,dst4, dst5; //destination register
    reg [4:0] op2, op3;  //operation
    reg [1:0] mode2;    //modes
    reg branch2, store2, writeback2, branch3, store3, writeback3, branch4, store4, writeback4, branch5, store5, writeback5; //control signals
    reg zin3, nin3, sin3, cin3, hin3, vin3, bflag3; //flags
    reg wea5, stall4, flush4; //control signals    

    //update the Pipeline on every clock cycle
    always @(negedge clk) begin

        //Pipeline registers - cleared on resets or flushes
        if (reset | flush4) begin
            decode <= 0;
            litsrc2 <= 0;
            litsrc3 <= 0;
            litsrc4 <= 0;
            Adata2 <= 0;
            Bdata2 <= 0;
            Adata3 <= 0;
            Bdata3 <= 0;
            ALUoutput3 <= 0;
            ALUoutput4 <= 0;
            ALUoutput5 <= 0;
            src2 <= 0;
            dst2 <= 0;
            dst3 <= 0;
            dst4 <= 0;
            dst5 <= 0;
            op2 <= 0;
            op3 <= 0;
            mode2 <= 0;
            branch2 <= 0;
            store2 <= 0;
            writeback2 <= 0;
            branch3 <= 0;
            store3 <= 0;
            writeback3 <= 0;
            branch4 <= 0;
            store4 <= 0;
            writeback4 <= 0;
            branch5 <= 0;
            store5 <= 0;
            writeback5 <= 0;
            zin3 <= 0;
            nin3 <= 0;
            sin3 <= 0;
            cin3 <= 0;
            hin3 <= 0;
            vin3 <= 0;
            bflag3 <= 0;
            wea5 <= 0;
            stall4 <= 0;
            flush4 <= 0;
        end

        // Stage 1-4 only completes if not stalled by hazard detection unit - stalls occur when there is a store instruction in the pipeline
        else if (~stall4) begin
            // Stage 1 - Fetch
            decode <= instruction;

            // Stage 2 - Decode and Register Fetch
            litsrc2 <= litsrc;
            src2 <= src;
            dst2 <= dst;
            op2 <= op;
            mode2 <= mode;
            branch2 <= branch;
            store2 <= store;
            writeback2 <= writeback;

            Adata2 <= A;
            Bdata2 <= B;
            
            // Stage 3 - Execute
            litsrc3 <= litsrc2; //forwarding if needed
            dst3 <= dst2;
            op3 <= op2;
            branch3 <= branch2;
            store3 <= store2;
            writeback3 <= writeback2;
            Adata3 <= Adata2;
            Bdata3 <= Bdata2;

            zin3 <= zflag;
            nin3 <= nflag;
            sin3 <= sflag;
            cin3 <= cflag;
            hin3 <= hflag;
            vin3 <= vflag;
            bflag3<= branchflag;
            ALUoutput3 <= ALUoutput;

            // Stage 4 - Hazard Detection
            litsrc4 <= litsrc3;
            dst4 <= dst3;
            branch4 <= branch3 & bflag3; //branch if branch instruction and ALU flag is set
            store4 <= store3;
            writeback4 <= writeback3;
            ALUoutput4 <= ALUoutput3;
            
            flush4 <= flush;
            stall4 <= stall;
        end

        // Only executes if stalled by hazard detection unit
        else if (stall4) begin
            stall4 <= ~stall4; //unstall the pipeline at the next clock cycle
        end

        // Stage 5 - Writeback - completes regardless of stall
        dst5 <= dst4;
        branch5 <= branch4; //branch if branch instruction and ALU flag is set
        store5 <= store4;
        writeback5 <= writeback4;
        ALUoutput5 <= ALUoutput4;
        wea5 <= wea;
    end

    //create a program counter sequential logic
    ProgramCounter counter (.clk(pcclk), .rst(reset), .pcin(PCwriteback), .branch(branch5), .en(~stall4),
    .pcout(pcout)
    );

    //create an instruction memory
    blk_mem_gen_ROM ROM(
    .clka(clk),     // input wire clka
    .ena(memclk),         // input wire ena
    .addra(pcout),  // input wire [5 : 0] addra
    .douta(instruction)  // output wire [48 : 0] douta
    );

    //create a data memory
    blk_mem_gen_RAM RAM(
    .clka(clk),     // input wire clka
    .ena(memclk),       // input wire ena
    .wea(wea5),       // input wire [0 : 0] wea
    .addra(RAMaddr),       // input wire [7 : 0] addra
    .dina(RAMwriteback),        // input wire [31 : 0] dina
    .douta(RAMout)    // output wire [31 : 0] douta
    );
    
    //create a decoder combinational logic
    Decoder decoder(.instruction(decode),
    .litsrc(litsrc),.src(src), .dst(dst), .mode(mode), .branch(branch), .op(op), .store(store), .writeback(writeback)
    );

    //create a register file sequential & combinational logic
    RegisterFile regfile(.clk(clk), .rst(reset), .rw(rw), .d_addr(dst5), .a_addr(src2), .b_addr(litsrc2[4:0]), .data(GPRwriteback),
    .a_data(agpr), .b_data(bgpr));

    //create a mux for A bus
    Amux abusmux(.mode(modeA), .GPR(agpr),.ALU(PortForward),
    .A(A));

    //create a bus mux combinational logic
    BusMux busmux(.mode(modeout), .litsrc(litsrc2), .GPR(bgpr), .RAM(RAMout), .Overwrite(PortForward),
    .B(B)
    );

    //create an ALU combinational logic
    ALU alu(.a(Adata3), .b(Bdata3), .op(op3), .zin(zin3), .cin(cin3), .vin(vin3), .hin(hin3), .sin(sin3), .nin(nin3),
    .out(ALUoutput), .zflag(zflag), .nflag(nflag), .sflag(sflag), .cflag(cflag), .hflag(hflag), .branch(branchflag), .vflag(vflag));
    
    //create an output mux combinational logic
    OutputMux outmux(.store(store5), .branch(branch5), .writeback(writeback5), .ALUBus(ALUoutput5),
    .GPR(GPRwriteback), .RAM(RAMwriteback), .PC(PCwriteback), .wea(wea), .rw(rw));

    // create a hazard detection unit
    HazardDetector hazard(.srcregA(src2), .srcregB(litsrc2), .dstwb(dst4), .modein(mode2), .ALUoutput(ALUoutput4), .branch(branch4), .store(store4), .RAMaddr0(litsrc2), .RAMaddr1(litsrc4),
    .modeB(modeout), .Forward(PortForward), .stall(stall), .RAMout(RAMaddr), .flush(flush), .modeA(modeA));

endmodule