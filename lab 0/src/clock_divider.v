`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:36:03 01/16/2019 
// Design Name: 
// Module Name:    clock_divider 
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
module clock_divider(clk, led, btns);
// 100000 kHz (1s = 100_000_000 cycles)
input clk;
input btns;
output reg led;

reg [26:0] a;

always @ (posedge clk)
begin
    if (btns == 1 || a == 'd100_000_000)
    begin
        a = 'd0;
    end
    else if (a > 'd50_000_000)
    begin
        led = 1;
        a = a + 'b1;
    end
    else
        begin
        a = a + 'b1;
        led = 0;
    end
       
end

endmodule
