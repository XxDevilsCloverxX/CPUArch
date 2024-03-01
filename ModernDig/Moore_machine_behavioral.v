`timescale 1ns/1ns

module top (
   input CLK, 
   input E,
   output reg A, B, Q
);

   // Local FSM vars
   reg [1:0] cs, ns;    // current state, next state
   localparam s0 = 2'b00, s1 = 2'b01, s2 = 2'b10, s3 = 2'b11;  // state bits

   always @(posedge CLK) begin
      cs = ns;   // update the current state at the end of evaluation - sequential logic
      // based on current case and input, evaluate the ns - combinational logic
      case(cs)
         s0: begin
            if(E) ns = s0;
            else ns = s1;
            {A,B,Q} = 3'b000;
         end
         s1: begin
            if(E) ns = s2;
            else ns = s1;
            {A,B,Q} = 3'b010;
         end
         s2: begin
            if(E) ns = s3;
            else ns = s1;
            {A,B,Q} = 3'b100;
         end
         s3: begin
            if(E) ns = s0;
            else ns = s1;
            {A,B,Q} = 3'b111;
         end

         // enter the default state s0 if no state exists yet
         default: begin
            ns = s0;
         end
      endcase
   end
endmodule

module UUT;

   // Inputs to the module
   reg clk, E;
   integer i;
   // outputs of the module
   wire A, B, Q;

   // module sim
   top topuut(.CLK(clk), .E(E), .A(A), .B(B), .Q(Q));

   // clock driver signal
   initial begin
      clk = 0;
      // create a clock signal
      forever begin
         #10 clk <= ~clk;
      end
   end

   // Simulate stepping through the FSM
   initial begin
      // initial E state
      E = 0;
      i = 0;
      // top line of FSM Truth Table
      $display("E | CS | A | B | Q | NS");
      forever begin
         /* 
         wait for state updates then change input signal 
         (with clocks, you want E to be twice as long as the clock)
         */
         i = i+1;
         if (i[0]) #20 E <= ~E;
         else #20;   // still wait, but dont update e every other cycle

         if (i > 256) $finish;   // finish the simulation at 256 iterattions
         // display the current state of the fsm + inputs + outputs
         $display("%b | %2b | %b | %b | %b | %2b", E, topuut.cs, A, B, Q, topuut.ns);         
      end
   end
endmodule