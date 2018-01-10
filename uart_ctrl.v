`include "config.vh"

module uart_ctrl
(
    input CLK,
    input RST,
    input read_op,
    input write_op,
    input [`ADDR_WIDTH] addr,
    input [255:0]       data_i,
    output reg [255:0]  data_o,
    output reg busy,
    output reg done,

    output wire Tx,
    input Rx
);

    wire 		UART_send_flag;
	wire [7:0]	UART_send_data;
	wire 		UART_recv_flag;
	wire [7:0]	UART_recv_data;
	wire		UART_sendable;
	wire		UART_receivable;

    

    uart_comm UART(
		CLK, RST,
		UART_send_flag, UART_send_data,
		UART_recv_flag, UART_recv_data,
		UART_sendable, UART_receivable,
		Tx, Rx);

    wire 					COMM_read_flag[CHANNEL-1:0];
	wire [MESSAGE_BIT-1:0]	COMM_read_data[CHANNEL-1:0];
	wire [4:0]				COMM_read_length[CHANNEL-1:0];
	wire 					COMM_write_flag[CHANNEL-1:0];
	wire [MESSAGE_BIT-1:0]	COMM_write_data[CHANNEL-1:0];
	wire [4:0]				COMM_write_length[CHANNEL-1:0];
	wire					COMM_readable[CHANNEL-1:0];
	wire					COMM_writable[CHANNEL-1:0];

    multchan_comm #(.MESSAGE_BIT(255), .CHANNEL_BIT(1)) COMM(
		CLK, RST,
		UART_send_flag, UART_send_data,
		UART_recv_flag, UART_recv_data,
		UART_sendable, UART_receivable,
		{COMM_read_flag[1], COMM_read_flag[0]},
		{COMM_read_length[1], COMM_read_data[1], COMM_read_length[0], COMM_read_data[0]},
		{COMM_write_flag[1], COMM_write_flag[0]},
		{COMM_write_length[1], COMM_write_data[1], COMM_write_length[0], COMM_write_data[0]},
		{COMM_readable[1], COMM_readable[0]},
		{COMM_writable[1], COMM_writable[0]}
        );
    
    wire op = read_op ? 0 : 1;
    wire [`ADDR_WIDTH] _addr = {op, addr[30:0]};
    reg[31:0] cnt1;
    reg[31:0] cnt2;
    always @ (posedge CLK) begin
        if (RST) begin
            cnt1 <= 32'b0;
            cnt2 <= 32'b0;
            busy <= 1'b0;
            done <= 1'b0;
        end else if (read_op) begin
            if (cnt2 >= 256) begin
                cnt2 <= 32'b0;
                cnt1 <= 32'b0;
                busy <= 1'b0;
                done <= 1'b1;
            end else begin
                busy = 1'b1;
                done <= 1'b0;
                if (cnt1 < 32 && sendable) begin
                    send_flag <= 1'b1;
                    recv_flag <= 1'b0;
                    send_data <= _addr[cnt1+:8];
                    cnt1      <= cnt1 + 8;
                end else if (cnt1 == 32 && receivable) begin
                    send_flag       <= 1'b0;
                    recv_flag       <= 1'b1;
                    send_data       <= 8'b00000000;
                    data_o[cnt2+:8] <= recv_data;
                    cnt2            <= cnt2 + 8;
                end
            end 
        end else if (write_op) begin
            if (cnt2 >= 256) begin
                cnt2 <= 32'b0;
                cnt1 <= 32'b0;
                busy <= 1'b0;
                done <= 1'b1;
            end else begin
                busy <= 1'b1;
                done <= 1'b0;
                if (cnt1 < 32 && sendable) begin
                    send_flag <= 1'b1;
                    recv_flag <= 1'b0;
                    send_data <= _addr[cnt1+:8];
                    cnt1      <= cnt1 + 8;
                end else if (cnt1 == 32 && sendable) begin
                    send_flag       <= 1'b1;
                    recv_flag       <= 1'b0;
                    send_data       <= _addr[cnt1+:8];
                    cnt2            <= cnt2 + 8;
                end
            end 
        end
    end
endmodule
