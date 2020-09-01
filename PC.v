`timescale 1ns / 1ps
// moduleName: PC
// fileName: PC
// Here is a module :  program counter
// fuction : 
//	1. w_pc == 1下， 在clk上沿更新pc
//	2. reset == 1下，重置pc 为 0

module PC(
    input CLK,								 // 
    input reset,               // 
    input w_pc,                // pc 写信号
  input [31:0] in_addr,        // pc输入地址，新地址
  output reg[31:0] out_addr    // pc输出地址，当前地址
    );

	initial begin
    out_addr <= 0;  					// 初始为 0
	end
	
	always@(posedge CLK or posedge reset)
	 begin
		if (reset == 1)  
      out_addr <= 0;  				// 重置为 0 
		else 
		 begin
			if (w_pc)  
        out_addr <= in_addr;	// 更新pc
			else  
        out_addr <= out_addr;	// 不变
		 end
	 end 
endmodule
