`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    collision_detection
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
module collision_detection(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	input wire [9:0] bird_pos_x,
	input wire [8:0] bird_pos_y,
	input wire [8:0] bird_width,
	input wire [8:0] bird_height,
	input wire [8:0] pipe_gap_y,
	input wire [9:0] pipe1_pos_x,
	input wire [8:0] pipe1_gap_pos_y,
	input wire [9:0] pipe1_width,
	input wire [9:0] pipe2_pos_x,
	input wire [8:0] pipe2_gap_pos_y,
	input wire [9:0] pipe2_width,
	input wire [9:0] pipe3_pos_x,
	input wire [8:0] pipe3_gap_pos_y,
	input wire [9:0] pipe3_width,
	input wire [8:0] screen_height,
	output wire is_bird_on_ground,
	output wire is_bird_overlap,
    output wire is_bird_on_ceiling
	);
	
assign is_bird_on_ground = bird_pos_y >= screen_height - bird_height;
assign is_bird_on_ceiling = bird_pos_y == 0;
	
	// x violation
wire [9:0] bird_max_x = bird_pos_x + bird_width - 2;
wire [9:0] pipe1_max_x = pipe1_pos_x + pipe1_width;
wire [9:0] pipe2_max_x = pipe2_pos_x + pipe2_width;
wire [9:0] pipe3_max_x = pipe3_pos_x + pipe3_width;

wire is_bird_overlap1_x_max = (pipe1_pos_x <= bird_max_x) && (bird_max_x <= pipe1_max_x);
wire is_bird_overlap2_x_max = (pipe2_pos_x <= bird_max_x) && (bird_max_x <= pipe2_max_x);
wire is_bird_overlap3_x_max = (pipe3_pos_x <= bird_max_x) && (bird_max_x <= pipe3_max_x);
wire is_bird_overlap1_x_min = (pipe1_pos_x <= bird_pos_x) && (bird_pos_x <= pipe1_max_x);
wire is_bird_overlap2_x_min = (pipe2_pos_x <= bird_pos_x) && (bird_pos_x <= pipe2_max_x);
wire is_bird_overlap3_x_min = (pipe3_pos_x <= bird_pos_x) && (bird_pos_x <= pipe3_max_x);

// y violation
wire [8:0] pipe1_bot_y = pipe1_gap_pos_y + pipe_gap_y;
wire [8:0] pipe2_bot_y = pipe2_gap_pos_y + pipe_gap_y;
wire [8:0] pipe3_bot_y = pipe3_gap_pos_y + pipe_gap_y;
wire [8:0] bird_min_y = bird_pos_y + bird_height;

wire is_bird_overlap1_y_top = (bird_pos_y <= pipe1_gap_pos_y);
wire is_bird_overlap2_y_top = (bird_pos_y <= pipe2_gap_pos_y);
wire is_bird_overlap3_y_top = (bird_pos_y <= pipe3_gap_pos_y);

wire is_bird_overlap1_y_bot = (pipe1_bot_y <= bird_min_y);
wire is_bird_overlap2_y_bot = (pipe2_bot_y <= bird_min_y);
wire is_bird_overlap3_y_bot = (pipe3_bot_y <= bird_min_y);

wire is_bird_overlap1_y = is_bird_overlap1_y_top || is_bird_overlap1_y_bot;
wire is_bird_overlap2_y = is_bird_overlap2_y_top || is_bird_overlap2_y_bot;
wire is_bird_overlap3_y = is_bird_overlap3_y_top || is_bird_overlap3_y_bot;

wire is_bird_overlap1 = is_bird_overlap1_y & (is_bird_overlap1_x_max || is_bird_overlap1_x_min);
wire is_bird_overlap2 = is_bird_overlap2_y & (is_bird_overlap2_x_max || is_bird_overlap2_x_min);
wire is_bird_overlap3 = is_bird_overlap3_y & (is_bird_overlap3_x_max || is_bird_overlap3_x_min);

assign is_bird_overlap = is_bird_overlap1 | is_bird_overlap2 | is_bird_overlap3;

endmodule
