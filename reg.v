`timescale 1ns / 1ps
`include "config.vh"

module regist
(
    input CLK,
    input RST,
    input [1:0] read_op1, 
    input [1:0] read_op2,
    input [`REG_WIDTH] read_addr1, 
    input [`REG_WIDTH] read_addr2,
    input write_op,
    input [`REG_WIDTH] write_addr,
    input [`DATA_WIDTH] write_data,
    output reg [`DATA_WIDTH] read_data1, 
    output reg [`DATA_WIDTH] read_data2
);
    reg [`DATA_WIDTH] reg_val[31:0];
    integer i;
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            for (i = 0; i < 32; i = i + 1) begin
                reg_val[i] <= `ZeroWord;
            end
        end else begin
            if (write_op && write_addr != `ZeroReg) begin
                reg_val[write_addr] <= write_data;
            end
        end
    end

    always @(*) begin
        if (RST) begin
            read_data1 <= `ZeroWord;
        end else begin
            if (read_op1 != `Zero_OP) begin
                if (write_op && write_addr == read_addr1 && write_addr != `ZeroReg) begin
                    read_data1 <= write_data;
                end else begin
                    read_data1 <= reg_val[read_addr1];
                end
            end else begin
                read_data1 <= `ZeroWord;
            end
        end
    end

    always @(*) begin
        if (RST) begin
            read_data2 <= `ZeroWord;
        end else begin
            if (read_op2 != `Zero_OP) begin
                if (write_op && write_addr == read_addr2 && write_addr != `ZeroReg) begin
                    read_data2 <= write_data;
                end else begin
                    read_data2 <= reg_val[read_addr2];
                end
            end else begin
                read_data2 <= `ZeroWord;
            end
        end
    end
endmodule
