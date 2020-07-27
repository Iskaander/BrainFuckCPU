`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Aleksander Kaminski
// 
// Create Date:    04:23:50 07/08/2014 
// Design Name:		Braindfuck CPU
// Module Name:    brainfuck_cpu_tb 
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
module brainfuck_cpu_tb();

	reg clk;
	reg rst;
	wire [3:0] led;
	wire uart_out;

	brainfuck_main DUT(clk, rst, led, uart_out);
	
	initial begin
        //$dumpfile("dump.vcd");
        //$dumpvars(0, DUT);
        #100000000;
        $stop;
    end
	
	initial begin
		rst <= 1'b0;
		clk <= 1'b0;
		#100 rst <= 1'b1;
	end
	
	always begin
		#1 clk <= ~clk;
	end

endmodule
