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
	reg jmp;
	reg [`DATA_WIDTH] next_addr;
	always @ (posedge CLK or posedge RST) begin
		if (RST) begin
			PC <= 32'h00000000;
			jmp <= 1'b0;
		end else begin
			if(!stall[0]) begin
				if(branch_flag == 1) begin
					PC  <= branch_target_address;
				end else begin
					PC <= PC + 4;
				end
			end else begin
			  	if(branch_flag == 1) begin
					jmp <= 1'b1;
					next_addr <= branch_target_address;
				end
				// if (jmp) begin
				// 	PC  <= next_addr;
				// 	jmp <= 1'b0;
				// end
			end
		end
	end
endmodule