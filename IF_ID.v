`timescale 1ns / 1ps
`include "config.vh"

module IF_ID(

    input CLK,
    input RST,

    //来自控制模块的信息
    input [5:0] stall,
    input jmp_flag,

    input [`ADDR_WIDTH] if_pc,
    input [`INST_WIDTH] if_inst,
    output reg[`ADDR_WIDTH] id_pc,
    output reg[`INST_WIDTH] id_inst
);
    reg jmp;
    always @ (posedge CLK or posedge RST) begin
        if (RST) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            jmp <= 1'b0;
        end else if (stall[1] == 1 && jmp_flag) begin 
            jmp <= 1'b1;
        end else if((stall[1] == 1 && stall[2] == 0)) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;    
        end else if(stall[1] == 0 && jmp) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;    
            jmp <= 1'b0;
        end else if (stall[1] == 0) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end
endmodule