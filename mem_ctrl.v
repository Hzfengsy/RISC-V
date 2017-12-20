`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/12 13:30:58
// Design Name: 
// Module Name: mem_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`include "config.vh"

//module mem_ctrl
//#(
//parameter PORT_COUNT = 2,
//parameter DATA_WIDTH_BYTE = 4,
//parameter ADDR_WIDTH_BYTE = 4
//)
//(
//    CLK, RST,
	
//	send_flag, send_data, send_length,
//	recv_flag, recv_data, recv_length,
//	//sendable, receivable,
//	rw_flag,                                  //0-read, 1-wirte
//	queue,
//	_addr,
//	_read_data, _write_data, _write_mask,
//    busy, done
//);
//    localparam DATA_WIDTH = 	8 * DATA_WIDTH_BYTE;
//    localparam ADDR_WIDTH =     8 * ADDR_WIDTH_BYTE;
//    localparam LENGTH_WIDTH =   `CLOG2(DATA_WIDTH_BYTE) + 1;
//    localparam PORT_COUNT_BIT = `CLOG2(PORT_COUNT);
//    localparam SEND_BYTE = 		DATA_WIDTH_BYTE + ADDR_WIDTH_BYTE + DATA_WIDTH_BYTE / 8 + 1;
//    input                        CLK, RST;
//    output reg                   send_flag;
//    output reg [SEND_BYTE*8-1:0] send_data;
//    output reg [4:0]             send_length;
//    output reg                   recv_flag;
//    input [SEND_BYTE*8-1:0]      recv_data;
//    input [4:0]                  recv_length;
//    //input                        sendable;
//    //input                        receivable;
//    input [PORT_COUNT-1:0]       rw_flag;
//    input [PORT_COUNT-1:0]       queue;
//    input [PORT_COUNT*ADDR_WIDTH-1:0]      _addr;
//    output [PORT_COUNT*DATA_WIDTH-1:0]     _read_data;
//    input [PORT_COUNT*DATA_WIDTH-1:0]      _write_data;
//    input [PORT_COUNT*DATA_WIDTH_BYTE-1:0] _write_mask;
//    output reg [PORT_COUNT-1:0]	   		   busy;
//    output reg [PORT_COUNT-1:0]            done;
//    wire [ADDR_WIDTH-1:0] 		addr[PORT_COUNT-1:0];
//    reg  [DATA_WIDTH-1:0] 		read_data[PORT_COUNT-1:0];
//    wire [DATA_WIDTH-1:0]       write_data[PORT_COUNT-1:0];
//    wire [DATA_WIDTH_BYTE-1:0]  write_mask[PORT_COUNT-1:0];
    
//    genvar i;
//    generate
//        for(i = 0; i<PORT_COUNT; i=i+1) begin
//            assign addr[i]       = _addr[(i+1)*ADDR_WIDTH-1:i*ADDR_WIDTH];
//            assign write_data[i] = _write_data[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH];
//            assign write_mask[i] = _write_mask[(i+1)*DATA_WIDTH_BYTE-1:i*DATA_WIDTH_BYTE];
//            assign _read_data[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] = read_data[i];
//        end
//    endgenerate
    
//    integer j;
//    always @(posedge CLK or posedge RST) begin
//        send_flag <= 0;
//        recv_flag <= 0;
//        done <= 0;
//        if (RST) begin
//            busy <= 0;
//            for(j=0; j<PORT_COUNT; j=j+1) begin
//                read_data[j] <= 0;
//                pending_flag[j] <= 0;
//                pending_addr[j] <= 0;
//                pending_write_data[j] <= 0;
//                pending_write_mask[j] <= 0;
//            end
//        end else begin
//            if (queue[1]) begin
                
//            else end
//        end
//    end
//endmodule
