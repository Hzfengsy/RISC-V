`include "config.vh"

module mem_wb(

	input CLK,
	input RST,

	input [5:0]             stall,	

	input [`REG_WIDTH]      mem_rd,
	input                   mem_rd_op,
	input [`DATA_WIDTH]	    mem_rd_data,

	output reg[`REG_WIDTH]  wb_rd,
	output reg              wb_rd_op,
	output reg[`DATA_WIDTH]	wb_rd_data
);


	always @ (posedge CLK) begin
		if(RST) begin
			wb_rd      <= `ZeroReg;
			wb_rd_op   <= 1'b0;
		  	wb_rd_data <= `ZeroWord;
		end else if(stall[4] && !stall[5]) begin
			wb_rd      <= `ZeroReg;
			wb_rd_op   <= 1'b0;
		  	wb_rd_data <= `ZeroWord;
		end else if(!stall[4]) begin
			wb_rd      <= mem_rd;
			wb_rd_op   <= mem_rd_op;
		  	wb_rd_data <= mem_rd_data;		
		end
	end
			

endmodule