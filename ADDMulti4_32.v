`timescale 1ns / 1ps
// moduleName: ADDMulti4_32
// fileName: ADDMulti4_32
// Here is a module : 
// ADDMulti4_32  默认把B左移2位后再加，专为跳转的PC加法  
// fuction : +

module ADDMulti4_32(
    input [31:0] A,
    input [31:0] B,
    output [31:0] out
    );
	
	// A + B
  assign out = A + (B << 2);
	
endmodule