`include "config.vh"

module RISC_V(
	input CLK,
	input RST
	
);

	wire[`ADDR_WIDTH] inst_addr;
	wire[`DATA_WIDTH] inst;
	
	wire[`ADDR_WIDTH] mem_addr_i;
	wire[255:0] mem_data_i;
	wire[255:0] mem_data_o;
	wire mem_write_op_i; 
	wire mem_read_op_i;
 

 	core core0(
		.CLK(CLK),
		.RST(RST),
	
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),

		.ram_data_i(mem_data_o),
		.ram_read_op(mem_read_op_i),
		.ram_write_op(mem_write_op_i),
		.ram_addr(mem_addr_i),
		.ram_data_o(mem_data_i)
	);
	
	inst_rom inst_rom0(
		.RST(RST),
		.addr(inst_addr),
		.inst(inst)	
	);

	data_ram data_ram0(
		.CLK(CLK),
		.read_op(mem_read_op_i),
		.write_op(mem_write_op_i),
		.addr(mem_addr_i),
		.data_i(mem_data_i),
		.data_o(mem_data_o)
	);

endmodule