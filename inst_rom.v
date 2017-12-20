`include "config.vh"

module inst_rom
(
	input                   RST,
	input [`ADDR_WIDTH]     addr,
	output reg[`DATA_WIDTH]	inst
);

	reg[`DATA_WIDTH]  inst_mem[0:`InstMemNum-1];
    wire [`DATA_WIDTH] tmp_inst = inst_mem[addr[`InstMemNumLog2+1:2]];

	initial begin
	   $readmemh ("C:/Users/59572/RISC-V/inst_rom.data", inst_mem);
	   $display("0x00: %h", inst_mem[0]);
	end
	always @ (*) begin
		if (RST) begin
			inst <= `ZeroWord;
	    end else begin
		    inst <= {tmp_inst[7:0], tmp_inst[15:8], tmp_inst[23:16], tmp_inst[31:24]};
		end
	end
endmodule
