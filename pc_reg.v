`timescale 1ns / 1ps
`include "config.vh"

module pc_reg(

	input CLK,
	input RST,

	//from control module
	input wire[5:0] stall,

	//from decode module
	input wire          branch_flag,
	input wire[`DATA_WIDTH] branch_target_address,
	
	output reg[`DATA_WIDTH] PC
);

	always @ (posedge CLK or posedge RST) begin
		if (RST) begin
			PC <= 32'h00000000;
		end else if(!stall[0]) begin
		  	if(branch_flag == 1) begin
				PC <= branch_target_address;
			end else begin
		  		PC <= PC + 4;
		  	end
		end
	end
endmodule