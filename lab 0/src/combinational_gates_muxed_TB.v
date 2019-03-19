/*
 * Module: Testbench for multiplexed combinational gates
 * 
 * Filename: combinational_gates_muxed_TB.v
 * Version: 1.0
 *
 * Author: Cejo Konuparamban Lonappan
 *
 * Description: The testbench code for verifying the multiplexed outputs of
 * eight comnibational gates. 
 */

// The timescale directive specifies the default time unit used for the simulation.
`timescale 1ns / 1ps

module combinational_gates_muxed_tb; // No inputs for a testbench!

// Inputs in the module to be tested will be port mapped to register variables
reg [4:0] sw_T;

// Outputs in the module to be tested will be port mapped to wire variables
wire led_T;

// Instantiation of the design module to be verified by the testbench
// Use named portmapping to map inputs to regsiter variables and outputs to
// wires
// UUT stands for Unit Under Test
// UUT is just a module name here. You can change it.
// use . to specify which argument we want to pass the value into
combinational_gates_muxed UUT(.sw(sw_T), .led(led_T));

// Used for saving Value Change Dump (.vcd) file that records the waveforms of
// the simulation. Not needed while using Xilinx ISIM simulator.
// The inital block is used similarly to an always block 
// except that the code in the block will only run once, 
// at the start of the simulation. Because there is no equivalent 
// to an initial block in hardware, initial blocks are not synthesizable 
// and can only be used in test benches.
initial
begin
        $dumpfile("combinational_gates_muxed.vcd");
        $dumpvars(2, combinational_gates_muxed_tb.UUT);
end

// IMPORTANT: Initialize all inputs. Otherwise the default value of register
// will be don't care (x).
initial
begin
	sw_T = 5'h0;
end

// Use an always block to generate all the test cases
// # 5 means to wait 5 time units
always
	#5 sw_T = sw_T + 1'b1;

// Code to terminate simulation after all the test cases have been covered.
initial
	#160 $finish; // After 160 timeunits, terminate simulation.

endmodule
