`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 02/26/2019 
// Design Name: 
// Module Name:    debouncer 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module debouncer(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	input wire btn,		//jump button
	output wire jump	//jump posedge
	);


	 reg    [16:0] clk_dv;
    reg           clk_en;
    reg           clk_en_d;
    reg    [2:0]  step_d;
    
    wire  [17:0] clk_dv_inc;

    // ===========================================================================
    // timing signal for clock enable
    // ===========================================================================

	assign clk_dv_inc = clk_dv + 1;
   
    always @ (posedge clk) begin
		if (clr) begin
			clk_dv   <= 0;
        	clk_en   <= 1'b0;
        	clk_en_d <= 1'b0;
        end
      	else begin
        	clk_dv   <= clk_dv_inc[16:0];
         	clk_en   <= clk_dv_inc[17];
        	clk_en_d <= clk_en;
      	end
    end

    // ===========================================================================
   	// Debouncing
   	// ===========================================================================

	assign jump = ~ step_d[0] & step_d[1];

   	always @ (posedge clk)
      	if (clr)
         	step_d[2:0]  <= 0;
      	else if (clk_en) // Down sampling
        	step_d[2:0]  <= {btn, step_d[2:1]};

endmodule
