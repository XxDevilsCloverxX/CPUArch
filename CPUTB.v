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

//memclk driver
initial begin
    memclk = 0;
    forever #20 memclk = ~memclk;
end

endmodule