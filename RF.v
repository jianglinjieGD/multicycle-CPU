`timescale 1ns / 1ps
// moduleName: 	RF
// fileName: 		RF
// Here is a module :  registereadReg_addrA file
// fuction : 
// 1. 随时可读出指定寄存器编号的值
// 2. 在写信号有效下，更新指定寄存器的值
// 3. 不修改0号寄存器，使之保持为0 
//	
module RF(
		input CLK,                       
	 	input w_RF,                  // RF 写信号
  input [4:0] readReg_addrA,                // reg_addr: readReg_addrA
  input [4:0] readReg_addrB,                // reg_addr: readReg_addrB
  input [4:0] writeReg_addr,      // reg_addr: 写地址（寄存器编号）
  input [31:0] writeData,         // 写数据
  output [31:0] out_dataA,        // 读数据A： readReg_addrA
  output [31:0] out_dataB       	// 读数据： readReg_addrB
    );
 reg [31:0] register[0:31];  		// 32个 32位寄存器
	
	integer i;		// 辅助变量，用来遍历
	initial 
	 begin
     // 32个寄存器初始化为0
		for(i = 0; i < 32; i = i + 1)  register[i] <= 0;
	 end

	// A、B两个端口： 读寄存器
	assign out_dataA = register[readReg_addrA];
	assign out_dataB = register[readReg_addrB];

	// 写寄存器
  always@(posedge w_RF, negedge CLK)
	 begin
		// 这里0号寄存器不使用，作为常数 0
		if (w_RF && writeReg_addr != 0)  register[writeReg_addr] = writeData;
	 end 


endmodule