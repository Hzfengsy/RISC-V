`timescale 1ns/1ps

module sim();
    reg     CLOCK_50;
    reg     rst;
    initial begin
        CLOCK_50 = 1'b0;
        forever #2 CLOCK_50 = ~CLOCK_50;
    end
      
    initial begin
        rst = 1'b1;
        #30 rst= 1'b0;
        #4100 $stop;
    end
       
  RISC_V RISC_V0(
		.CLK(CLOCK_50),
		.RST(rst)	
	);

endmodule