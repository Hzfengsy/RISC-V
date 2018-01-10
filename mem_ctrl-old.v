`include "config.vh"

module mem_ctrl
(
    input CLK,
    input RST,
    input read_op1,
    input read_op2,
    input write_op,
    input [`ADDR_WIDTH] addr1,
    input [`ADDR_WIDTH] addr2,
    input [255:0]       data2_i,
    output reg [255:0]  data1_o,
    output reg [255:0]  data2_o,
    output reg busy1,
    output reg done1,
    output reg busy2,
    output reg done2,

    output wire Tx,
    input Rx
);
    reg mem_read;
    reg mem_write;
    wire mem_busy;
    wire mem_done;
    reg  [`ADDR_WIDTH] mem_addr;
    reg  [255:0]       mem_data_o;
    wire [255:0]       mem_data_i;

    // uart_ctrl uart_ctrl0
    // (
    //     .CLK(CLK),
    //     .RST(RST),
    //     .read_op(mem_read),
    //     .write_op(mem_write),
    //     .addr(mem_addr),
    //     .data_i(mem_data_o),
    //     .data_o(mem_data_i),
    //     .busy(mem_busy),
    //     .done(mem_done),

    //     .Tx(Tx),
    //     .Rx(Rx)
    // );

    

    reg [1:0] pending;
    always @ (*) begin
        if (RST) begin
            pending = 2'b00;
            busy1 = 1'b0;
            done1 = 1'b0;
            busy2 = 1'b0;
            done2 = 1'b0;
        end else begin
            if (mem_busy) begin
                busy1 = 1'b1;
                done1 = 1'b0;
                busy2 = 1'b1;
                done2 = 1'b0;
            end
            else if (mem_done) begin
                if (pending == 2'b01) begin
                    pending = 2'b00;
                    busy1 = 1'b0;
                    done1 = 1'b1;
                    if (read_op1) begin
                        data1_o = mem_data_i;
                    end
                end
                if (pending == 2'b10) begin
                    pending = 2'b00;
                    busy2 = 1'b0;
                    done2 = 1'b1;
                    if (read_op1) begin
                        data2_o = mem_data_i;
                    end
                end
            end
            if (pending == 2'b00) begin
                if (read_op2) begin
                    mem_read   = 1'b1;
                    mem_write  = 1'b0;
                    mem_addr   = addr2;
                    pending    = 2'b10;
                    busy1      = 1'b0;
                    done1      = 1'b0;
                    busy2      = 1'b1;
                    done2      = 1'b0;
                end else if (write_op) begin
                    mem_read   = 1'b0;
                    mem_write  = 1'b1;
                    mem_data_o = data2_i;
                    mem_addr   = addr2;
                    pending    = 2'b10;
                    busy1      = 1'b0;
                    done1      = 1'b0;
                    busy2      = 1'b1;
                    done2      = 1'b0;
                end else if (read_op1) begin
                    mem_read   = 1'b1;
                    mem_write  = 1'b0;
                    mem_addr   = addr1;
                    pending    = 2'b01;
                    busy1      = 1'b1;
                    done1      = 1'b0;
                    busy2      = 1'b0;
                    done2      = 1'b0;
                end
            end
        end
    end
endmodule
