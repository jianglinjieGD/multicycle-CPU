`timescale 1ns / 1ps
module multicycle_CPU(
    input CLK,
    input reset
    );
    
  wire[31:0] out_data; // DM
  wire[31:0] out_ADDMulti4_32;	 //ADDMulti4_32
  wire[31:0] out_pcSrc;			// pcSrc 4路选择器输出
  wire [4:0] out_RFWriteAddr;		// RFWriteAddr 
  wire[31:0] result, out_RFWriteData;       // ALU结果
wire zero;                   // ALU结果 0标志
// CU信号
wire w_pc, slc_ALUB, slc_ALUA, w_RF, w_dataMem;
wire[1:0] op_ext, slc_pcSrc, slc_RFWriteAddr, slc_RFWriteData;
wire[3:0] op_ALU;
wire[31:0] pc_new; // ADD4_32, out

  // 信号线的名字 = 信号来源名字


  /*
  module PC(
    input CLK,								 // 
    input reset,               // 
    input w_pc,                // pc 写信号
  input [31:0] in_addr,        // pc输入地址，新地址
  output reg[31:0] out_addr    // pc输出地址，当前地址
    );
  */
  // from PC
  wire[31:0] out_addr_pc;
  PC PC_case(.CLK(CLK), .reset(reset), .w_pc(w_pc), .in_addr(out_pcSrc),
             .out_addr(out_addr_pc) );
  
  /*
  module IM(
	input [31:0] read_addr,					// 读地址 	
  // I类型的： imediate = rd,sa,func
  // J类型的： address = rs,rt,rd,sa,func
  output reg[5:0] op,
  output reg[4:0] rs, rt, rd, sa,
  ouptut reg[5:0] func
	);
  */
  //from IM
  wire[5:0] op, func;
  wire[4:0] rs, rt, rd, sa;
  IM IM_case (.read_addr(out_addr_pc), 
              .op(op), .rs(rs), .rt(rt), .rd(rd), .sa(sa), .func(func));
  
  /*
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
  */
  // from RF
  wire[31:0] out_dataA, out_dataB;

  RF RF_case (.CLK(CLK), .w_RF(w_RF), .readReg_addrA(rs), 
              .readReg_addrB(rt),.writeReg_addr(out_RFWriteAddr),.writeData(out_RFWriteData), 
              .out_dataA(out_dataA), .out_dataB(out_dataB));
  
  
  /*
  module EXT(
  input [1:0]op_ext,              // 决定拓展类型的操作码
  input [15:0] src_immed,         // 要拓展的原数据
  output [31:0] new_immed   			// 拓展后的数据
    );
  */
  // from EXT
  wire[31:0] new_immed;
  EXT EXT_case (.op_ext(op_ext), .src_immed({rd,sa,func}), 
                .new_immed(new_immed));
 
  /*
  module PCJUMP(
    input [31:0] PC4,        // 指令
    input [25:0] in_addr,    // 输入地址
    output [31:0] out_addr   // 输出地址(指令)
    );
  */
  // from PCJUMP (pc+4)[31:28],addr,00
  wire[31:0] out_addr;
  PCJUMP PCJUMP_case (.PC4(pc_new), .in_addr({rs,rt,rd,sa,func}), 
                      .out_addr(out_addr));
 	/*
  module ADD4_32(
  input [31:0] pc_before,
    // input [31:0] B,
  output [31:0] pc_new
    );
    // 专为pc+4
  */
  // from ADD4_32 

  ADD4_32 ADD4_32_case (.pc_before(out_addr_pc), 
                        .pc_new(pc_new));
  
  
  /*
module MUX2L_32(
	  input slc,
    input [31:0] in_0,
    input [31:0] in_1,
    output [31:0] out_0
    );
  */
  wire[31:0] out_slc_ALUA, out_slc_ALUB;
  MUX2L_32 MUX2L_32_ALUA (.slc(slc_ALUA), .in_0(pc_new), .in_1(out_dataA),
                          .out_0(out_slc_ALUA));
  MUX2L_32 MUX2L_32_ALUB (.slc(slc_ALUB), .in_0(out_dataB), .in_1(new_immed),
                          .out_0(out_slc_ALUB));
  MUX2L_32 MUX2L_32_RFWriteData (.slc(slc_RFWriteData), .in_0(result), .in_1(out_data),
                                 .out_0(out_RFWriteData));
  
  /*
  module ALU(
  input [3:0] op_ALU,           // ALU操作码，决定操作类型
  input [31:0] src_A,        	  // 源操作数A
  input [31:0] src_B,           // 源操作数B
    output reg zero,            // 0标志
  output reg[31:0] result       // 结果
    );
  */
  ALU ALU_case (.op_ALU(op_ALU), .src_A(out_slc_ALUA), 
                .src_B(out_slc_ALUB), 
                .zero(zero), .result(result));
  
  /*
  module DM(
	 	input w_dataMem,            	 // 写信号
  input [31:0] rw_addr,            // 读写地址
  input [31:0] in_data,         	 // 要写入的数据 
  output reg [31:0] out_data    	 // 读出的数据
    );
  */
  DM DM_case (.CLK(CLK), .w_dataMem(w_dataMem), .rw_addr(result), .in_data(out_dataB), 
              .out_data(out_data));
  
  /*
  module ADDMulti4_32(
    input [31:0] A,
    input [31:0] B,
    output [31:0] out
    );
    // 专为地址跳转： （pc+4）+ imme << 2
  */
  ADDMulti4_32 ADDMulti4_32_case (.A(pc_new), .B(new_immed),
                                  .out(out_ADDMulti4_32));
  
  /*
  module MUX4L_32(
  input [1:0] slc,
  input [31:0] in_0,
  input [31:0] in_1,
  input [31:0] in_2,
  input [31:0] in_3,
  output [31:0] out_0
    );
  */
  MUX4L_32 MUX4L_32_pcSrc (.slc(slc_pcSrc), .in_0(pc_new), 
                           .in_1(out_ADDMulti4_32), 
                           .in_2(out_dataA), .in_3(out_addr),
                           .out_0(out_pcSrc));
  
  /*
  module MUX4L_5(
	 input [1:0] slc,
    input [4:0] in_0,
    input [4:0] in_1,
	 input [4:0] in_2,
	 input [4:0] in_3,
    out_0put [4:0] out_0
    );
  */
  // 1F : $31
  MUX4L_5 MUX4L_5_RFWriteAddr (.slc(slc_RFWriteAddr), .in_0(5'h1F), 
                               .in_1(rt), .in_2(rd), 
                               .in_3(5'b00000),
                               .out_0(out_RFWriteAddr));
  // in_3 不使用
  
 /*
 module CU(
     input CLK,              			// 时钟
     input reset,            			// 重置信号
  input [5:0] op_instruction,     // 指令的op段
  input [5:0] func_instruction,		// 指令的func段
    input zero,             			// ALU的zero输出

     // 一堆控制信号
    output reg w_pc,           		// PC 写信号    
    output reg slc_ALUB,         	// 多路选择器： ALU源操作数B来源选择
    output reg slc_ALUA,          // 多路选择器： ALU源操作数A来源选择
    output reg[1:0] slc_RFWriteData,  // 多路选择器：RF写数据来源第一级（两级选择）
    output reg w_RF,          		// (RF)写使能信号，为1时，在时钟上升沿写入
    output reg w_dataMem,       	// (DM)数据存储器读写控制信号，为1写，为0读
  output reg[1:0] op_ext,     		// 立即数拓展： 00：移位指令下对sa的0拓展；
  																// 01拓展一般0拓展
  																// 11： 一般情况的符号拓展
  output reg[1:0] slc_pcSrc,      // 新的PC值的来源选择
  output reg[1:0] slc_RFWriteAddr,// RF写地址的来源选择
  output reg[3:0] op_ALU       		// ALU操作码
    );
 */

  CU CU_case (.CLK(CLK), .reset(reset), .op_instruction(op), 
              .func_instruction(func), .zero(zero),
              .w_pc(w_pc), .slc_ALUB(slc_ALUB), .slc_ALUA(slc_ALUA),	 
              .slc_RFWriteData(slc_RFWriteData), .w_RF(w_RF), 
              .w_dataMem(w_dataMem), .op_ext(op_ext), .slc_pcSrc(slc_pcSrc), 
              .slc_RFWriteAddr(slc_RFWriteAddr), .op_ALU(op_ALU));
 
endmodule