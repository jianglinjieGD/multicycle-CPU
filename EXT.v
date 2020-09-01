`timescale 1ns / 1ps
// moduleName: EXT
// fileName: EXT
// Here is a module :  EXT
// fuction : 
//	
module EXT(
  input [1:0]op_ext,              // 决定拓展类型的操作码
  input [15:0] src_immed,         // 要拓展的原数据
  output [31:0] new_immed   			// 拓展后的数据
    );
	// 低位 
  // 00： zero-extend： sll： 移位的位数是指令中sa段（[10:6]）指定的
  // 所以是 [4:0] = [10:6], 其他补0
  // 除了是拓展sa段以外，其他的被拓展数都是在[15:0],所以保持低位即可
  assign new_immed[4:0] = (op_ext == 2'b00) ? src_immed[10:6] : src_immed[4:0];
  assign new_immed[15:5] = (op_ext == 2'b00) ? 11'b00000000000 : src_immed[15:5];
	
  // 高位： （零拓展）无符号补0， （符号拓展）有符号补符号
	assign new_immed[31:16] = (op_ext == 2'b10) ? (src_immed[15] ? 16'hffff : 16'h0000) : 16'h0000;

endmodule