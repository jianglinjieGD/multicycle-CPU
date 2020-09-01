`timescale 1ns / 1ps
// moduleName: ADD4_32
// fileName: ADD4_32
// Here is a module : ADD4_32  
// fuction : 专门为pc+4

module ADD4_32(
  input [31:0] pc_before,
    // input [31:0] B,
  output [31:0] pc_new
    );
	
	// pc_before + 4
	assign pc_new = pc_before + 4;
	
endmodule	