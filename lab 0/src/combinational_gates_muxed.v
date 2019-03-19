/*
 * Module: Multiplexed combinational gates
 * 
 * Filename: combinational_gates_muxed.v
 * Version: 1.0
 *
 * Author: Cejo Konuparamban Lonappan
 *
 * Description: RTL for implementing eight combinational gates with the 
 * outputs of the gates multiplexed using an 8:1 Multiplexer. The gates
 * implemented are NAND, AND, NOR, OR, XOR, XNOR, NOT, and a non-inverting
 * buffer. 
 */

// put both input and output in arguments
module combinational_gates_muxed (led, sw);

// Input and output declaration
// Input and output are wire by default
input  [4:0] sw;  // Inputs sw[4:2] are unused. [most significant bit : least siginificant bit]
// Contrary to their name, regs don't necessarily correspond to
// physical registers. They represent data storage elements in
// Verilog/SystemVerilog.
output reg led; // Outputs led[7:1] are unused. led is 1 bit

// Wires are used for connecting different elements. They can be treated
// as physical wires. They can be read or assigned. No values get stored
// in them. They need to be driven by either continuous assign statement
// or from a port of a module.
// 
// Declaring wires for the eight two inpuit basic gates	
//                Output Select Input Number
wire nand_out;    // 3'b111 // if you do not specify the number of bits,
wire  and_out;    // 3'b110 // it is 1 bit by default
wire  nor_out;    // 3'b101
wire   or_out;    // 3'b100
wire  xor_out;    // 3'b011
wire xnor_out;    // 3'b010
wire buff_out;    // 3'b001
wire  not_out;    // 3'b000

wire [7:0] MuxIn;     // MuxIn takes 8 inputs
wire [2:0] SelectIn;  // use 3 bit to select which MuxIn input to output. 2^3 = 8.

// Generate outputs for the eight gates
// sw's are defined in ucf file
// sw represents switch
// use the keyword 'assign' to assign value to wire type
assign nand_out = ~(sw[0] & sw[1]); // 3'b000 // ~ is NOT
assign  and_out =   sw[0] & sw[1];  // 3'b001
assign  nor_out = ~(sw[0] | sw[1]); // 3'b010
assign   or_out =   sw[0] | sw[1];  // 3'b011
assign  xor_out =   sw[0] ^ sw[1];  // 3'b100 // ^ is XOR
assign xnor_out =   sw[0] ^~ sw[1]; // 3'b101
assign buff_out =    sw[0];         // 3'b110
assign  not_out =   ~sw[0];         // 3'b111

//                    3'b111 3'b110   3'b101   3'b100    3'b011   3'b010  3'b001   3'b000
assign MuxIn 	= {not_out, buff_out, xnor_out, xor_out, or_out, nor_out, and_out, nand_out};

// Assigning select input lines for the multiplexer using switch lines SW7, SW6, and SW5
assign SelectIn = sw[4:2];

// what is always block?
// usually assign values to reg type in always block
// With always block, we can tell the program
// when to assign values to reg type variables.
// For example, 
//
//always @(posedge CLK) begin
//    a <= 0; //assign 0 to a when there is a positve clock edge
//end
//
// "begin" and "end" above are like {} in C++ 
// Output multiplexer
//
// the stuff after @ is called sensitive list.
//	
// The sensitive list is the one which tells the always block 
// when to execute the block of code, as shown in the figure below. 
// The @ symbol after reserved word ' always', 
// indicates that the block will be triggered "at" the condition in parenthesis 
// after symbol @
//
// The code inside always block will be executed 
// whenever the values in sensitive list change
always @(MuxIn, SelectIn)
	led = MuxIn[SelectIn]; 

endmodule // nexys3
