`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:15:25 01/16/2019 
// Design Name: 
// Module Name:    fout_bit_counter 
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
module fout_bit_counter(a, rst, clk);

input rst;
input clk;
output reg [3:0] a;

always @ (posedge clk)
begin
    if (rst)
        a <= 'b0000;
    else
        a <= a + 'b1;
end

endmodule
