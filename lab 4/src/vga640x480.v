`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
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

module vga640x480(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	input wire [9:0] bird_pos_x,
	input wire [8:0] bird_pos_y,
	input wire [8:0] bird_width,
	input wire [8:0] bird_height,
	input wire [8:0] pipe_gap_y,
	input wire [9:0] pipe1_pos_x,
	input wire [8:0] pipe1_gap_pos_y,
	input wire [8:0] pipe1_width,
	input wire [9:0] pipe2_pos_x,
	input wire [8:0] pipe2_gap_pos_y,
	input wire [8:0] pipe2_width,
	input wire [9:0] pipe3_pos_x,
	input wire [8:0] pipe3_gap_pos_y,
	input wire [8:0] pipe3_width,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue,	//blue vga output
	output wire [9:0] screen_width,
	output wire [8:0] screen_height
	);
    
// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// graphic parameter (top-left is (0, 0))
assign screen_width = hfp - hbp;
assign screen_height = vfp - vbp;

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=

always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =



wire is_background_in_range = vc >= vbp && vc < vfp && hc >= hbp && hc < hfp;

/*
wire is_bird_in_range = 
		vc >= vbp + (bird_pos_y) 
        && vc <= vbp + (bird_pos_y + bird_height) 
        && hc >= hbp + (bird_pos_x) 
        && hc <= hbp + (bird_pos_x + bird_width);

wire is_pipe1_veritical_in_range = 
    ((vc >= vbp) && (vc <= vbp + pipe1_gap_pos_y)) 
    || ((vc >= vbp + pipe1_gap_pos_y + pipe_gap_y) && (vc < vfp)) ;
wire is_pipe1_horizontal_in_range = 
    (hc >= hbp + pipe1_pos_x) 
    && (hc <= hbp + pipe1_pos_x + pipe1_width);

wire is_pipe2_veritical_in_range = 
    ((vc >= vbp) && (vc <= vbp + pipe2_gap_pos_y)) 
    || ((vc >= vbp + pipe2_gap_pos_y + pipe_gap_y) && (vc < vfp)) ;
wire is_pipe2_horizontal_in_range = 
    (hc >= hbp + pipe2_pos_x) 
    && (hc <= hbp + pipe2_pos_x + pipe2_width);
	 
wire is_pipe3_veritical_in_range = 
    ((vc >= vbp) && (vc <= vbp + pipe3_gap_pos_y)) 
    || ((vc >= vbp + pipe3_gap_pos_y + pipe_gap_y) && (vc < vfp)) ;
wire is_pipe3_horizontal_in_range = 
    (hc >= hbp + pipe3_pos_x) 
    && (hc <= hbp + pipe3_pos_x + pipe3_width);
*/


wire [9:0] bird_offset_x = hbp + bird_pos_x;
wire [9:0] bird_offset_y = vbp + bird_pos_y;

wire is_bird_black_in_range =
	((vc == bird_offset_y) && (bird_offset_x + 12 <= hc && hc <= bird_offset_x + 24))
	|| ((vc == bird_offset_y + 1) && (bird_offset_x + 12 <= hc && hc <= bird_offset_x + 24))
	|| ((vc == bird_offset_y + 2) && (bird_offset_x + 8 <= hc && hc <= bird_offset_x + 26))
	|| ((vc == bird_offset_y + 3) && (bird_offset_x + 8 <= hc && hc <= bird_offset_x + 12))
	|| ((vc == bird_offset_y + 3) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 3) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 26))
	|| ((vc == bird_offset_y + 4) && (bird_offset_x + 6 <= hc && hc <= bird_offset_x + 12))
	|| ((vc == bird_offset_y + 4) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 4) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 28))
	|| ((vc == bird_offset_y + 5) && (bird_offset_x + 6 <= hc && hc <= bird_offset_x + 8))
	|| ((vc == bird_offset_y + 5) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 5) && (bird_offset_x + 26 <= hc && hc <= bird_offset_x + 28))
	|| ((vc == bird_offset_y + 6) && (bird_offset_x + 2 <= hc && hc <= bird_offset_x + 10))
	|| ((vc == bird_offset_y + 6) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 6) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 2 <= hc && hc <= bird_offset_x + 10))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 26))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 28 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x <= hc && hc <= bird_offset_x + 12))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 26))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x + 28 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x <= hc && hc <= bird_offset_x + 2))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 12))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 26))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 28 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x <= hc && hc <= bird_offset_x + 2))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 14))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 24 <= hc && hc <= bird_offset_x + 26))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 28 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x <= hc && hc <= bird_offset_x + 2))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x + 12 <= hc && hc <= bird_offset_x + 14))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x + 28 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x <= hc && hc <= bird_offset_x + 2))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x + 12 <= hc && hc <= bird_offset_x + 14))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 32))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x <= hc && hc <= bird_offset_x + 2))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x + 12 <= hc && hc <= bird_offset_x + 14))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x + 20 <= hc && hc <= bird_offset_x + 32))
	|| ((vc == bird_offset_y + 14) && (bird_offset_x <= hc && hc <= bird_offset_x + 4))
	|| ((vc == bird_offset_y + 14) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 14))
	|| ((vc == bird_offset_y + 14) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 34))
	|| ((vc == bird_offset_y + 15) && (bird_offset_x + 2 <= hc && hc <= bird_offset_x + 4))
	|| ((vc == bird_offset_y + 15) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 12))
	|| ((vc == bird_offset_y + 15) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 15) && (bird_offset_x + 32 <= hc && hc <= bird_offset_x + 34))
	|| ((vc == bird_offset_y + 16) && (bird_offset_x + 2 <= hc && hc <= bird_offset_x + 12))
	|| ((vc == bird_offset_y + 16) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 34))
	|| ((vc == bird_offset_y + 17) && (bird_offset_x + 4 <= hc && hc <= bird_offset_x + 10))
	|| ((vc == bird_offset_y + 17) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 17) && (bird_offset_x + 20 <= hc && hc <= bird_offset_x + 32))
	|| ((vc == bird_offset_y + 18) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 18))
	|| ((vc == bird_offset_y + 18) && (bird_offset_x + 4 <= hc && hc <= bird_offset_x + 10))
	|| ((vc == bird_offset_y + 18) && (bird_offset_x + 16 <= hc && hc <= bird_offset_x + 32))
	|| ((vc == bird_offset_y + 19) && (bird_offset_x + 4 <= hc && hc <= bird_offset_x + 6))
	|| ((vc == bird_offset_y + 19) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 19) && (bird_offset_x + 30 <= hc && hc <= bird_offset_x + 32))
	|| ((vc == bird_offset_y + 20) && (bird_offset_x + 4 <= hc && hc <= bird_offset_x + 10))
	|| ((vc == bird_offset_y + 20) && (bird_offset_x + 18 <= hc && hc <= bird_offset_x + 32))
	|| ((vc == bird_offset_y + 21) && (bird_offset_x + 6 <= hc && hc <= bird_offset_x + 10))
	|| ((vc == bird_offset_y + 21) && (bird_offset_x + 20 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 22) && (bird_offset_x + 6 <= hc && hc <= bird_offset_x + 30))
	|| ((vc == bird_offset_y + 23) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 20))
	|| ((vc == bird_offset_y + 24) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 20));


wire is_bird_yellow_in_range = 
	((vc == bird_offset_y + 3) && (bird_offset_x + 13 <= hc && hc <= bird_offset_x + 17))
	|| ((vc == bird_offset_y + 4) && (bird_offset_x + 13 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 5) && (bird_offset_x + 9 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 6) && (bird_offset_x + 11 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 11 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x + 13 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 13 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 15 == hc))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x + 15 <= hc && hc <= bird_offset_x + 17))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x + 3 <= hc && hc <= bird_offset_x + 4))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 11))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x + 15 <= hc && hc <= bird_offset_x + 17))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x + 3 <= hc && hc <= bird_offset_x + 4))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x + 10 <= hc && hc <= bird_offset_x + 11))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x + 15 <= hc && hc <= bird_offset_x + 19))
	|| ((vc == bird_offset_y + 14) && (bird_offset_x + 5 <= hc && hc <= bird_offset_x + 9))
	|| ((vc == bird_offset_y + 14) && (bird_offset_x + 15 <= hc && hc <= bird_offset_x + 17))
	|| ((vc == bird_offset_y + 15) && (bird_offset_x + 5 <= hc && hc <= bird_offset_x + 9))
	|| ((vc == bird_offset_y + 15) && (bird_offset_x + 13 <= hc && hc <= bird_offset_x + 17));


wire is_bird_orange_in_range =
	((vc == bird_offset_y + 16) && (bird_offset_x + 13 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 17) && (bird_offset_x + 11 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 18) && (bird_offset_x + 11 <= hc && hc <= bird_offset_x + 15))
	|| ((vc == bird_offset_y + 19) && (bird_offset_x + 7 <= hc && hc <= bird_offset_x + 17))
	|| ((vc == bird_offset_y + 20) && (bird_offset_x + 11 <= hc && hc <= bird_offset_x + 17))
	|| ((vc == bird_offset_y + 21) && (bird_offset_x + 11 <= hc && hc <= bird_offset_x + 19));


wire is_bird_red_in_range =
	((vc == bird_offset_y + 15) && (bird_offset_x + 21 <= hc && hc <= bird_offset_x + 31))
	|| ((vc == bird_offset_y + 17) && (bird_offset_x + 19 == hc))
	|| ((vc == bird_offset_y + 19) && (bird_offset_x + 21 <= hc && hc <= bird_offset_x + 29));


wire is_bird_white_in_range = 
	((vc == bird_offset_y + 3) && (bird_offset_x + 21 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 4) && (bird_offset_x + 21 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 5) && (bird_offset_x + 19 <= hc && hc <= bird_offset_x + 25))
	|| ((vc == bird_offset_y + 6) && (bird_offset_x + 19 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 19 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 7) && (bird_offset_x + 27 == hc))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x + 19 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 8) && (bird_offset_x + 27 == hc))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 3 <= hc && hc <= bird_offset_x + 9))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 19 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 9) && (bird_offset_x + 27 == hc))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 3 <= hc && hc <= bird_offset_x + 9))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 21 <= hc && hc <= bird_offset_x + 23))
	|| ((vc == bird_offset_y + 10) && (bird_offset_x + 27 == hc))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x + 3 <= hc && hc <= bird_offset_x + 11))
	|| ((vc == bird_offset_y + 11) && (bird_offset_x + 21 <= hc && hc <= bird_offset_x + 27))
	|| ((vc == bird_offset_y + 12) && (bird_offset_x + 5 <= hc && hc <= bird_offset_x + 9))
	|| ((vc == bird_offset_y + 13) && (bird_offset_x + 5 <= hc && hc <= bird_offset_x + 9));


parameter pipe_head_height = 16;

wire [9:0] pipe1_offset_x = hbp + pipe1_pos_x;
wire [9:0] pipe1_top_offset_y = vbp + pipe1_gap_pos_y;
wire [9:0] pipe1_bottom_offset_y = vbp + pipe1_gap_pos_y + pipe_gap_y;

wire is_pipe1_top_black_in_range =
	((hc == pipe1_offset_x) 
		&& ((pipe1_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe1_top_offset_y - 1)))
	|| ((hc == pipe1_offset_x + 1)
		&& ((pipe1_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe1_top_offset_y - 1)))
	|| ((hc == pipe1_offset_x + pipe1_width - 2) 
		&& ((pipe1_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe1_top_offset_y - 1)))
	|| ((hc == pipe1_offset_x + pipe1_width - 1) 
		&& ((pipe1_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe1_top_offset_y - 1)))
	|| ((hc == pipe1_offset_x + 2)
		&& ((vbp <= vc && vc <= pipe1_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe1_offset_x + 3) 
		&& ((vbp <= vc && vc <= pipe1_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe1_offset_x + pipe1_width - 4) 
		&& ((vbp <= vc && vc <= pipe1_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe1_offset_x + pipe1_width - 3) 
		&& ((vbp <= vc && vc <= pipe1_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((vc == pipe1_top_offset_y - (pipe_head_height + 2 + 2 - 1))
		&& (pipe1_offset_x + 2 <= hc && hc <= pipe1_offset_x + pipe1_width - 1 - 2))
	|| ((vc == pipe1_top_offset_y - (pipe_head_height + 2 + 2 - 1) + 1)
		&& (pipe1_offset_x + 2 <= hc && hc <= pipe1_offset_x + pipe1_width - 1 - 2))
	|| ((vc == pipe1_top_offset_y - 1 - 1)
		&& (pipe1_offset_x <= hc && hc <= pipe1_offset_x + pipe1_width - 1))
	|| ((vc == pipe1_top_offset_y - 1)
		&& (pipe1_offset_x <= hc && hc <= pipe1_offset_x + pipe1_width - 1));

wire is_pipe1_bottom_black_in_range = 
	((hc == pipe1_offset_x) 
		&& (pipe1_bottom_offset_y + 2 <= vc && vc <= pipe1_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe1_offset_x + 1) 
		&& (pipe1_bottom_offset_y + 2 <= vc && vc <= pipe1_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe1_offset_x + pipe1_width - 1) 
		&& (pipe1_bottom_offset_y + 2 <= vc && vc <= pipe1_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe1_offset_x + pipe1_width - 2) 
		&& (pipe1_bottom_offset_y + 2 <= vc && vc <= pipe1_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe1_offset_x + 2) 
		&& (pipe1_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe1_offset_x + 3) 
		&& (pipe1_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe1_offset_x + pipe1_width - 1 - 2) 
		&& (pipe1_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe1_offset_x + pipe1_width - 1 - 3) 
		&& (pipe1_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((vc == pipe1_bottom_offset_y) 
		&& (pipe1_offset_x <= hc && hc < pipe1_offset_x + pipe1_width - 1))
	|| ((vc == pipe1_bottom_offset_y + 1) 
		&& (pipe1_offset_x <= hc && hc < pipe1_offset_x + pipe1_width - 1))
	|| ((vc == pipe1_bottom_offset_y + 2 + pipe_head_height) 
		&& (pipe1_offset_x + 2 <= hc && hc < pipe1_offset_x + pipe1_width - 1 - 2))
	|| ((vc == pipe1_bottom_offset_y + 2 + pipe_head_height + 1) 
		&& (pipe1_offset_x + 2 <= hc && hc < pipe1_offset_x + pipe1_width - 1 - 2));

wire is_pipe1_black_in_range = is_pipe1_top_black_in_range | is_pipe1_bottom_black_in_range;




wire [9:0] pipe2_offset_x = hbp + pipe2_pos_x;
wire [9:0] pipe2_top_offset_y = vbp + pipe2_gap_pos_y;
wire [9:0] pipe2_bottom_offset_y = vbp + pipe2_gap_pos_y + pipe_gap_y;

wire is_pipe2_top_black_in_range =
	((hc == pipe2_offset_x) 
		&& ((pipe2_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe2_top_offset_y - 1)))
	|| ((hc == pipe2_offset_x + 1)
		&& ((pipe2_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe2_top_offset_y - 1)))
	|| ((hc == pipe2_offset_x + pipe2_width - 2) 
		&& ((pipe2_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe2_top_offset_y - 1)))
	|| ((hc == pipe2_offset_x + pipe2_width - 1) 
		&& ((pipe2_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe2_top_offset_y - 1)))
	|| ((hc == pipe2_offset_x + 2)
		&& ((vbp <= vc && vc <= pipe2_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe2_offset_x + 3) 
		&& ((vbp <= vc && vc <= pipe2_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe2_offset_x + pipe2_width - 4) 
		&& ((vbp <= vc && vc <= pipe2_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe2_offset_x + pipe2_width - 3) 
		&& ((vbp <= vc && vc <= pipe2_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((vc == pipe2_top_offset_y - (pipe_head_height + 2 + 2 - 1))
		&& (pipe2_offset_x + 2 <= hc && hc <= pipe2_offset_x + pipe2_width - 1 - 2))
	|| ((vc == pipe2_top_offset_y - (pipe_head_height + 2 + 2 - 1) + 1)
		&& (pipe2_offset_x + 2 <= hc && hc <= pipe2_offset_x + pipe2_width - 1 - 2))
	|| ((vc == pipe2_top_offset_y - 1 - 1)
		&& (pipe2_offset_x <= hc && hc <= pipe2_offset_x + pipe2_width - 1))
	|| ((vc == pipe2_top_offset_y - 1)
		&& (pipe2_offset_x <= hc && hc <= pipe2_offset_x + pipe2_width - 1));

wire is_pipe2_bottom_black_in_range = 
	((hc == pipe2_offset_x) 
		&& (pipe2_bottom_offset_y + 2 <= vc && vc <= pipe2_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe2_offset_x + 1) 
		&& (pipe2_bottom_offset_y + 2 <= vc && vc <= pipe2_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe2_offset_x + pipe2_width - 1) 
		&& (pipe2_bottom_offset_y + 2 <= vc && vc <= pipe2_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe2_offset_x + pipe2_width - 2) 
		&& (pipe2_bottom_offset_y + 2 <= vc && vc <= pipe2_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe2_offset_x + 2) 
		&& (pipe2_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe2_offset_x + 3) 
		&& (pipe2_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe2_offset_x + pipe2_width - 1 - 2) 
		&& (pipe2_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe2_offset_x + pipe2_width - 1 - 3) 
		&& (pipe2_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((vc == pipe2_bottom_offset_y) 
		&& (pipe2_offset_x <= hc && hc < pipe2_offset_x + pipe2_width - 1))
	|| ((vc == pipe2_bottom_offset_y + 1) 
		&& (pipe2_offset_x <= hc && hc < pipe2_offset_x + pipe2_width - 1))
	|| ((vc == pipe2_bottom_offset_y + 2 + pipe_head_height) 
		&& (pipe2_offset_x + 2 <= hc && hc < pipe2_offset_x + pipe2_width - 1 - 2))
	|| ((vc == pipe2_bottom_offset_y + 2 + pipe_head_height + 1) 
		&& (pipe2_offset_x + 2 <= hc && hc < pipe2_offset_x + pipe2_width - 1 - 2));

wire is_pipe2_black_in_range = is_pipe2_top_black_in_range | is_pipe2_bottom_black_in_range;



wire [9:0] pipe3_offset_x = hbp + pipe3_pos_x;
wire [9:0] pipe3_top_offset_y = vbp + pipe3_gap_pos_y;
wire [9:0] pipe3_bottom_offset_y = vbp + pipe3_gap_pos_y + pipe_gap_y;

wire is_pipe3_top_black_in_range =
	((hc == pipe3_offset_x) 
		&& ((pipe3_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe3_top_offset_y - 1)))
	|| ((hc == pipe3_offset_x + 1)
		&& ((pipe3_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe3_top_offset_y - 1)))
	|| ((hc == pipe3_offset_x + pipe3_width - 2) 
		&& ((pipe3_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe3_top_offset_y - 1)))
	|| ((hc == pipe3_offset_x + pipe3_width - 1) 
		&& ((pipe3_top_offset_y - (pipe_head_height - 1) <= vc && vc <= pipe3_top_offset_y - 1)))
	|| ((hc == pipe3_offset_x + 2)
		&& ((vbp <= vc && vc <= pipe3_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe3_offset_x + 3) 
		&& ((vbp <= vc && vc <= pipe3_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe3_offset_x + pipe3_width - 4) 
		&& ((vbp <= vc && vc <= pipe3_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((hc == pipe3_offset_x + pipe3_width - 3) 
		&& ((vbp <= vc && vc <= pipe3_top_offset_y - (pipe_head_height + 2 + 2 - 1))))
	|| ((vc == pipe3_top_offset_y - (pipe_head_height + 2 + 2 - 1))
		&& (pipe3_offset_x + 2 <= hc && hc <= pipe3_offset_x + pipe3_width - 1 - 2))
	|| ((vc == pipe3_top_offset_y - (pipe_head_height + 2 + 2 - 1) + 1)
		&& (pipe3_offset_x + 2 <= hc && hc <= pipe3_offset_x + pipe3_width - 1 - 2))
	|| ((vc == pipe3_top_offset_y - 1 - 1)
		&& (pipe3_offset_x <= hc && hc <= pipe3_offset_x + pipe3_width - 1))
	|| ((vc == pipe3_top_offset_y - 1)
		&& (pipe3_offset_x <= hc && hc <= pipe3_offset_x + pipe3_width - 1));

wire is_pipe3_bottom_black_in_range = 
	((hc == pipe3_offset_x) 
		&& (pipe3_bottom_offset_y + 2 <= vc && vc <= pipe3_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe3_offset_x + 1) 
		&& (pipe3_bottom_offset_y + 2 <= vc && vc <= pipe3_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe3_offset_x + pipe3_width - 1) 
		&& (pipe3_bottom_offset_y + 2 <= vc && vc <= pipe3_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe3_offset_x + pipe3_width - 2) 
		&& (pipe3_bottom_offset_y + 2 <= vc && vc <= pipe3_bottom_offset_y + 2 + pipe_head_height))
	|| ((hc == pipe3_offset_x + 2) 
		&& (pipe3_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe3_offset_x + 3) 
		&& (pipe3_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe3_offset_x + pipe3_width - 1 - 2) 
		&& (pipe3_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((hc == pipe3_offset_x + pipe3_width - 1 - 3) 
		&& (pipe3_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp))
	|| ((vc == pipe3_bottom_offset_y) 
		&& (pipe3_offset_x <= hc && hc < pipe3_offset_x + pipe3_width - 1))
	|| ((vc == pipe3_bottom_offset_y + 1) 
		&& (pipe3_offset_x <= hc && hc < pipe3_offset_x + pipe3_width - 1))
	|| ((vc == pipe3_bottom_offset_y + 2 + pipe_head_height) 
		&& (pipe3_offset_x + 2 <= hc && hc < pipe3_offset_x + pipe3_width - 1 - 2))
	|| ((vc == pipe3_bottom_offset_y + 2 + pipe_head_height + 1) 
		&& (pipe3_offset_x + 2 <= hc && hc < pipe3_offset_x + pipe3_width - 1 - 2));

wire is_pipe3_black_in_range = is_pipe3_top_black_in_range | is_pipe3_bottom_black_in_range;

wire is_pipe1_top_green_in_range = 
	((pipe1_offset_x + 2 + 2 <= hc && hc <= pipe1_offset_x + pipe1_width - 1 - 2 - 2)
		&& (vbp <= vc && vc <= pipe1_top_offset_y - 1 - 2 - pipe_head_height - 2))
	|| ((pipe1_offset_x + 2 <= hc && hc <= pipe1_offset_x + pipe1_width - 1 - 2)
		&& (pipe1_top_offset_y - 1 - 2 - pipe_head_height <= vc && vc <= pipe1_top_offset_y - 1 - 2));

wire is_pipe1_bottom_green_in_range =
	((pipe1_offset_x + 2 <= hc && hc <= pipe1_offset_x + pipe1_width - 1 - 2)
		&& (pipe1_bottom_offset_y + 2 <= vc && vc <= pipe1_bottom_offset_y + 2 + pipe_head_height - 1))
	|| ((pipe1_offset_x + 2 + 2 <= hc && hc <= pipe1_offset_x + pipe1_width - 1 - 2 - 2)
		&& (pipe1_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp));

wire is_pipe1_green_in_range = is_pipe1_top_green_in_range | is_pipe1_bottom_green_in_range;



wire is_pipe2_top_green_in_range = 
	((pipe2_offset_x + 2 + 2 <= hc && hc <= pipe2_offset_x + pipe2_width - 1 - 2 - 2)
		&& (vbp <= vc && vc <= pipe2_top_offset_y - 1 - 2 - pipe_head_height - 2))
	|| ((pipe2_offset_x + 2 <= hc && hc <= pipe2_offset_x + pipe2_width - 1 - 2)
		&& (pipe2_top_offset_y - 1 - 2 - pipe_head_height <= vc && vc <= pipe2_top_offset_y - 1 - 2));

wire is_pipe2_bottom_green_in_range =
	((pipe2_offset_x + 2 <= hc && hc <= pipe2_offset_x + pipe2_width - 1 - 2)
		&& (pipe2_bottom_offset_y + 2 <= vc && vc <= pipe2_bottom_offset_y + 2 + pipe_head_height - 1))
	|| ((pipe2_offset_x + 2 + 2 <= hc && hc <= pipe2_offset_x + pipe2_width - 1 - 2 - 2)
		&& (pipe2_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp));

wire is_pipe2_green_in_range = is_pipe2_top_green_in_range | is_pipe2_bottom_green_in_range;



wire is_pipe3_top_green_in_range = 
	((pipe3_offset_x + 2 + 2 <= hc && hc <= pipe3_offset_x + pipe3_width - 1 - 2 - 2)
		&& (vbp <= vc && vc <= pipe3_top_offset_y - 1 - 2 - pipe_head_height - 2))
	|| ((pipe3_offset_x + 2 <= hc && hc <= pipe3_offset_x + pipe3_width - 1 - 2)
		&& (pipe3_top_offset_y - 1 - 2 - pipe_head_height <= vc && vc <= pipe3_top_offset_y - 1 - 2));

wire is_pipe3_bottom_green_in_range =
	((pipe3_offset_x + 2 <= hc && hc <= pipe3_offset_x + pipe3_width - 1 - 2)
		&& (pipe3_bottom_offset_y + 2 <= vc && vc <= pipe3_bottom_offset_y + 2 + pipe_head_height - 1))
	|| ((pipe3_offset_x + 2 + 2 <= hc && hc <= pipe3_offset_x + pipe3_width - 1 - 2 - 2)
		&& (pipe3_bottom_offset_y + 2 + pipe_head_height + 2 <= vc && vc < vfp));

wire is_pipe3_green_in_range = is_pipe3_top_green_in_range | is_pipe3_bottom_green_in_range;


wire is_black_in_range = 
	is_bird_black_in_range 
	| is_pipe1_black_in_range 
	| is_pipe2_black_in_range 
	| is_pipe3_black_in_range;

wire is_green_in_range = 
	is_pipe1_green_in_range 
	| is_pipe2_green_in_range 
	| is_pipe3_green_in_range;

always @(*)
begin
    if (is_black_in_range) begin
        red <= 3'b000;
        green <= 3'b000;
        blue <= 2'b00;
    end
    else if (is_bird_yellow_in_range) begin
    	red <= 3'b111;
        green <= 3'b111;
        blue <= 2'b00;
    end
    else if (is_bird_orange_in_range) begin
    	red <= 3'b111;
        green <= 3'b011;
        blue <= 2'b00;
    end
    else if (is_bird_red_in_range) begin
    	red <= 3'b111;
        green <= 3'b000;
        blue <= 2'b00;
    end
    else if (is_bird_white_in_range) begin
    	red <= 3'b111;
        green <= 3'b111;
        blue <= 2'b11;
    end
    else if (is_green_in_range) begin
        red <= 3'b010;
        green <= 3'b110;
        blue <= 2'b00;
    end
	else if (is_background_in_range) begin
        red <= 3'b010;
        green <= 3'b110;
        blue <= 2'b10;
    end
    else begin
        red <= 0;
        green <= 0;
        blue <= 0;
    end
    

end

endmodule
