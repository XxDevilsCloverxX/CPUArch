module ProgramCounter (
    input clk,                  // Clock signal
    input rst,                  // Reset signal
    input branch,               // Branch signal
    input [31:0] pc_in,         // Program counter input
    output reg [31:0] pc_out    // Program counter output
);
    
    reg [6:0] addr;            // Address register can address 64 locations of ROM

    always @(posedge clk) begin
        if (rst) begin
            pc_out = 0;      // Reset for the program counter
            addr = 0;        // Reset for the address register
        end 
        else if (branch) begin
            pc_out = pc_in;   // Branch to the address being passed in
        end
        else begin
            pc_out = addr;    // Increment the program counter
            addr = addr + 1;  // Increment the address register
        end
    end
endmodule

