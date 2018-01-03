`include "config.vh"

module data_ram(

    input CLK,
    input read_op,
    input write_op,
    input [`ADDR_WIDTH]       addr,
    // input [3:0]               mask[`DATA_COLS],
    input [255:0]       data_i,
    output reg[255:0]   data_o
    
);

    reg [`DATA_WIDTH] data_mem[0:`DataMemNum-1];
    wire[`DATA_WIDTH] _addr = addr[`DataMemNumLog2+1:2];

    always @ (posedge CLK) begin
        if(write_op) begin
            data_mem[_addr + 0] <= data_i[31:0];
            data_mem[_addr + 1] <= data_i[63:32];
            data_mem[_addr + 2] <= data_i[95:64];
            data_mem[_addr + 3] <= data_i[127:96];
            data_mem[_addr + 4] <= data_i[159:128];
            data_mem[_addr + 5] <= data_i[191:160];
            data_mem[_addr + 6] <= data_i[223:192];
            data_mem[_addr + 7] <= data_i[255:224];
        end
    end
    
    integer j;
    always @ (*) begin
        if(read_op) begin
            data_o[31:0]    <= data_mem[_addr + 0];
            data_o[63:32]   <= data_mem[_addr + 1];
            data_o[95:64]   <= data_mem[_addr + 2];
            data_o[127:96]  <= data_mem[_addr + 3];
            data_o[159:128] <= data_mem[_addr + 4];
            data_o[191:160] <= data_mem[_addr + 5];
            data_o[223:192] <= data_mem[_addr + 6];
            data_o[255:224] <= data_mem[_addr + 7];
        end else begin
            data_o[31:0]    <= `ZeroWord;
            data_o[63:32]   <= `ZeroWord;
            data_o[95:64]   <= `ZeroWord;
            data_o[127:96]  <= `ZeroWord;
            data_o[159:128] <= `ZeroWord;
            data_o[191:160] <= `ZeroWord;
            data_o[223:192] <= `ZeroWord;
            data_o[255:224] <= `ZeroWord;
        end
    end        
endmodule
