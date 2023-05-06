`timescale 1ns/1ps

/*
    Name: Silas Rodriguez
    R-Number: R-11679913
    Assignment: Project 6
*/
module CPUTB;

reg clk;
reg reset;
reg memen;

wire [5:0] counter;

//clk driver
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

//memen driver
initial begin
    memen = 0;
    forever #20 memen = ~memen;
end

//reset driver  - 1 for 20ns to flush the pipeline
initial begin
    reset = 1;
    #20 reset = 0;
end

CPU cpu(
    .clk(clk),
    .reset(reset),
    .memen(memen),
    .counter(counter)
);

endmodule