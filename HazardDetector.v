module HazardDetector (
    input [4:0] srcexe,        //source register
    input [4:0] dstwb,        //destination register

    input [1:0] modein,     //Mux select input
    output reg [1:0] modeout,   //mux select overwrite
    
    input [31:0] ALUoutput, //ALU output
    output reg [31:0] Forward,        // forward the ALU output to the execute stage
    
    input [31:0] RAMaddr0,   //RAM address to be read from
    input [31:0] RAMaddr1,   //RAM address to be written to
    input store,            //store signal
    output reg stall,       //stall signal
    output reg [31:0] RAMout,   //RAM address to be accessed

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