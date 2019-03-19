`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    random 
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
module random(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	input wire [8:0] screen_height,
	input wire [8:0] pipe_gap_y,
	output wire [9:0] random1,
	output wire [9:0] random2,
	output wire [9:0] random3
	);
	
reg [9:0] random_generator_1;
reg [9:0] random_generator_2;
reg [9:0] random_generator_3;

assign random1 = random_generator_1;
assign random2 = random_generator_2;
assign random3 = random_generator_3;

always @ (posedge clk or posedge clr) begin
	if (clr) begin
		random_generator_1 <= 8'b10010110;
      random_generator_2 <= 8'b11110110;
		random_generator_2 <= 8'b11100110;
	end
	else begin
		random_generator_1 <= 
			(random_generator_1 ^ (random_generator_1 << 1)) 
			% (screen_height - pipe_gap_y);
			
      random_generator_2 <= 
			(random_generator_2 ^ (random_generator_2 << 1)) 
			% (screen_height - pipe_gap_y);
			
		random_generator_3 <= 
			(random_generator_3 ^ (random_generator_3 << 1)) 
			% (screen_height - pipe_gap_y);
	end
end


endmodule
