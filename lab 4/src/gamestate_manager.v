`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    gamestate_manager
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
module gamestate_manager(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	input wire is_bird_on_ground,
	input wire is_bird_overlap,
    input wire is_bird_on_ceiling,
	output wire isDone
	);
	
assign isDone = is_bird_on_ground | is_bird_overlap | is_bird_on_ceiling;
	
endmodule
