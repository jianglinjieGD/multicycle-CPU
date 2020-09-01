`timescale 1ns / 1ps
// moduleName: 
// fileName: 
// Here is a module :  
// fuction : 
//	
module DM(
  input CLK,
	 	input w_dataMem,            	 // 写信号
  input [31:0] rw_addr,            // 读写地址
  input [31:0] in_data,         	 
  output reg [31:0] out_data    	
    );

	// 模拟内存
  reg [7:0] mem[0:63];
	
	integer i;			
	initial
	 begin
   
		for (i = 0; i < 64; i = i + 1)  mem[i] <= 0;
	 end
	

	always@(negedge CLK)
	 begin
     if (w_dataMem)		// 大端模式、 逐个字节写
		 begin
		  mem[rw_addr] <= in_data[31:24];
			mem[rw_addr + 1] <= in_data[23:16];
			mem[rw_addr + 2] <= in_data[15:8];
			mem[rw_addr + 3] <= in_data[7:0];
		 end
		else							// 读 同理
		 begin
		  out_data[31:24] <= mem[rw_addr];
			out_data[23:16] <= mem[rw_addr + 1];
			out_data[15:8] <= mem[rw_addr + 2];
			out_data[7:0] <= mem[rw_addr + 3];
		 end
	 end
	 
endmodule