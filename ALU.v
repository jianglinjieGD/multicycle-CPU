`timescale 1ns / 1ps
// moduleName: ALU
// fileName: ALU
// Here is a module :  Arithmetic and Logic Unit
// fuction : 

module ALU(
  input [3:0] op_ALU,           // ALU操作码，决定操作类型
  input [31:0] src_A,        	  // 源操作数A
  input [31:0] src_B,           // 源操作数B
    output reg zero,            // 0标志
  output reg[31:0] result       // 结果
    );

  // 初始化 0标志
	initial 
	 begin
		zero <= 0;
	 end


	always@(*)
	 begin
		case (op_ALU)
			4'b0000 :  result <= src_A + src_B;             // 加
			4'b0001 :  result <= src_A - src_B;             // -
      4'b0010 :  result <= (src_A < src_B) ? 1 : 0;   // A < B ?
			4'b0011 :  result <= src_A >> src_B;            // A 右移 B 位
			4'b0100 :  result <= src_A << src_B;            // A 左移 B 位
			4'b0101 :  result <= src_A | src_B;             // A 按位或 B
			4'b0110 :  result <= src_A & src_B;             // A 按位与 B
			4'b0111 :  result <= src_A ^ src_B;             // A 异或 B
      4'b1000 :  result <= src_B;											// for movn, movz
        																							// rt 自然判是否为0
        					
      4'b1001 :  result <= src_A + 4;									// jal addr放到$31的地址值
      
      
      default: result <= result;	// do nothing
		endcase
	 
		// 0标志
		if (result)  zero = 0;
		else  zero = 1;
	 end

endmodule