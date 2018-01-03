`timescale 1ns / 1ps
`include "config.vh"

module EX(
    input RST,

    //from id module
    input [`ALU_OP_WIDTH] AluOP,
    input [`DATA_WIDTH]   src1,
    input [`DATA_WIDTH]   src2,
    input [`REG_WIDTH]    rd,
    input                 rd_op,
    input [`DATA_WIDTH]   inst_i,
    input [`DATA_WIDTH]   mem_wdata_i,


    input [`DATA_WIDTH]   link_address_i,
    input                 is_in_delayslot_i,    

    output reg[`REG_WIDTH]     rd_o,
    output reg                 rd_op_o,
    output reg[`DATA_WIDTH]    rd_data,
    output wire[`DATA_WIDTH]   mem_wdata_o,

    output wire[`ALU_OP_WIDTH] AluOP_o,
    output reg[`DATA_WIDTH]    mem_addr_o,

    output reg                 stallreq  
    );
    assign AluOP_o = AluOP;
    assign mem_wdata_o = src2;
    wire [`DATA_WIDTH] load_addr;
    wire [`DATA_WIDTH] store_addr;
    assign load_addr = {{20{inst_i[31]}}, inst_i[31:20]};
    assign store_addr = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};

    always @(*) begin
        if(RST) begin
            rd_o       <= `ZeroReg;
            rd_op_o    <= 0'b0;
            rd_data    <= `ZeroWord;
            mem_addr_o <= `ZeroWord;
        end else begin
            rd_o     <= rd;
            rd_op_o  <= rd_op;
            stallreq <= 1'b0;
            case(AluOP)
                `ALU_LUI  :   rd_data <= src1;
                `ALU_AUIPC:   rd_data <= src1 + src2;
                `ALU_ADD  :   rd_data <= src1 + src2;
                `ALU_SUB  :   rd_data <= src1 - src2;
                `ALU_AND  :   rd_data <= src1 & src2;
                `ALU_OR   :   rd_data <= src1 | src2;
                `ALU_XOR  :   rd_data <= src1 ^ src2;
                `ALU_SLL  :   rd_data <= src1 << src2[4:0];
                `ALU_SRL  :   rd_data <= src1 >> src2[4:0];
                `ALU_SRA  :   rd_data <= $signed(src1) >>> src2[4:0];
                `ALU_SEQ  :   rd_data <= src1 == src2 ? 32'b1 : 32'b0;
                `ALU_SLT  :   rd_data <= $signed(src1) < $signed(src2) ? 32'b1 : 32'b0;
                `ALU_SLTU :   rd_data <= src1 < src2 ? 32'b1 : 32'b0;
                // load
                `ALU_LB   :   mem_addr_o <= src1 + load_addr;
                `ALU_LH   :   mem_addr_o <= src1 + load_addr;
                `ALU_LW   :   mem_addr_o <= src1 + load_addr;
                `ALU_LBU  :   mem_addr_o <= src1 + load_addr;
                `ALU_LHU  :   mem_addr_o <= src1 + load_addr;
                // store
                `ALU_SB   :   mem_addr_o <= src1 + store_addr;
                `ALU_SH   :   mem_addr_o <= src1 + store_addr;
                `ALU_SW   :   mem_addr_o <= src1 + store_addr;
                default   :   rd_data <= link_address_i;
            endcase
        end
    end
endmodule
