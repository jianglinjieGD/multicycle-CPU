`timescale 1ns/1ps
module multicycle_CPU_TB(
);

  reg clk;   
  always #5 clk = ~clk;
  
  initial
  begin
    #5
    clk = 1;
  end
    
  multicycle_CPU cpu_tb(
    .CLK(clk), .reset(1'b0)
    );
    
endmodule


