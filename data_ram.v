`include "config.vh"

module data_ram(

    input CLK,
    input read_op,
    input write_op,
    input [`ADDR_WIDTH]    addr,
    input [3:0]            mask,
    input [`DATA_WIDTH]       data_i,
    output reg[`DATA_WIDTH]   data_o
    
);

    reg[`DATA_WIDTH]  data_mem[0:`DataMemNum-1];

    always @ (posedge CLK) begin
        if(write_op) begin
            if (mask[3] == 1'b1) begin
                data_mem[addr[`DataMemNumLog2+1:2]][31:24] <= data_i[31:24];
            end
            if (mask[2] == 1'b1) begin
                data_mem[addr[`DataMemNumLog2+1:2]][23:16] <= data_i[23:16];
            end
            if (mask[1] == 1'b1) begin
                data_mem[addr[`DataMemNumLog2+1:2]][15:8] <= data_i[15:8];
            end
            if (mask[0] == 1'b1) begin
                data_mem[addr[`DataMemNumLog2+1:2]][7:0] <= data_i[7:0];
            end                       
        end
    end
    
    always @ (*) begin
        if(read_op) begin
            data_o <= data_mem[addr[`DataMemNumLog2+1:2]];
        end else begin
            data_o <= `ZeroWord;
        end
    end        
endmodule
