`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
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
module NERP_demo_top(
	input wire clk,			//master clock = 50MHz
	input wire clr,			//right-most pushbutton for reset
	input wire btn,         //middle pushbutton for jump
    input wire sw,
    input wire mode,
	output wire [6:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// 7-segment clock interconnect
wire segclk;

// VGA display clock interconnect
wire dclk;

// disable the 7-segment decimal points
assign dp = 1;

// jump button debouncer
wire jump;

// clk manager
wire clk_bird;
wire clk_pipe;
wire clk_moving_pipe;

// screen info
wire [9:0] screen_width;
wire [8:0] screen_height;

// const bird parameter
parameter bird_width = 35;
parameter bird_height = 25;
parameter bird_start_pos_x = 135;
parameter bird_start_pos_y = 215;
parameter bird_jump_power = 1;

// const pipe parameter
parameter pipe_start_width = 45;
parameter pipe_gap_y = 100;
parameter pipe_gap_x = (640 - pipe_start_width - pipe_start_width) / 3;
parameter pipe_start_pos_x = 350;

// pipe1 variables
reg [9:0] pipe1_pos_x = pipe_start_pos_x;
reg [5:0] pipe1_width = pipe_start_width;
reg [8:0] pipe1_gap_pos_y = 300;

// pipe2 variables
reg [9:0] pipe2_pos_x = pipe_start_pos_x + pipe_start_width + pipe_gap_x;
reg [5:0] pipe2_width = pipe_start_width;
reg [8:0] pipe2_gap_pos_y = 300;

// pipe3 variables
reg [9:0] pipe3_pos_x = (pipe_start_pos_x + pipe_start_width + pipe_gap_x) + pipe_start_width + pipe_gap_x;
reg [5:0] pipe3_width = pipe_start_width;
reg [8:0] pipe3_gap_pos_y = 300;

// bird varialbles
reg [8:0] bird_pos_y = bird_start_pos_y;
reg [9:0] bird_pos_x = bird_start_pos_x;

// game state
wire isDone;

// random number generator
wire [9:0] random1;
wire [9:0] random2;
wire [9:0] random3;

// collision flags
wire is_bird_overlap;
wire is_bird_on_ground;
wire is_bird_on_ceiling;

// scores [score3, score2, score1]
wire [3:0] score1;
wire [3:0] score2;
wire [3:0] score3;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.segclk(segclk),
	.dclk(dclk)
	);

// 7-segment display controller
segdisplay U2(
	.segclk(segclk),
	.clr(clr),
	.score1(score1),
	.score2(score2),
	.score3(score3),
	.score4(score4),
	.seg(seg),
	.an(an)
	);

// VGA controller
vga640x480 U3(
	.dclk(dclk),
	.clr(clr),
	.bird_pos_x(bird_pos_x),
	.bird_pos_y(bird_pos_y),
	.bird_width(bird_width),
	.bird_height(bird_height),
	.pipe_gap_y(pipe_gap_y),
	.pipe1_pos_x(pipe1_pos_x),
	.pipe1_gap_pos_y(pipe1_gap_pos_y),
	.pipe1_width(pipe1_width),
	.pipe2_pos_x(pipe2_pos_x),
	.pipe2_gap_pos_y(pipe2_gap_pos_y),
	.pipe2_width(pipe2_width),
	.pipe3_pos_x(pipe3_pos_x),
	.pipe3_gap_pos_y(pipe3_gap_pos_y),
	.pipe3_width(pipe3_width),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue),
	.screen_width(screen_width),
	.screen_height(screen_height)
	);

// debouncer for btn
debouncer U4(
	.clk(clk),
	.clr(clr),
	.btn(btn),
	.jump(jump)
	);

clock_manager U5(
	.clk(clk),
	.clr(clr),
	.clk_bird(clk_bird),
	.clk_pipe(clk_pipe),
    .clk_moving_pipe(clk_moving_pipe)
	);
	
random U6(
	.clk(clk),
	.clr(clr),
	.screen_height(screen_height),
	.pipe_gap_y(pipe_gap_y),
	.random1(random1),
	.random2(random2),
	.random3(random3)
);

collision_detection U7(
	.clk(clk),
	.clr(clr),
	.bird_pos_x(bird_pos_x),
	.bird_pos_y(bird_pos_y),
	.bird_width(bird_width),
	.bird_height(bird_height),
	.pipe_gap_y(pipe_gap_y),
	.pipe1_pos_x(pipe1_pos_x),
	.pipe1_gap_pos_y(pipe1_gap_pos_y),
	.pipe1_width(pipe1_width),
	.pipe2_pos_x(pipe2_pos_x),
	.pipe2_gap_pos_y(pipe2_gap_pos_y),
	.pipe2_width(pipe2_width),
	.pipe3_pos_x(pipe3_pos_x),
	.pipe3_gap_pos_y(pipe3_gap_pos_y),
	.pipe3_width(pipe2_width),
	.screen_height(screen_height),
	.is_bird_on_ground(is_bird_on_ground),
	.is_bird_overlap(is_bird_overlap),
    .is_bird_on_ceiling(is_bird_on_ceiling)
	);
	
gamestate_manager U8(
	.clk(clk),
	.clr(clr),
	.is_bird_on_ground(is_bird_on_ground),
	.is_bird_overlap(is_bird_overlap),
    .is_bird_on_ceiling(is_bird_on_ceiling),
	.isDone(isDone)
	);

score_manager U9(
	.clk(clk),
	.clr(clr),
	.bird_pos_x(bird_pos_x),
	.pipe1_pos_x(pipe1_pos_x),
	.pipe1_width(pipe1_width),
	.pipe2_pos_x(pipe2_pos_x),
	.pipe2_width(pipe2_width),
	.pipe3_pos_x(pipe3_pos_x),
	.pipe3_width(pipe3_width),
	.isDone(isDone),
	.score1(score1),
	.score2(score2),
	.score3(score3)
	);
    	
// =================================================
// update object positions
// =================================================

wire is_pipe1_out_of_bounds = pipe1_pos_x == 0;
wire is_pipe1_width_out_of_bounds = pipe1_width == 0;

wire is_pipe2_out_of_bounds = pipe2_pos_x == 0;
wire is_pipe2_width_out_of_bounds = pipe2_width == 0;

wire is_pipe3_out_of_bounds = pipe3_pos_x == 0;
wire is_pipe3_width_out_of_bounds = pipe3_width == 0;

reg is_pipe1_moving_up = 1;
reg is_pipe2_moving_up = 0;
reg is_pipe3_moving_up = 1;

always @ (posedge clk or posedge clr) begin
    if (clr) begin
        is_pipe1_moving_up <= 1;
        is_pipe2_moving_up <= 0;
        is_pipe3_moving_up <= 1;
    end
    else begin
        if (pipe1_gap_pos_y == 0)
            is_pipe1_moving_up <= 0;
        else if (pipe1_gap_pos_y + pipe_gap_y == screen_height)
            is_pipe1_moving_up <= 1;
        
        if (pipe2_gap_pos_y == 0)
            is_pipe2_moving_up <= 0;
        else if (pipe2_gap_pos_y + pipe_gap_y == screen_height)
            is_pipe2_moving_up <= 1;
            
        if (pipe3_gap_pos_y == 0)
            is_pipe3_moving_up <= 0;
        else if (pipe3_gap_pos_y + pipe_gap_y == screen_height)
            is_pipe3_moving_up <= 1;
            
    end
end

always @ (posedge clk or posedge clr) begin
	
	if (clr) begin
		bird_pos_y <= bird_start_pos_y;
        pipe1_pos_x <= pipe_start_pos_x;
        pipe1_width <= pipe_start_width;
        pipe1_gap_pos_y <= random1;
        pipe2_pos_x <= pipe1_pos_x + pipe_start_width + pipe_gap_x;
        pipe2_width <= pipe_start_width;
        pipe2_gap_pos_y <= random2;
		pipe3_pos_x <= pipe2_pos_x + pipe_start_width + pipe_gap_x;
        pipe3_width <= pipe_start_width;
        pipe3_gap_pos_y <= random3;
	end
	else if (~isDone) begin

		// =================================================
		// update bird position
		// =================================================
        if (clk_bird) begin
            if (sw | jump) begin
                if (bird_pos_y - bird_jump_power >= 0) begin
                    bird_pos_y <= bird_pos_y - bird_jump_power;
                end
                else begin
                    bird_pos_y <= 0;
                end
            end
            else begin
                bird_pos_y <= bird_pos_y + 1;
            end
        end
		
        
        // =================================================
		// update pipe position
		// =================================================
        if (clk_pipe) begin
            
            
            if (is_pipe1_out_of_bounds) begin
                if (is_pipe1_width_out_of_bounds) begin
                    pipe1_width <= pipe_start_width;
                    pipe1_gap_pos_y <= random1;
                    pipe1_pos_x <= screen_width;
                end
                else begin
                    pipe1_width <= pipe1_width - 1;
                        if (mode) begin
                            if (is_pipe1_moving_up)
                                pipe1_gap_pos_y <= pipe1_gap_pos_y - 1;
                            else
                                pipe1_gap_pos_y <= pipe1_gap_pos_y + 1;
                        end
                        
                    
                end  
            end
            else begin
                pipe1_pos_x <= pipe1_pos_x - 1;
                    if (mode) begin
                        if (is_pipe1_moving_up)
                            pipe1_gap_pos_y <= pipe1_gap_pos_y - 1;
                        else
                            pipe1_gap_pos_y <= pipe1_gap_pos_y + 1;
                    end
                    
                
            end     

            if (is_pipe2_out_of_bounds) begin
                if (is_pipe2_width_out_of_bounds) begin
                    pipe2_width <= pipe_start_width;
                    pipe2_gap_pos_y <= random2;
                    pipe2_pos_x <= screen_width;
                    
                end
                else begin
                    pipe2_width <= pipe2_width - 1;
                        if (mode) begin
                            if (is_pipe2_moving_up)
                                pipe2_gap_pos_y <= pipe2_gap_pos_y - 1;
                            else
                                pipe2_gap_pos_y <= pipe2_gap_pos_y + 1;
                        end
                        
                    
                end  
            end
            else begin
                pipe2_pos_x <= pipe2_pos_x - 1;
                    if (mode) begin
                        if (is_pipe2_moving_up)
                            pipe2_gap_pos_y <= pipe2_gap_pos_y - 1;
                        else
                            pipe2_gap_pos_y <= pipe2_gap_pos_y + 1;
                    end
                    
                
            end
				
				if (is_pipe3_out_of_bounds) begin
                if (is_pipe3_width_out_of_bounds) begin
                    pipe3_width <= pipe_start_width;
                    pipe3_gap_pos_y <= random3;
                    pipe3_pos_x <= screen_width;
                    
                end
                else begin
                    pipe3_width <= pipe3_width - 1;
                        if (mode) begin
                            if (is_pipe3_moving_up)
                                pipe3_gap_pos_y <= pipe3_gap_pos_y - 1;
                            else
                                pipe3_gap_pos_y <= pipe3_gap_pos_y + 1;
                        end
                        
                    
                end  
            end
            else begin
                pipe3_pos_x <= pipe3_pos_x - 1;
                    if (mode) begin
                        if (is_pipe3_moving_up)
                            pipe3_gap_pos_y <= pipe3_gap_pos_y - 1;
                        else
                            pipe3_gap_pos_y <= pipe3_gap_pos_y + 1;
                    end
                    
                
            end 

				
        end // pipe clock
        
		  
	end // else if ~isDone
end //always

endmodule
