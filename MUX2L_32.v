`timescale 1ns / 1ps
// moduleName: MUX2L_32
module MUX2L_32(
	  input slc,
    input [31:0] in_0,
    input [31:0] in_1,
    output [31:0] out_0
    );

	assign out_0 = slc ? in_1 : in_0;
	
endmodule