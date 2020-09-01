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
  // 有限状态机宏定义
    parameter [2:0] 
        IF    		= 3'b000,
        ID    		= 3'b001,
        EX_MEM		= 3'b010,
  			EX_NO_MEM = 3'b011,
  			EX_NO_WB	=	3'b100,
        MEM_NO_WB	= 3'b101,
        MEM_WB   	= 3'b110,
        WB 				= 3'b111;
        
// 指令的识别部分： func 或 op
    parameter [5:0]
     	add_func  = 6'b100000,
      sub_func 	= 6'b100001, 
      and_func  = 6'b100100, 
      or_func  	= 6'b100101,  
      movn_func = 6'b001011,
      movz_func = 6'b001010,
      sll_func  = 6'b000000,  
      slt_func  = 6'b101010,  
      jr_func   = 6'b001000,  
      addi_op   = 6'b001100,  
      ori_op    = 6'b001101,  
      sw_op  		= 6'b101011,   
      lw_op     = 6'b100011,  
      beq_op    = 6'b000100,   
      j_op  		= 6'b000010,  
      jal_op 		= 6'b000011
  		// ,halt_op = 
  		; 
 		// 状态
    reg [2:0] status;
  	// 初始化
  	initial
    begin
      w_pc <= 0;
      slc_ALUB <= 0;
      slc_ALUA <= 0;
      w_RF <= 0;
      w_dataMem <= 0;
      slc_pcSrc <= 0;
      slc_RFWriteData <= 0;
      slc_RFWriteAddr <= 0;
      op_ALU <= 0;
      status = IF;
    end
    
    always@(posedge CLK or posedge reset)
     begin
        // 重置
        if (reset)  
         begin
            status = IF;
            w_pc = 0;
            w_RF = 0;
         end
        else
         begin
           case (status)				
             	// 根据所处的状态CU发出不同的控制信号

                IF:					 // 对所有指令都一样
                 begin
                    // 禁止写指令，寄存器，和内存
                    w_pc = 0;					// 读取指令期间，不许修改PC
                    w_RF = 0;					// 非流水： RF此阶段不写
                    w_dataMem = 0;		// 同理DM 不写
                   // 其他为了不被遗留的状态影响的重置
                    status <= ID;			// 进入ID段
                 end
             
                ID:
                 begin
                    case (op_instruction)
                      	6'b000000 : 		// op = 0的指令通过func识别
                          begin
                            case (func_instruction)
                              sll_func:
                                begin
                                  op_ext = 2'b00;	// 对sa进行0拓展
                                  status = EX_NO_MEM;
                                end
                              
                              jr_func: status = EX_NO_WB;
                              
                              default:	
                                   status = EX_NO_MEM;	// 其他进入EX_NO_MEM，读寄存器即可
                              	// add_func,  and_func, sub_func,  or_func,  
                              	// movn_func,  movz_func, slt_func:    
                            endcase
                          end		// op = 0 终止
                      	// 以下op != 0, 通过op识别 
                        sw_op, lw_op:
                          begin
                            op_ext = 2'b10;		// 地址符号拓展
                            status = EX_MEM;
                          end
                      	
                      	j_op :	status = EX_NO_WB;
                      	jal_op : status = EX_NO_MEM;
                      
                      	addi_op, beq_op :
                          begin
                            op_ext = 2'b10;				// 进行符号拓展	
                            status = EX_NO_MEM;
                          end
                      	
                        ori_op :
                          begin
                            op_ext = 01;				// 进行一般情况的 0拓展
                            status = EX_NO_MEM;
                          end
                    endcase		
                 end					// ID 终止
             
             EX_MEM: 	// sw, lw
               begin
                 slc_ALUB = 1;		// 
                 slc_ALUA = 1;		// A来源rs
                 op_ALU = 0000;		// rs + imme ==> DM_addr 读写相同
                 if (func_instruction == sw_op) status = MEM_NO_WB; // sw
                 else status = MEM_WB;		// lw
               end
             
             EX_NO_WB: // j, jr
               begin
                 if (func_instruction == jr_func) slc_pcSrc = 2'b10;
                     
                 if (op_instruction == j_op) slc_pcSrc = 2'b11;
              
                 w_pc = 1;
                 status = IF;
               end
             
             EX_NO_MEM: // add, sub, and, or, movn,movz, slt,sll, 
               					// addi, ori, beq, jal
               begin
                 if (op_instruction == 0)		// op = 0,  看func
                   begin
                     slc_ALUB = 0;					//  B来源是rt 
                     slc_ALUA = 1;					// A来源rs
									   case(func_instruction)
                       add_func : op_ALU = 4'b0000;
                       sub_func : op_ALU = 4'b0001;
                       and_func : op_ALU = 4'b0110;
                       or_func  : op_ALU = 4'b0101;
                       movn_func: op_ALU = 4'b1000;
                       movz_func: op_ALU = 4'b1000;
                       slt_func : op_ALU = 4'b0010;
                       sll_func : 
                         begin
                           slc_ALUB = 1;			// B来源imme
                           op_ALU = 4'b0100;
                         end
                       default: ;							// do nothing
                     endcase	     
                   end			// if (op_instrcution == 0)-end
                 else				// op != 0 ????op
                   begin
                     slc_ALUB = 1;				// B???ime
                     slc_ALUA = 1;				// A??rs
                     case(op_instruction)
                       addi_op : op_ALU = 4'b0000;
                       ori_op  : op_ALU = 4'b0101;
                       beq_op  : 
                        begin
                          slc_ALUB = 0;       // rt
                          op_ALU = 4'b0001;
                        end
                       jal_op  : 
                         begin
                           slc_ALUA = 0;
                           op_ALU = 4'b1001;
                         end
                     endcase
                       
                   end				// else-end
               status = WB;		// EX_NO_MEM ==> WB?
             end	// EX_NO_MEM -end
                      
             MEM_NO_WB : // sw
               begin
                 w_dataMem = 1; 			// write DM
                 w_pc =  1;         // write pc
                 status = IF; 	// no WB,????IF?
               end
             
             MEM_WB : 	// lw
               begin
                 w_dataMem = 0;		// read DM 
                 status = WB;	//  ==> WB
               end
             
             WB :				// 对RF写回； 对PC进行更新（部分指令）
               	// 写入rt：addi, ori，lw
                // 写入rd：add, sub, and, or, movn,movz, slt,sll, 
               	// 更新pc: beq, jal 
               					
               begin
                 // 数据来源选择： ALU， DM
                 slc_pcSrc = 0;
                 if (op_instruction == lw_op)	//只有lw是来自DM
                   slc_RFWriteData = 2'b01;
                 else if (op_instruction == 0 && func_instruction[5:1] == 5'b00101) 
                   slc_RFWriteData = 2'b10;	 // 00101 + 1/0:movn,movz 
                 else
                   slc_RFWriteData = 2'b00;	// RF的in_data来源:ALU-result
                 // RF写入地址来源选择：rd， rt
                 case (op_instruction)
                   jal_op:	
                    begin
                      slc_pcSrc = 2'b11;					 // out of PCJUMP 
                      slc_RFWriteAddr = 2'b00;		// $31, 1F
                    end
      
                   addi_op, ori_op, lw_op:
                     begin
                       slc_RFWriteAddr = 2'b01; 	  		// from rt
                     end
                   6'b000000: slc_RFWriteAddr = 2'b10; 	// 正好写入rd的命令都是op=0
                   // select  pc src 
                   beq_op: slc_pcSrc = zero ? 2'b01 : 2'b00;	// pc+4+imme<<2:pc+4
                   
                 endcase
                 
                // 是否给RF发送写信号
                 if (func_instruction == movn_func && zero == 1)
                   w_RF = 0;	// movn 非0则写
                 else if (func_instruction == movz_func && zero == 0)
                   w_RF = 0;	// movz 0则写
                 else
                   w_RF = 1;		// 其他可以进入到WB的命令就是直接写
                   
                 w_pc = 1; 			// 更新pc，每条指令都要的 
                 status = IF; //  ==》 IF
               end  // WB-end
           endcase  // case(status)
         end	  // if (reset) -else end       
     end			  // always_end  
  endmodule





