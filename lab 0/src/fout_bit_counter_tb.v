`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:19:26 01/16/2019
// Design Name:   fout_bit_counter
// Module Name:   C:/Users/152/Desktop/lab0/fout_bit_counter_tb.v
// Project Name:  lab0
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: fout_bit_counter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fout_bit_counter_tb;

	// Inputs
	reg rst;
	reg clk;

	// Outputs
	wire [3:0] a;

	// Instantiate the Unit Under Test (UUT)
	fout_bit_counter uut (
		.a(a), 
		.rst(rst), 
		.clk(clk)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;
        #10
        rst = 1;
        #10
        rst = 0;

	end
    
    
    // Use an always block to generate all the test cases
    always
        #5 clk = clk + 1'b1;

    // Code to terminate simulation after all the test cases have been covered.
    initial
        #160 $finish; // After 160 timeunits, terminate simulation.
      
endmodule

