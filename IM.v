`timescale 1ns / 1ps
// moduleName: IM
// fileName: IM
// Here is a module :  Instruction Memory 
// fuction : 根据给的地址，输出存储器上的 32位指令
// 这里是使用reg来模拟存储器， 所以使用8位reg[7:0]
//	
module IM(
	input [31:0] read_addr,					// 读地址 	
	// 以下 IR = op,rs,rt,rd,sa,func
  // 为了方便，分成了几部分而不以一个IR整体存在
  // 由于指令类型的不同
  // I类型的： imediate = rd,sa,func
  // J类型的： address = rs,rt,rd,sa,func
  output reg[5:0] op,
  output reg[4:0] rs,
  output reg[4:0] rt,
  output reg[4:0] rd,
  output reg[4:0] sa,
  output reg[5:0] func 
	);
	 
	reg[7:0] mem[0:63];  						// 存储器模拟，64字节
  // wire [15:0] immediate;
  // assign immediate = {rs,sa,func};
	initial 
	 begin
     {mem[0], mem[1], mem[2], mem[3]} = 32'h30010001;      //1
	   {mem[4], mem[5], mem[6], mem[7]} = 32'h00201020;      //2
	   {mem[8], mem[9], mem[10], mem[11]} = 32'h00401821;    //3
	   {mem[12], mem[13], mem[14], mem[15]} = 32'h00622024;  //4
	   {mem[16], mem[17], mem[18], mem[19]} = 32'h00832825;  //5
	   {mem[20], mem[21], mem[22], mem[23]} = 32'h00A4300B;   //6
	   {mem[24], mem[25], mem[26], mem[27]} = 32'h00A4380A;           //7
	   {mem[28], mem[29], mem[30], mem[31]} = 32'h00E6402A;           //8
	   {mem[32], mem[33], mem[34], mem[35]} = 32'h01004880;           //9
	   {mem[36], mem[37], mem[38], mem[39]} = 32'h350A0002;           //10
	   {mem[40], mem[41], mem[42], mem[43]} = 32'hAC020000;           //11
	   {mem[44], mem[45], mem[46], mem[47]} = 32'h8C0B0000;           //12
	   {mem[48], mem[49], mem[50], mem[51]} = 32'h10000001;           //13
	   {mem[52], mem[53], mem[54], mem[55]} = 32'h300C000C;           //14
	   {mem[56], mem[57], mem[58], mem[59]} = 32'h300C000F;           //15
	   {mem[60], mem[61], mem[62], mem[63]} = 32'h08000012;           //16
	   {mem[64], mem[65], mem[66], mem[67]} = 32'h300C0005;           //17
	   {mem[68], mem[69], mem[70], mem[71]} = 32'h03E00008;           //18
	   {mem[72], mem[73], mem[74], mem[75]} = 32'h0C000010;           //19
	   {mem[76], mem[77], mem[78], mem[79]} = 32'h300C0014;           //20
	   {mem[80], mem[81], mem[82], mem[83]} = 32'h300C0015;           //21
		// 初始化为0
		op <= 0;
		rs <= 0;
		rt <= 0;
		rd <= 0;
		sa <= 0;
		func <= 0;
		// 读文件（测试使用的指令放在文件中）
     $readmemb("./test/test.txt", mem); 
	 end

	// fetch the instruction to IR
  always@(* )
	 begin
		 begin
		 	// 一个字节一个字节的赋值  大端模式（高位在低地址）
			op <= mem[read_addr][7:2];
      rs <= {mem[read_addr][1:0], mem[read_addr + 1][7:5]};
      rt <= mem[read_addr+1][4:0];
			rd <= mem[read_addr+2][7:3];
      sa <= {mem[read_addr+2][2:0], mem[read_addr+3][7:6]};
      func <= mem[read_addr+3][5:0];	
		 end
	 end

endmodule

