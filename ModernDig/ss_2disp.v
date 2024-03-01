`timescale 1ns/1ns

module SevenSegDriver(
    input [3:0] number,
    output A, B, C, D, E, F, G, dp // 8 1-bit outputs
);
    // What comes on | what numbers turn them on
            assign A = number==0 | number==2 | number==3 | number==5 | number==6 | number==7 | number==8 | number==9 | number==4'HA | number==4'HC | number==4'HE | number==4'HF;
            assign B = number==0 | number==1 | number==2 | number==3 | number==4 | number==7 | number==8 | number==9 | number==4'HA | number==4'HD;
            assign C = number==0 | number==1 | number==3 | number==4 | number==5 | number==6 | number==7 | number==8 | number==9 | number==4'HA | number==4'HB | number==4'HD;
            assign D = number==0 | number==2 | number==3 | number==5 | number==6 | number==8 | number==9 | number==4'HB | number==4'HC | number==4'HD | number==4'HE;
            assign E = number==0 | number==2 | number==6 | number==8 | number==4'HA | number==4'HB | number==4'HC | number==4'HD | number==4'HE | number==4'HF;
            assign F = number==0 | number==4 | number==5 | number==6 | number==8 | number==9 | number==4'HA | number==4'HB | number==4'HC | number==4'HE | number==4'HF;
            assign G = number==2 | number==3 | number==4 | number==5 | number==6 | number==8 | number==9 | number==4'HA | number==4'HB | number==4'HD | number==4'HE | number==4'HF;
            // only turn on when number's MSB is 1
            assign dp = 0;
endmodule

module Top(Value,SevenSegDig1,SevenSegDig2);
    //Port Declarations
    input [7:0] Value; 
    output [7:0] SevenSegDig1, SevenSegDig2; 

    //Logic
    SevenSegDriver Unit0(Value[7:4], SevenSegDig2[0],SevenSegDig2[1],SevenSegDig2[2],SevenSegDig2[3],SevenSegDig2[4],SevenSegDig2[5],SevenSegDig2[6], SevenSegDig2[7]);
    SevenSegDriver Unit1(Value[3:0], SevenSegDig1[0],SevenSegDig1[1],SevenSegDig1[2],SevenSegDig1[3],SevenSegDig1[4],SevenSegDig1[5],SevenSegDig1[6], SevenSegDig1[7]);    
endmodule

// Simulate the complex module working 
module TOP_SIM;
    //input
    reg [7:0] display_num;  // 0-255 3:0 + 3:0 = 7:0 for left display and right display
    //output
    wire [7:0] SSD1; 
    wire [7:0] SSD2; 

    // define the connections
    Top ComplexMod(.Value(display_num), .SevenSegDig2(SSD2), .SevenSegDig1(SSD1)); 

    // simulation step
    initial begin
        $display("%36s|%-36s", "SSEG 2              ", "            SSEG1");
        $display("%36s %-36s", " i | dp | G | F | E | D | C | B | A |",  "dp | G | F | E | D | C | B | A", );
        for (integer i=0; i<256; i=i+1) begin
            display_num=i;
            #10; // delay the signal update
            $display("%3h| %2b | %b | %b | %b | %b | %b | %b | %b | %2b | %b | %b | %b | %b | %b | %b | %b", display_num, SSD2[7],SSD2[6],SSD2[5],SSD2[4],SSD2[3],SSD2[2],SSD2[1], SSD2[0], SSD1[7],SSD1[6],SSD1[5],SSD1[4],SSD1[3],SSD1[2],SSD1[1], SSD1[0]);
        end
    end
endmodule


// simulate the simple modules working
// module SSEG_SIM;
//     //input
//     reg [7:0] display_num;  // 0-255 3:0 + 3:0 = 7:0 for left display and right display
//     //output
//     wire a1,b1,c1,d1,e1,f1,g1,dp1;
//     wire a2,b2,c2,d2,e2,f2,g2,dp2;

//     // define the connections
//     Hex_SSEG SSEG1(display_num[3:0], a1,b1,c1,d1,e1,f1,g1, dp1);   // right display - displays 0-f "ones place" - lower 4 bits
//     Hex_SSEG SSEG2(display_num[7:4], a2,b2,c2,d2,e2,f2,g2, dp2);   // left display - display 0-f   "tens place" - upper 4 bits

//     // Use just the top module to display the total output

//     // simulation step
//     initial begin
//         $display("%36s|%-36s", "SSEG 2              ", "            SSEG1");
//         $display("%36s %-36s", "  i| A | B | C | D | E | F | G | dp |",  "A | B | C | D | E | F | G | dp", );
//         for (integer i=0; i<256; i=i+1) begin
//             display_num=i;
//             #10; // delay the signal update
//             $display("%3h| %b | %b | %b | %b | %b | %b | %b | %2b | %b | %b | %b | %b | %b | %b | %b | %b", display_num, a2,b2,c2,d2,e2,f2,g2, dp2, a1,b1,c1,d1,e1,f1,g1, dp1);
//         end
//     end
// endmodule