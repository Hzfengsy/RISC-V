`include "config.vh"

module ctrl(
	input RST,
	//from decode
	input stallreq_from_id,

  	//from execute
	input stallreq_from_ex,
	output reg[5:0] stall       
);
	always @ (*) begin
		if(RST == 1) begin
			stall <= 6'b000000;
		end else if(stallreq_from_ex == 1) begin
			stall <= 6'b001111;
		end else if(stallreq_from_id == 1) begin
			stall <= 6'b000111;
		end else begin
			stall <= 6'b000000;
		end
	end
endmodule