`timescale 1ns / 1ps

module sim_memory(
	input CLK,
	input RST,
	output Tx,
	input Rx
    );
    
    wire send_flag;
	wire [7:0] send_data;
	wire recv_flag;
	wire [7:0] recv_data;
	
	wire recvable, sendable;
	uart_comm uart(CLK, RST, send_flag, send_data, recv_flag, recv_data, sendable, recvable, Tx, Rx);
	
	reg read_flag;
	wire [4:0] read_data_length;
	wire [255:0] read_data;
	reg write_flag;
	reg [4:0] write_data_length;
	reg [255:0] write_data;
	wire readable;
	wire writable;
	
	wire _trash, _trash2;
	
	reg [7:0] memory[132047:0];
	reg [7:0] memory_stack[132047:0];
	
	integer i;
	initial begin
		for(i=0;i<2048;i=i+1) begin
			memory[i] = 0;
			memory_stack[i] = 0;
		end
		$readmemh("C:/Users/59572/RISC-V/inst_rom.data", memory);
	end
	
	function [31:0] getDWORD;
		input [31:0] addr;
		getDWORD = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]};
	endfunction
	
	function [15:0] getWORD;
		input [31:0] addr;
		getWORD = {memory[addr+1], memory[addr]};
	endfunction
	
	multchan_comm #(.CHANNEL_BIT(1), .MESSAGE_BIT(256)) comm(
		CLK, RST, send_flag, send_data, recv_flag, recv_data, sendable, recvable,
		{1'b0, read_flag}, {read_data_length, read_data},
		{1'b0, write_flag}, {write_data_length, write_data},
		{_trash, readable}, {_trash2, writable});
	
	always @(posedge CLK or posedge RST) begin
		read_flag <= 0;
		write_flag <= 0;
		if(RST) begin
			write_data <= 0;
		end else begin
			if(readable) begin
				read_flag <= 1;
				if(read_data_length == 5 && read_data[32] == 0) begin	//read
					$display("GET READ REQUEST, ADDR = 0x%x DATA = %x", read_data[31:0], {getDWORD(read_data[31:0]+12), getDWORD(read_data[31:0]+8), getDWORD(read_data[31:0]+4), getDWORD(read_data[31:0])});
					write_flag <= 1;
					write_data <= {getDWORD(read_data[31:0]+12), getDWORD(read_data[31:0]+8), getDWORD(read_data[31:0]+4), getDWORD(read_data[31:0])};
					write_data_length <= 16;
				end else begin	//write
					$display("GET WRITE REQUEST, ADDR = 0x%x DATA = %x MASK = %x", read_data[159:128], read_data[127:0], read_data[175:160]);
					if(read_data[64])
						memory[read_data[63:32]] <= read_data[7:0];
					if(read_data[65])
						memory[read_data[63:32]+1] <= read_data[15:8];
					if(read_data[66])
						memory[read_data[63:32]+2] <= read_data[23:16];
					if(read_data[67])
						memory[read_data[63:32]+3] <= read_data[31:24];
				end
			end
		end
	end
endmodule
