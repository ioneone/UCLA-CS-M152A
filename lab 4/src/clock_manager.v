`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    clock_manger 
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
module clock_manager(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	output wire clk_bird,
	output wire clk_pipe,
    output wire clk_moving_pipe
	);
	
parameter clk_bird_counter_max = 1_000_000;
parameter clk_pipe_counter_max = 2_000_000;
parameter clk_moving_pipe_counter_max = 4_000_000;
	
reg [26:0] clk_bird_counter;
reg [26:0] clk_pipe_counter;
reg [26:0] clk_moving_pipe_counter;

assign clk_bird = clk_bird_counter == clk_bird_counter_max;
assign clk_pipe = clk_pipe_counter == clk_pipe_counter_max;
assign clk_moving_pipe = clk_moving_pipe_counter == clk_moving_pipe_counter_max;

always @ (posedge clk or posedge clr) begin

	if (clr) begin
        clk_bird_counter <= 0;
        clk_pipe_counter <= 0;
        clk_moving_pipe_counter <= 0;
	end 
	else begin
	
		if (clk_bird)
			clk_bird_counter <= 'd0;
		else
			clk_bird_counter <= clk_bird_counter + 1;
        
        if (clk_pipe)
			clk_pipe_counter <= 'd0;
		else
			clk_pipe_counter <= clk_pipe_counter + 1; 
            
        if (clk_moving_pipe)
			clk_moving_pipe_counter <= 'd0;
		else
			clk_moving_pipe_counter <= clk_moving_pipe_counter + 1; 
            
        
        
	end

end

	

endmodule
