`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:56 03/19/2013 
// Design Name: 
// Module Name:    segdisplay 
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
module segdisplay(
	input wire segclk,		//7-segment clock
	input wire clr,			//asynchronous reset
	input wire [3:0] score1,
	input wire [3:0] score2,
	input wire [3:0] score3,
	input wire [3:0] score4,
	output reg [6:0] seg,	//7-segment display LEDs
	output reg [3:0] an		//7-segment display anode enable
	);

// constants for displaying digits on display
parameter D0 = 'b1000000;
parameter D1 = 'b1111001;
parameter D2 = 'b0100100;
parameter D3 = 'b0110000;
parameter D4 = 'b0011001;
parameter D5 = 'b0010010;
parameter D6 = 'b0000010;
parameter D7 = 'b1111000;
parameter D8 = 'b0000000;
parameter D9 = 'b0010000;
parameter D_default = 'b1111111;

// seg_scores
wire [7:0] seg_score1 = 
	(score1 == 0) ? D0 : 
	(score1 == 1) ? D1 : 
	(score1 == 2) ? D2 : 
	(score1 == 3) ? D3 : 
	(score1 == 4) ? D4 :
	(score1 == 5) ? D5 :
	(score1 == 6) ? D6 :
	(score1 == 7) ? D7 :
	(score1 == 8) ? D8 :
	(score1 == 9) ? D9 : D_default;

wire [7:0] seg_score2 = 
	(score2 == 0) ? D0 : 
	(score2 == 1) ? D1 : 
	(score2 == 2) ? D2 : 
	(score2 == 3) ? D3 : 
	(score2 == 4) ? D4 :
	(score2 == 5) ? D5 :
	(score2 == 6) ? D6 :
	(score2 == 7) ? D7 :
	(score2 == 8) ? D8 :
	(score2 == 9) ? D9 : D_default;

wire [7:0] seg_score3 = 
	(score3 == 0) ? D0 : 
	(score3 == 1) ? D1 : 
	(score3 == 2) ? D2 : 
	(score3 == 3) ? D3 : 
	(score3 == 4) ? D4 :
	(score3 == 5) ? D5 :
	(score3 == 6) ? D6 :
	(score3 == 7) ? D7 :
	(score3 == 8) ? D8 :
	(score3 == 9) ? D9 : D_default;

wire [7:0] seg_score4 = 
	(score4 == 0) ? D0 : 
	(score4 == 1) ? D1 : 
	(score4 == 2) ? D2 : 
	(score4 == 3) ? D3 : 
	(score4 == 4) ? D4 :
	(score4 == 5) ? D5 :
	(score4 == 6) ? D6 :
	(score4 == 7) ? D7 :
	(score4 == 8) ? D8 :
	(score4 == 9) ? D9 : D_default;


// Finite State Machine (FSM) states
parameter left = 2'b00;
parameter midleft = 2'b01;
parameter midright = 2'b10;
parameter right = 2'b11;

// state register
reg [1:0] state;

// FSM which cycles though every digit of the display every 2.62ms.
// This should be fast enough to trick our eyes into seeing that
// all four digits are on display at the same time.
always @(posedge segclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		seg <= D_default;
		an <= 4'b1111;
		state <= left;
	end
	// display the character for the current position
	// and then move to the next state
	else
	begin

		case(state)
			left: 
            begin
                seg <= 'b11111111;
				an <= 4'b0111;
				state <= midleft;
			end
			midleft:
			begin
				  casex (score3)
               'd0: seg <= 'b11000000;
               'd1: seg <= 'b11111001;
               'd2: seg <= 'b10100100;
               'd3: seg <= 'b10110000;
               'd4: seg <= 'b10011001;
               'd5: seg <= 'b10010010;
               'd6: seg <= 'b10000010;
               'd7: seg <= 'b11111000;
               'd8: seg <= 'b10000000;
               'd9: seg <= 'b10010000;
               default: seg <= 'b11111111;
            endcase
				an <= 4'b1011;
				state <= midright;
			end
			midright:
			begin
              casex (score2)
               'd0: seg <= 'b11000000;
               'd1: seg <= 'b11111001;
               'd2: seg <= 'b10100100;
               'd3: seg <= 'b10110000;
               'd4: seg <= 'b10011001;
               'd5: seg <= 'b10010010;
               'd6: seg <= 'b10000010;
               'd7: seg <= 'b11111000;
               'd8: seg <= 'b10000000;
               'd9: seg <= 'b10010000;
               default: seg <= 'b11111111;
            endcase
				an <= 4'b1101;
				state <= right;
			end
			right:
			begin
				 casex (score1)
               'd0: seg <= 'b11000000;
               'd1: seg <= 'b11111001;
               'd2: seg <= 'b10100100;
               'd3: seg <= 'b10110000;
               'd4: seg <= 'b10011001;
               'd5: seg <= 'b10010010;
               'd6: seg <= 'b10000010;
               'd7: seg <= 'b11111000;
               'd8: seg <= 'b10000000;
               'd9: seg <= 'b10010000;
               default: seg <= 'b11111111;
            endcase
				an <= 4'b1110;
				state <= left;
			end
		endcase
	end
end

endmodule
