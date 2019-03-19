`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   06:57:03 01/20/2019
// Design Name:   FPCVT
// Module Name:   /home/ise/CS_152A/lab 1/lab1/fpcvt_tb.v
// Project Name:  lab1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FPCVT
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fpcvt_tb;

	// Inputs
	reg [12:0] D;

	// Outputs
	wire S;
	wire [2:0] E;
	wire [4:0] F;
	// Instantiate the Unit Under Test (UUT)
	
	FPCVT uut (
		.D(D), 
		.S(S), 
		.E(E), 
		.F(F)
	);
	
	

	initial begin
		// Initialize Inputs
		/*
			Test Case 1:
			D  = 1_1110_0101_1010 (-422)
			~D = 0_0001_1010_0110 (422)
			F  = 11010
			E  = 100              (4)
			S  = 1
		*/
		//D = 'b1111001011010;
		
		/*
			Test Case 2:
			D = 0_0000_1010_0111
			F = 10101
			E = 011
			S = 0
		*/
		//D = 'b0000010100111;
		
		/*
			Test Case 3:
			D = 0_0000_0110_1111
			F = 11100
			E = 010
			S = 0
		*/
		//D = 'b0000001101111;
		
		/*
			Test Case 4:
			D = 0_0000_0000_0100
			F = 00100
			E = 000
			S = 0
		*/
		//D = 'b0000000000100;
		
		/*
			Test Case 5:
			D = 0_0000_0000_0000
			F = 00000
			E = 000
			S = 0
		*/
		//D = 'b0000000000000;
		
		/*
			Test Case 6:
			D = 0_0001_1111_1111
			F = 10000
			E = 101
			S = 0
		*/
		//D = 'b0000111111111;
		
		/*
			Test Case 7:
			D = 1_0000_0000_0000
			F = 11111
			E = 111
			S = 1
		*/
		//D = 'b1000000000000;
        
        /*
            Test Case 8
            D = 0_1111_1100_0000
            F = 11111
            E = 111
            S = 0
        */
        D = 'b0111111000000;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		$finish;

	end
	
endmodule

