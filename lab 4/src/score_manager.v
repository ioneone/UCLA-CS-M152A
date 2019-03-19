`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    score_manger 
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
module score_manager(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	input wire [9:0] bird_pos_x,
	input wire [9:0] pipe1_pos_x,
	input wire [9:0] pipe1_width,
	input wire [9:0] pipe2_pos_x,
	input wire [9:0] pipe2_width,
	input wire [9:0] pipe3_pos_x,
	input wire [9:0] pipe3_width,
	input wire isDone,
	output reg [3:0] score1,
	output reg [3:0] score2,
	output reg [3:0] score3
	);
		
wire should_increment = 
	(pipe1_pos_x + pipe1_width == bird_pos_x) 
	| (pipe2_pos_x + pipe2_width == bird_pos_x) 
	| (pipe3_pos_x + pipe3_width == bird_pos_x);

always @ (posedge clk or posedge clr) begin

	if (clr) begin
		score1 <= 0;
		score2 <= 0;
		score3 <= 0;
	end 
	else begin
		if (should_increment) begin
		
			if (score1 == 'd9) begin
				score1 <= 0;
				if (score2 == 'd9) begin
					score2 <= 0;
					if (score3 == 'd9) begin
						score3 <= 0;
					end
					else
						score3 <= score3 + 1;
				end
                else 
                    score2 <= score2 + 1;
            end
            else
                score1 <= score1 + 1;
        end
	end

end


endmodule
