`timescale 1ns / 1ps
// moduleName: ALU
// fileName: ALU
// Here is a module :  Arithmetic and Logic Unit
// fuction : 

// 26bit 字节address， 补全成32bit字节地址
// << 2, 头部使用PC的头部
// jar命令的含义： PC = (PC+4)[31:28]||target||'00'


module PCJUMP(
  	input [31:0] PC4,          // 指令
    input [25:0] in_addr,    // 输入地址
    output [31:0] out_addr   // 输出地址(指令)
    );

  // out_addr = PC[31:28] + in_addr + 00
  // 这里用<= 会不会好一点
  	assign out_addr[31:28] = PC4[31:28];
    assign out_addr[27:2] = in_addr;
    assign out_addr[1:0] = 2'b00;

endmodule
