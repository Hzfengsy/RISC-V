`include "config.vh"

module ID_EX(
	input CLK,
	input RST,

	//from control module
	input [5:0] stall,
	
	//from decode module
	input [`ALU_OP_WIDTH]          id_AluOp,
	input [`DATA_WIDTH]            id_reg1,
	input [`DATA_WIDTH]            id_reg2,
	input [`REG_WIDTH]             id_rd,
	input                          id_rd_op,
	input [`DATA_WIDTH]            id_link_address,
	input                          id_delayslot,
	input                          next_delayslot,		
	input [`DATA_WIDTH]            id_inst,
	input [`DATA_WIDTH]            id_mem_wdata,
	
	//to excute module
	output reg [`ALU_OP_WIDTH]     ex_AluOp,
	output reg [`DATA_WIDTH]       ex_reg1,
	output reg [`DATA_WIDTH]       ex_reg2,
	output reg [`REG_WIDTH]        ex_rd,
	output reg                     ex_rd_op,
	output reg [`DATA_WIDTH]       ex_link_address,
    output reg                     ex_is_in_delayslot,
	output reg                     is_in_delayslot,
	output reg [`DATA_WIDTH]       ex_inst,
	output reg [`DATA_WIDTH]       ex_mem_wdata
);

	always @ (posedge CLK) begin
		if (RST) begin
			ex_AluOp           <= `ALU_NOP;
			ex_reg1            <= `ZeroWord;
			ex_reg2            <= `ZeroWord;
			ex_rd              <= 5'd0;
			ex_rd_op           <= 0;
			ex_link_address    <= `ZeroWord;
			ex_is_in_delayslot <= 0;
	        is_in_delayslot    <= 0;
	        ex_inst            <= `ZeroWord;
			ex_mem_wdata           <= `ZeroWord;
		end else if(stall[2] && !stall[3]) begin
			ex_AluOp           <= `ALU_NOP;
			ex_reg1            <= `ZeroWord;
			ex_reg2            <= `ZeroWord;
			ex_rd              <= 5'd0;
			ex_rd_op           <= 0;
			ex_link_address    <= `ZeroWord;
			ex_is_in_delayslot <= 0;
	        ex_inst            <= `ZeroWord;
			ex_mem_wdata           <= `ZeroWord;
		end else if(!stall[2]) begin
            ex_AluOp           <= id_AluOp;
			ex_reg1            <= id_reg1;
			ex_reg2            <= id_reg2;
			ex_rd              <= id_rd;
			ex_rd_op           <= id_rd_op;
			ex_link_address    <= id_link_address;
			ex_is_in_delayslot <= id_delayslot;
            is_in_delayslot    <= next_delayslot;
	        ex_inst            <= id_inst;
			ex_mem_wdata           <= id_mem_wdata;		
		end
	end
	
endmodule