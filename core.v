`include "config.vh"
`timescale 1ns / 1ps

module core(

	input CLK,
	input RST,
	
 
	input [`DATA_WIDTH]         rom_data_i,
	output wire[`DATA_WIDTH]    rom_addr_o,
	output wire                 rom_ce_o,
	
	input [`DATA_WIDTH]         ram_data_i,
    output wire                 ram_read_op,
    output wire                 ram_write_op,
    output wire [`ADDR_WIDTH]   ram_addr,
    output wire [3:0]           ram_mask,
    output wire [`DATA_WIDTH]   ram_data_o
	
);

	wire[`ADDR_WIDTH] pc;
	wire[`ADDR_WIDTH] id_pc_i;
	wire[`DATA_WIDTH] id_inst_i;
	
	//连接译码阶段ID模块的输出与ID/EX模块的输�??
	wire[`ALU_OP_WIDTH] id_aluop_o;
	wire[`DATA_WIDTH] id_reg1_o;
	wire[`DATA_WIDTH] id_reg2_o;
	wire id_reg_op_o;
	wire[`REG_WIDTH] id_rd_o;
	wire id_is_in_delayslot_o;
    wire[`DATA_WIDTH] id_link_address_o;	
    wire[`DATA_WIDTH] id_inst_o;
	wire[`DATA_WIDTH] id_mem_wdata_o;
	
	//连接ID/EX模块的输出与执行阶段EX模块的输�??
	wire[`ALU_OP_WIDTH] ex_aluop_i;
	wire[`DATA_WIDTH] ex_reg1_i;
	wire[`DATA_WIDTH] ex_reg2_i;
	wire ex_reg_op_i;
	wire[`REG_WIDTH] ex_rd_i;
	wire ex_is_in_delayslot_i;	
    wire[`DATA_WIDTH] ex_link_address_i;	
    wire[`DATA_WIDTH] ex_inst_i;
	wire[`DATA_WIDTH] ex_mem_wdata_i;
	
	//连接执行阶段EX模块的输出与EX/MEM模块的输�??
	wire ex_reg_op_o;
	wire[`REG_WIDTH] ex_rd_o;
	wire[`DATA_WIDTH] ex_data_o;
	wire[`DATA_WIDTH] ex_mem_wdata_o;
	
	wire[`ALU_OP_WIDTH] ex_aluop_o;
	wire[`DATA_WIDTH] ex_mem_addr_o;
	wire[`DATA_WIDTH] ex_reg1_o;
	wire[`DATA_WIDTH] ex_reg2_o;	

	//连接EX/MEM模块的输出与访存阶段MEM模块的输�??
	wire mem_reg_op_i;
	wire[`REG_WIDTH] mem_rd_i;
	wire[`DATA_WIDTH] mem_data_i;
	wire[`DATA_WIDTH] mem_mem_wdata_i;
	
	wire[`ALU_OP_WIDTH] mem_aluop_i;
	wire[`DATA_WIDTH] mem_mem_addr_i;
	wire[`DATA_WIDTH] mem_reg1_i;
	wire[`DATA_WIDTH] mem_reg2_i;		

	//连接访存阶段MEM模块的输出与MEM/WB模块的输�??
	wire mem_reg_op_o;
	wire[`REG_WIDTH] mem_rd_o;
	wire[`DATA_WIDTH] mem_data_o;
	
	
	//连接MEM/WB模块的输出与回写阶段的输�??	
	wire wb_reg_op_i;
	wire[`REG_WIDTH] wb_rd_i;
	wire[`DATA_WIDTH] wb_data_i;

	
	//连接译码阶段ID模块与�?�用寄存器Regfile模块
    wire[1:0] reg1_read;
    wire[1:0] reg2_read;
    wire[`DATA_WIDTH] reg1_data;
    wire[`DATA_WIDTH] reg2_data;
    wire[`REG_WIDTH] reg1_addr;
    wire[`REG_WIDTH] reg2_addr;

	wire is_in_delayslot_i;
	wire is_in_delayslot_o;
	wire next_inst_in_delayslot_o;
	wire id_branch_flag_o;
	wire[`DATA_WIDTH] branch_target_address;

	wire [5:0] stall;
	wire stallreq_from_id;	
	wire stallreq_from_ex;
  
  //pc_reg例化
	pc_reg pc_reg0(
		.CLK(CLK),
		.RST(RST),
		.stall(stall),
		.branch_flag(id_branch_flag_o),
		.branch_target_address(branch_target_address),		
		.PC(pc)
	);
	
  	assign rom_addr_o = pc;

  	//IF/ID模块例化
	IF_ID if_id0(
		.CLK(CLK),
		.RST(RST),
		.stall(stall),
		.jmp_flag(id_branch_flag_o),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);
	
	//译码阶段ID模块
	ID id0(
		.RST(RST),
		.addr(id_pc_i),
		.inst_i(id_inst_i),
		.reg1_data(reg1_data),
		.reg2_data(reg2_data),

		.ex_aluop(ex_aluop_o),

	    //处于执行阶段的指令要写入的目的寄存器信息
		.ex_reg_op(ex_reg_op_o),
		.ex_data(ex_data_o),
		.ex_rd(ex_rd_o),

	    //处于访存阶段的指令要写入的目的寄存器信息
		.mem_reg_op(mem_reg_op_o),
		.mem_data(mem_data_o),
		.mem_rd(mem_rd_o),

	    .is_in_delayslot_i(is_in_delayslot_i),

		//送到regfile的信�??
		.reg1_op(reg1_read),
		.reg2_op(reg2_read), 	  

		.reg1_addr(reg1_addr),
		.reg2_addr(reg2_addr), 
	  
		//送到ID/EX模块的信�??
		.ALU_op(id_aluop_o),
		.src_1(id_reg1_o),
		.src_2(id_reg2_o),
		.rd(id_rd_o),
		.write_op(id_reg_op_o),
		.inst_o(id_inst_o),

		.mem_wdata(id_mem_wdata_o),
	 	.next_inst_in_delayslot(next_inst_in_delayslot_o),	
		.branch_flag(id_branch_flag_o),
		.branch_target_address(branch_target_address),       
		.link_addr(id_link_address_o),
		
		.is_in_delayslot_o(id_is_in_delayslot_o),
		
		.stallreq(stallreq_from_id)		
	);

  	//通用寄存器Regfile例化
	regist regfile(
		.CLK (CLK),
		.RST (RST),
		.write_op   (wb_reg_op_i),
		.write_addr (wb_rd_i),
		.write_data (wb_data_i),
		.read_op1   (reg1_read),
		.read_addr1 (reg1_addr),
		.read_data1 (reg1_data),
		.read_op2   (reg2_read),
		.read_addr2 (reg2_addr),
		.read_data2 (reg2_data)
	);

	//ID/EX模块
	ID_EX id_ex0(
		.CLK(CLK),
		.RST(RST),
		
		.stall(stall),
		
		//从译码阶段ID模块传�?�的信息
		.id_AluOp(id_aluop_o),

		.id_reg1(id_reg1_o),
		.id_reg2(id_reg2_o),
		.id_rd(id_rd_o),
		.id_rd_op(id_reg_op_o),
		.id_link_address(id_link_address_o),
		.id_delayslot(id_is_in_delayslot_o),
		.next_delayslot(next_inst_in_delayslot_o),		
		.id_inst(id_inst_o),	
		.id_mem_wdata(id_mem_wdata_o),
	
		//传�?�到执行阶段EX模块的信�??
		.ex_AluOp(ex_aluop_i),
		.ex_reg1(ex_reg1_i),
		.ex_reg2(ex_reg2_i),
		.ex_rd(ex_rd_i),
		.ex_rd_op(ex_reg_op_i),
		.ex_link_address(ex_link_address_i),
  		.ex_is_in_delayslot(ex_is_in_delayslot_i),
		.is_in_delayslot(is_in_delayslot_i),
		.ex_inst(ex_inst_i),
		.ex_mem_wdata(ex_mem_wdata_i)	
	);		
	
	//EX模块
	EX ex0(
		.RST(RST),
	
		//送到执行阶段EX模块的信�??
		.AluOP(ex_aluop_i),
		.src1(ex_reg1_i),
		.src2(ex_reg2_i),
		.rd(ex_rd_i),
		.rd_op(ex_reg_op_i),
		.inst_i(ex_inst_i),
		.mem_wdata_i(ex_mem_wdata_i),

	  	.link_address_i(ex_link_address_i),
		.is_in_delayslot_i(ex_is_in_delayslot_i),	  
			  
	  	//EX模块的输出到EX/MEM模块信息
		.rd_o(ex_rd_o),
		.rd_op_o(ex_reg_op_o),
		.rd_data(ex_data_o),
		.mem_wdata_o(ex_mem_wdata_o),

		.AluOP_o(ex_aluop_o),
		.mem_addr_o(ex_mem_addr_o),
		
		.stallreq(stallreq_from_ex)     				
		
	);

  //EX/MEM模块
  EX_MEM ex_mem0(
		.CLK(CLK),
		.RST(RST),
	  
	  	.stall(stall),
	  
		//来自执行阶段EX模块的信�??	
		.ex_rd(ex_rd_o),
		.ex_rd_op(ex_reg_op_o),
		.ex_rd_data(ex_data_o),

  		.ex_aluop(ex_aluop_o),
		.ex_mem_addr(ex_mem_addr_o),	
		.ex_mem_wdata(ex_mem_wdata_o),

		//送到访存阶段MEM模块的信�??
		.mem_rd(mem_rd_i),
		.mem_rd_op(mem_reg_op_i),
		.mem_rd_data(mem_data_i),

  		.mem_aluop(mem_aluop_i),
		.mem_mem_addr(mem_mem_addr_i),
		.mem_mem_wdata(mem_mem_wdata_i)
	);
	
  //MEM模块例化
	mem mem0(
		.RST(RST),
	
		//来自EX/MEM模块的信�??	
		.rd(mem_rd_i),
		.rd_op(mem_reg_op_i),
		.rd_data(mem_data_i),
		
		

  		.AluOP(mem_aluop_i),
		.mem_addr(mem_mem_addr_i),
		.mem_wdata_i(mem_mem_wdata_i),
	
		//来自memory的信�??
		.mem_data(ram_data_i),
	  
		//送到MEM/WB模块的信�??
		.rd_o(mem_rd_o),
		.rd_op_o(mem_reg_op_o),
		.rd_data_o(mem_data_o),
		
		//送到memory的信�??
		.mem_addr_o(ram_addr),
		.mem_write(ram_write_op),
		.mem_read(ram_read_op),
		.mem_mask(ram_mask),
		.mem_wdata(ram_data_o)		
	);

  //MEM/WB模块
	mem_wb mem_wb0(
		.CLK(CLK),
		.RST(RST),

    	.stall(stall),

		//来自访存阶段MEM模块的信�??	
		.mem_rd(mem_rd_o),
		.mem_rd_op(mem_reg_op_o),
		.mem_rd_data(mem_data_o),							
	
		//送到回写阶段的信�??
		.wb_rd(wb_rd_i),
		.wb_rd_op(wb_reg_op_i),
		.wb_rd_data(wb_data_i)							       	
	);
	
	ctrl ctrl0(
		.RST(RST),
	
		.stallreq_from_id(stallreq_from_id),
		.stallreq_from_ex(stallreq_from_ex),

		.stall(stall)       	
	);

	
endmodule