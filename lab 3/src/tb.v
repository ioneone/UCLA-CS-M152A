`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   06:26:24 02/16/2019
// Design Name:   nexys3
// Module Name:   /home/ise/CS_152A/lab 3/src/tb.v
// Project Name:  project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: nexys3
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb;

	// Inputs
	reg [1:0] sw;
	reg btnS;
	reg btnR;
	reg clk;

	// Outputs
	wire [7:0] seg;
	wire [3:0] an;

	// Instantiate the Unit Under Test (UUT)
	nexys3 uut (
		.seg(seg), 
		.an(an), 
		.sw(sw), 
		.btnS(btnS), 
		.btnR(btnR), 
		.clk(clk)
	);

	initial begin
		// Initialize Inputs
		sw = 0;
		btnS = 0;
		btnR = 1;
		clk = 0;
		#100 btnR = 0;
        
		// Tests
		
		//tskTestNoAdjustMode();
		//tskTestPause();
		//tskTestAdjustSecondsMode();
		tskTestAdjustMinutesMode();

	end
	
	always #1 clk = ~clk;
	
	task tskTestNoAdjustMode;
		begin
			sw[0] = 0;
		end
	endtask
	
	task tskTestPause;
		begin
			#1500000 btnS = 1;
			//#30000000 btnS = 0;
			//#15000000 btnS = 1;
		end
	endtask
	
	task tskTestAdjustSecondsMode;
		begin
			sw[0] = 1;
			sw[1] = 1;
		end
	endtask
	
	task tskTestAdjustMinutesMode;
		begin
			sw[0] = 1;
			sw[1] = 0;
		end
	endtask
      
endmodule

