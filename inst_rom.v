`include "config.vh"

module inst_rom
(
	input                       RST,
	input                       read_op,
	input [`ADDR_WIDTH]         addr,
	output wire[255:0]      	inst
);

	reg[`DATA_WIDTH]  inst_mem[0:`InstMemNum-1];

	initial begin
	   $readmemh ("C:/Users/59572/RISC-V/inst_rom.mem", inst_mem);
	end
	assign inst[31:0]    = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 0];
	assign inst[63:32]   = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 1];
	assign inst[95:64]   = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 2];
	assign inst[127:96]  = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 3];
	assign inst[159:128] = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 4];
	assign inst[191:160] = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 5];
	assign inst[223:192] = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 6];
	assign inst[255:224] = (read_op == 1'b0) ? `ZeroWord : inst_mem[addr[`InstMemNumLog2+1:2] + 7];
	
	// always @ (*) begin
	// 	if (RST) begin
	// 		inst <= `ZeroWord;
	//     end else begin
	// 	    inst <= {tmp_inst[7:0], tmp_inst[15:8], tmp_inst[23:16], tmp_inst[31:24]};
	// 	end
	// end
endmodule
