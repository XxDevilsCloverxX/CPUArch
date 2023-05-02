module CPUTB;

reg clk;
reg reset;
reg pcclk;

wire [5:0] counter;

//clk driver
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

//pcclk driver
initial begin
    pcclk = 0;
    forever #5 pcclk = ~pcclk;
end

//reset driver  - 1 for 20ns to flush the pipeline
initial begin
    reset = 1;
    #20 reset = 0;
end

CPU cpu(
    .clk(clk),
    .reset(reset),
    .pcclk(pcclk)
    .pcout(counter)
);

endmodule