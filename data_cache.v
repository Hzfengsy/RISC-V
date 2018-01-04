`include "config.vh"

module data_cache(

    input CLK,
    input RST,
    input read_op,
    input write_op,
    input [`ADDR_WIDTH]       addr,
    input [3:0]               mask,
    input [`DATA_WIDTH]       data_i,
    output reg[`DATA_WIDTH]   data_o,

    output reg                mem_read,
    output reg                mem_write,
    output reg [`ADDR_WIDTH]  mem_addr,
    input [255:0]       mem_data_i,
    output reg [255:0]  mem_data_o,

    output wire busy
);

    wire [`TAG_WIDTH]    tag    = addr[31:10];
    wire [`INDEX_WIDTH]  index  = addr[9:5]; 
    wire [`SELECT_WIDTH] select = addr[4:0];
    reg  [`DATA_WIDTH]   cache_data [`DATA_ROW_WIDTH][`SET_WIDTH][`DATA_COL_WIDTH];
    reg  [`TAG_WIDTH]    cache_tag  [`DATA_ROW_WIDTH][`SET_WIDTH];
    reg                  cache_valid[`DATA_ROW_WIDTH][`SET_WIDTH];
    reg                  cache_dirty[`DATA_ROW_WIDTH][`SET_WIDTH];
    reg                  cache_LRU  [`DATA_ROW_WIDTH];
    wire [1:0] hit = (write_op == 1'b0 && read_op == 1'b0) ? 2'b11 :
                     (cache_valid[index][0] && cache_tag[index][0] == tag) ? 2'b00 :
                     (cache_valid[index][1] && cache_tag[index][1] == tag) ? 2'b01 : 2'b10;
    wire set = cache_LRU[index] ^ 1;
    reg first_step;
    assign busy = (hit == 2'b10) ? 1'b1 : 1'b0;
    integer i;
    integer j;
    integer k;
    
    always @ (posedge CLK) begin
        if (RST) begin
            for (i = 0; i < `DATA_ROWS; i = i + 1) begin
                for (j = 0; j < `SET_NUM; j = j + 1) begin
                    cache_valid[i][j] <= 0;
                    cache_dirty[i][j] <= 0;
                    cache_LRU  [i]    <= 0;
                end
            end
            first_step   <=  1'b1;
        end else begin
            if (hit == 2'b10) begin
                if (first_step) begin
                    mem_read    <=   1'b1;
                    mem_addr    <=   {addr[31:5], 5'b00000};
                    first_step  <=   1'b0;
                    if (cache_dirty[index][set]) begin
                        mem_write   <=   1'b1;
                        mem_data_o[31:0]    <= cache_data[index][set][0];
                        mem_data_o[63:32]   <= cache_data[index][set][1];
                        mem_data_o[95:64]   <= cache_data[index][set][2];
                        mem_data_o[127:96]  <= cache_data[index][set][3];
                        mem_data_o[159:128] <= cache_data[index][set][4];
                        mem_data_o[191:160] <= cache_data[index][set][5];
                        mem_data_o[223:192] <= cache_data[index][set][6];
                        mem_data_o[255:224] <= cache_data[index][set][7];
                    end else begin
                        mem_write   <=   1'b0;
                        mem_data_o[31:0]    <= `ZeroWord;
                        mem_data_o[63:32]   <= `ZeroWord;
                        mem_data_o[95:64]   <= `ZeroWord;
                        mem_data_o[127:96]  <= `ZeroWord;
                        mem_data_o[159:128] <= `ZeroWord;
                        mem_data_o[191:160] <= `ZeroWord;
                        mem_data_o[223:192] <= `ZeroWord;
                        mem_data_o[255:224] <= `ZeroWord;
                    end
                end else begin
                    cache_data[index][set][0] <= mem_data_i[31:0];
                    cache_data[index][set][1] <= mem_data_i[63:32];
                    cache_data[index][set][2] <= mem_data_i[95:64];
                    cache_data[index][set][3] <= mem_data_i[127:96];
                    cache_data[index][set][4] <= mem_data_i[159:128];
                    cache_data[index][set][5] <= mem_data_i[191:160];
                    cache_data[index][set][6] <= mem_data_i[223:192];
                    cache_data[index][set][7] <= mem_data_i[255:224];
                    cache_valid[index][set]   <= 1'b1;
                    cache_tag[index][set]     <= tag;
                    cache_dirty[index][set]   <= 1'b0;
                    mem_read    <=   1'b0;
                    mem_addr    <=    `ZeroWord;
                    first_step  <=   1'b1;
                end
            end
            else begin
                mem_read    <=   1'b0;
                mem_write   <=   1'b0;
                mem_addr    <=    `ZeroWord;
                mem_data_o[31:0]    <= `ZeroWord;
                mem_data_o[63:32]   <= `ZeroWord;
                mem_data_o[95:64]   <= `ZeroWord;
                mem_data_o[127:96]  <= `ZeroWord;
                mem_data_o[159:128] <= `ZeroWord;
                mem_data_o[191:160] <= `ZeroWord;
                mem_data_o[223:192] <= `ZeroWord;
                mem_data_o[255:224] <= `ZeroWord;
            end
            if (write_op) begin
                if (hit < 2'b10) begin
                    if (mask[3] == 1'b1) begin
                        cache_data[index][hit][select[4:2]][31:24] <= data_i[31:24];
                    end
                    if (mask[2] == 1'b1) begin
                        cache_data[index][hit][select[4:2]][23:16] <= data_i[23:16];
                    end
                    if (mask[1] == 1'b1) begin
                        cache_data[index][hit][select[4:2]][15:8]  <= data_i[15:8];
                    end
                    if (mask[0] == 1'b1) begin
                        cache_data[index][hit][select[4:2]][7:0]   <= data_i[7:0];
                    end
                    cache_LRU[index]         <= hit;
                    cache_dirty[index][hit]  <= 1'b1;
                end
            end
        end
    end
    
    always @ (*) begin
        if(read_op) begin
            if (hit < 2'b10) begin
                data_o           = cache_data[index][hit][select[4:2]];
                cache_LRU[index] = hit;
            end 
        end else begin
            data_o = `ZeroWord;
        end
    end

endmodule
