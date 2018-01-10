module mem_ctrl(
    input CLK,
    input RST,
    input read_op1,
    input read_op2,
    input write_op,
    input [`ADDR_WIDTH]        addr1,
    input [`ADDR_WIDTH]        addr2,
    input [`BENCH_WIDTH]       data2_i,
    output wire [`BENCH_WIDTH]  data1_o,
    output wire [`BENCH_WIDTH]  data2_o,
	input [15:0]               mask,
    output wire busy1,
    output wire done1,
    output wire busy2,
    output wire done2,

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
	
	localparam CHANNEL_BIT = 1;
	localparam MESSAGE_BIT = 184;
	localparam CHANNEL = 1 << CHANNEL_BIT;
	
	wire 					COMM_read_flag[CHANNEL-1:0];
	wire [MESSAGE_BIT-1:0]	COMM_read_data[CHANNEL-1:0];
	wire [4:0]				COMM_read_length[CHANNEL-1:0];
	wire 					COMM_write_flag[CHANNEL-1:0];
	wire [MESSAGE_BIT-1:0]	COMM_write_data[CHANNEL-1:0];
	wire [4:0]				COMM_write_length[CHANNEL-1:0];
	wire					COMM_readable[CHANNEL-1:0];
	wire					COMM_writable[CHANNEL-1:0];
	
	multchan_comm #(.MESSAGE_BIT(MESSAGE_BIT), .CHANNEL_BIT(CHANNEL_BIT)) COMM(
		CLK, RST,
		UART_send_flag, UART_send_data,
		UART_recv_flag, UART_recv_data,
		UART_sendable, UART_receivable,
		{COMM_read_flag[1], COMM_read_flag[0]},
		{COMM_read_length[1], COMM_read_data[1], COMM_read_length[0], COMM_read_data[0]},
		{COMM_write_flag[1], COMM_write_flag[0]},
		{COMM_write_length[1], COMM_write_data[1], COMM_write_length[0], COMM_write_data[0]},
		{COMM_readable[1], COMM_readable[0]},
		{COMM_writable[1], COMM_writable[0]});
	
	wire [2*2-1:0]	MEM_rw_flag;
	wire [2*32*4-1:0]	MEM_read_data;
	wire [2*32*4-1:0]	MEM_write_data;

    assign MEM_rw_flag[1:0] = read_op1 ? 2'b01 : 2'b00;
    assign MEM_rw_flag[3:2] = read_op2 ? 2'b01 : (write_op ? 2'b10 : 2'b00);
    assign MEM_write_data[255:128] = data2_i;
	
	controller CTRL(
		CLK, RST,
		COMM_write_flag[0], COMM_write_data[0], COMM_write_length[0],
		COMM_read_flag[0], COMM_read_data[0], COMM_read_length[0],
		COMM_writable[0], COMM_readable[0],
		MEM_rw_flag, {addr2, addr1},
		{data2_o, data1_o}, MEM_write_data, {mask, 16'h0000},
		{busy2, busy1}, {done2, done1});

endmodule