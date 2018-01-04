`include "config.vh"

module RISC_V(
	input CLK,
	input RST
	
);

	wire[`ADDR_WIDTH] inst_addr;
	wire[255:0]       inst;
	
	wire[`ADDR_WIDTH] mem_addr_i;
	wire[255:0]       mem_data_i;
	wire[255:0]       mem_data_o;
	wire mem_write_op_i; 
	wire mem_read_op_i;
	wire rom_read_op;
 

 	core core0(
		.CLK(CLK),
		.RST(RST),
	
		.rom_read_op(rom_read_op),
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),

		.ram_data_i(mem_data_o),
		.ram_read_op(mem_read_op_i),
		.ram_write_op(mem_write_op_i),
		.ram_addr(mem_addr_i),
		.ram_data_o(mem_data_i)
	);
	
	inst_rom inst_rom0(
		.RST(RST),
		.read_op(rom_read_op),
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