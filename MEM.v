`include "config.vh"

module mem(

    input RST,
    
    input [`REG_WIDTH]      rd,
    input                   rd_op,
    input [`DATA_WIDTH]     rd_data,

    input [`ALU_OP_WIDTH]   AluOP,
    input [`ADDR_WIDTH]     mem_addr,
    input [`DATA_WIDTH]     mem_wdata_i,
    
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
                `ALU_LB: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b0;
                    mem_read   <= 1'b1;
                    mem_mask   <= 4'b0000;
                    mem_wdata  <= `ZeroWord;
                    case (mem_addr[1:0])
                        2'b00: rd_data_o  <= {{24{mem_data[7]}}, mem_data[7:0]};
                        2'b01: rd_data_o  <= {{24{mem_data[15]}}, mem_data[15:8]};
                        2'b10: rd_data_o  <= {{24{mem_data[23]}}, mem_data[23:16]};
                        2'b11: rd_data_o  <= {{24{mem_data[31]}}, mem_data[31:24]};
                    endcase
                end
                `ALU_LBU: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b0;
                    mem_read   <= 1'b1;
                    mem_mask   <= 4'b0000;
                    mem_wdata  <= `ZeroWord;
                    case (mem_addr[1:0])
                        2'b00: rd_data_o  <= {24'b0, mem_data[7:0]};
                        2'b01: rd_data_o  <= {24'b0, mem_data[15:8]};
                        2'b10: rd_data_o  <= {24'b0, mem_data[23:16]};
                        2'b11: rd_data_o  <= {24'b0, mem_data[31:24]};
                    endcase
                end
                `ALU_LH: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b0;
                    mem_read   <= 1'b1;
                    mem_mask   <= 4'b0000;
                    mem_wdata  <= `ZeroWord;
                    case (mem_addr[1:0])
                        2'b00: rd_data_o  <= {{16{mem_data[15]}}, mem_data[15:0]};
                        2'b10: rd_data_o  <= {{16{mem_data[31]}}, mem_data[31:16]};
                    endcase
                end
                `ALU_LHU: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b0;
                    mem_read   <= 1'b1;
                    mem_mask   <= 4'b0000;
                    mem_wdata  <= `ZeroWord;
                    case (mem_addr[1:0])
                        2'b00: rd_data_o  <= {16'b0, mem_data[15:0]};
                        2'b10: rd_data_o  <= {16'b0, mem_data[31:16]};
                    endcase
                end
                `ALU_LW: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b0;
                    mem_read   <= 1'b1;
                    mem_mask   <= 4'b0000;
                    mem_wdata  <= `ZeroWord;
                    rd_data_o  <= mem_data;
                end
                `ALU_SB: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b1;
                    mem_read   <= 1'b0;
                    mem_mask   <= 1'b1 << mem_addr[1:0];
                    mem_wdata  <= mem_wdata_i << mem_addr[1:0];
                    rd_data_o  <= `ZeroWord;
                end
                `ALU_SH: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b1;
                    mem_read   <= 1'b0;
                    mem_mask   <= 2'b11 << mem_addr[1:0];
                    mem_wdata  <= mem_wdata_i << mem_addr[1:0];
                    rd_data_o  <= `ZeroWord;
                end
                `ALU_SW: begin
                    mem_addr_o <= {mem_addr[31:2], 2'b00};
                    mem_write  <= 1'b1;
                    mem_read   <= 1'b0;
                    mem_mask   <= 4'b1111;
                    mem_wdata  <= mem_wdata_i;
                    rd_data_o  <= `ZeroWord;
                end
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