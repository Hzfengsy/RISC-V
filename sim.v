`timescale 1ns/1ps

module sim();
    reg     CLOCK_50;
    reg     rst;
    initial begin
        CLOCK_50 = 1'b0;
        forever #1 CLOCK_50 = ~CLOCK_50;
    end
      
    initial begin
        rst = 1'b1;
        #10.5 rst= 1'b0;
    end
    wire Tx;
    wire Rx;
       
    RISC_V RISC_V0(
		.CLK(CLOCK_50),
		.RST(rst),
		
		.Tx(Tx),
		.Rx(Rx)	
	);
	
	sim_memory sim_memory0(
        .CLK(CLOCK_50),
        .RST(rst),
        .Tx(Rx),
        .Rx(Tx)
        );

endmodule