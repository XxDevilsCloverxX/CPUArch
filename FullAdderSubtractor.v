/*
add-sub.v
Developed By: Silas Rodriguez @ Texas Tech University
*/

/**
	@brief: full_adder - Adder Logic for 1 bit numbers
 	@input A, B: Bits to be added
  	@input Cin: Carried bit from previous adder, or select
   	@output Cout: Carry bit from adder
    	@output S: Sum of A + B + Cin
*/
module full_adder(A, B, Cin, Cout, S);
	input A, B, Cin;
	output Cout, S;			// cout = carry out (to next adder)
							// S = sum
	assign {Cout, S} = A + B + Cin;		// Cout will get the extra bit, S will store its bit
endmodule

/**
	@brief: top - Full adder subtractor control level
 	@input: A, B: Numbers to be added
  	@input S: 'Select' 0 for add, 1 for subtract
   	@output F: Sum of A+B or Difference A-B
*/
module top(A, B, S, F);
	input [31:0] A, B;		// Numbers to be added
	input S;				// Select for Sub
	output [31:0] F;		// Output bits

	wire [31:0] carrywires;	// Carry between full adders
	genvar i;
	// Generate 32 instances
	generate
		for (i = 0; i<32; i = i+1) begin
			if (i==0) begin
				full_adder u0 (.A(A[0]), .B(B[0] ^ S), .Cin(S), .Cout(carrywires[0]), .S(F[0]));				// 0th adder to take S
			end
			else begin
				full_adder ui (.A(A[i]), .B(B[i] ^ S), .Cin(carrywires[i-1]), .Cout(carrywires[i]), .S(F[i]));	// ith adder
			end
		end
	endgenerate
endmodule

/**
	@brief: testbench simulation for top module
*/
module testbench;
	// Change this parameter for larger numbers : 2 ** 32 Max = 4294967296, chose 8 Bit for "8 bit registers in assembly"
	parameter N = (2**8);
	parameter PrintNeg = 0;	// flip to 1 to print signed
    // Inputs
    reg [31:0] A, B;
 	reg S;
    // Outputs
	wire [31:0] F;

	// Loop variables
	integer i;
	integer j;
    // Instantiate the top module
    top uut (
        .A(A), .B(B), .S(S), .F(F) 
	);
    // Apply test vectors
    initial begin
		// For addition
		$display("Addition:");	// show updated output
		S = 0;
		for (i = 0; i<N; i=i+1) begin
			for (j = 0; j<N; j=j+1) begin
				A = i;
				B = j;
				#10 $display("%d + %d = %d", A, B, F);	// show updated output
			end
		end
		// for subtraction
		$display("Subtraction:");	// show updated output
		S = 1;
		for (i = 0; i<N; i=i+1) begin
			for (j = 0; j<N; j=j+1) begin
				A = i;
				B = j;
				#10 $display("%d - %d = %d", A, B, F);	// show updated output
			end
		end
        // Finish simulation
        $finish;
    end
endmodule
