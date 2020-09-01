`timescale 1ns / 1ps
// moduleName: MUX4L_5
module MUX4L_5(
	 input [1:0] slc,
   input [4:0] in_0,
   input [4:0] in_1,
	 input [4:0] in_2,
	 input [4:0] in_3,
   output [4:0] out_0
    );

	assign out_0 = slc[0] ? (slc[1] ? in_3 : in_1) : (slc[1] ? in_2 : in_0);
endmodule