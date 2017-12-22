`timescale 1ns / 1ps
`include "config.vh"

module EX_MEM(

	input CLK,
	input RST,

	input [5:0]	stall,	
	
	//from execution module
	input [`REG_WIDTH]    ex_rd,
	input                 ex_rd_op,
	input [`DATA_WIDTH]	  ex_rd_data, 	

    input [`ALU_OP_WIDTH] ex_aluop,
	input [`DATA_WIDTH]   ex_mem_addr,
	input [`DATA_WIDTH]   ex_mem_wdata,
	
	
	//send to memeory module
	output reg[`REG_WIDTH]    mem_rd,
	output reg                mem_rd_op,
	output reg[`DATA_WIDTH]   mem_rd_data,
    output reg[`ALU_OP_WIDTH] mem_aluop,
	output reg[`DATA_WIDTH]   mem_mem_addr,
	output reg[`DATA_WIDTH]   mem_mem_wdata
);
	always @ (posedge CLK or posedge RST) begin
		if(RST) begin
            mem_rd        <= `ZeroReg;
			mem_rd_op     <= 1'b0;
		    mem_rd_data   <= `ZeroWord;	
  		    mem_aluop     <= `ALU_NOP;
			mem_mem_addr  <= `ZeroWord;
			mem_mem_wdata <= `ZeroWord;
		end else if(stall[3] && !stall[4]) begin
			mem_rd        <= `ZeroReg;
			mem_rd_op     <= 1'b0;
		    mem_rd_data   <= `ZeroWord;
  		    mem_aluop     <= `ALU_NOP;
			mem_mem_addr  <= `ZeroWord;
			mem_mem_wdata <= `ZeroWord;
		end else if(!stall[3]) begin
			mem_rd        <= ex_rd;
			mem_rd_op     <= ex_rd_op;
			mem_rd_data   <= ex_rd_data;	
  		    mem_aluop     <= ex_aluop;
			mem_mem_addr  <= ex_mem_addr;
			mem_mem_wdata <= ex_mem_wdata;
	    end
	end
			

endmodule