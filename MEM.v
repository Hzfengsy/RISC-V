`include "config.vh"

module mem(

    input RST,
    
    input [`REG_WIDTH]      rd,
    input                   rd_op,
    input [`DATA_WIDTH]     rd_data,

    input [`ALU_OP_WIDTH]   AluOP,
    input [`ADDR_WIDTH]     mem_addr,
    
    //from mem
    input [`DATA_WIDTH]     mem_data,
    
    //to writeback
    output reg[`REG_WIDTH]  rd_o,
    output reg              rd_op_o,
    output reg[`DATA_WIDTH] rd_data_o,
    
    //to mem
    output reg[`DATA_WIDTH] mem_addr_o,
    output reg              mem_write,
    output reg              mem_read,
    output reg[3:0]         mem_mask,
    output reg[`DATA_WIDTH] mem_wdata
);

    always @(*) begin
        if (RST) begin
            rd_o       <= `ZeroReg;
            rd_op_o    <= 1'b0;
            rd_data_o  <= `ZeroWord;
            mem_addr_o <= `ZeroWord;
            mem_write  <= 1'b0;
            mem_read   <= 1'b0;
            mem_mask   <= 4'b0000;
            mem_wdata  <= `ZeroWord;
        end
        else begin
            rd_o    <= rd;
            rd_op_o <= rd_op;
            case (AluOP)
                default: begin
                    rd_data_o  <= rd_data;
                    mem_addr_o <= `ZeroWord;
                    mem_write  <= 1'b0;
                    mem_read   <= 1'b0;
                    mem_mask   <= 4'b0000;
                    mem_wdata  <= `ZeroWord;
                end
            endcase
        end
    end
endmodule