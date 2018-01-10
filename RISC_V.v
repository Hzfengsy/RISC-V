`include "config.vh"

module RISC_V(
	input CLK,
	input RST,
	
	output wire Tx,
    input Rx
);

	wire[`ADDR_WIDTH]   inst_addr;
	wire[`BENCH_WIDTH]  inst;
	  
	wire[`ADDR_WIDTH]   mem_addr_i;
	wire[`BENCH_WIDTH]  mem_data_i;
	wire[`BENCH_WIDTH]  mem_data_o;
	wire[15:0]          mem_mask;
	wire mem_write_op_i; 
	wire mem_read_op_i;
	wire rom_read_op;
	wire busy1;
    wire done1;
    wire busy2;
    wire done2;
 

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
		.ram_data_o(mem_data_i),
		.ram_mask(mem_mask),

		.busy1(busy1),
		.done1(done1),
		.busy2(busy2),
		.done2(done2)
	);

	mem_ctrl controller
	(
		.CLK(CLK),
		.RST(RST),
		.read_op1(rom_read_op),
		.read_op2(mem_read_op_i),
		.write_op(mem_write_op_i),
		.addr1(inst_addr),
		.addr2(mem_addr_i),
		.data2_i(mem_data_i),
		.data1_o(inst),
		.data2_o(mem_data_o),
		.mask(mem_mask),
		.busy1(busy1),
		.done1(done1),
		.busy2(busy2),
		.done2(done2),

		.Tx(Tx),
		.Rx(Rx)
	);
	
	// inst_rom inst_rom0(
	// 	.RST(RST),
	// 	.read_op(rom_read_op),
	// 	.addr(inst_addr),
	// 	.inst(inst)	
	// );

	// data_ram data_ram0(
	// 	.CLK(CLK),
	// 	.read_op(mem_read_op_i),
	// 	.write_op(mem_write_op_i),
	// 	.addr(mem_addr_i),
	// 	.data_i(mem_data_i),
	// 	.data_o(mem_data_o)
	// );



endmodule