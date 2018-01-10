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
    input [`BENCH_WIDTH]      mem_data_i,
    output reg [`BENCH_WIDTH] mem_data_o,
    output reg [15:0]         mem_mask,

    input                     mem_busy,
    input                     mem_done,

    output wire busy
    
);

    wire [`TAG_WIDTH]    tag    = addr[31:10];
    wire [`INDEX_WIDTH]  index  = addr[9:4]; 
    wire [`SELECT_WIDTH] select = addr[3:0];
    reg  [`DATA_WIDTH]   cache_data [`DATA_ROW_WIDTH][`SET_WIDTH][`DATA_COL_WIDTH];
    reg  [`TAG_WIDTH]    cache_tag  [`DATA_ROW_WIDTH][`SET_WIDTH];
    reg                  cache_valid[`DATA_ROW_WIDTH][`SET_WIDTH];
    reg                  cache_dirty[`DATA_ROW_WIDTH][`SET_WIDTH];
    reg                  cache_LRU  [`DATA_ROW_WIDTH];
    reg [`ADDR_WIDTH]    read_addr;
    wire [1:0] hit = (write_op == 1'b0 && read_op == 1'b0) ? 2'b11 :
                     (cache_valid[index][0] && cache_tag[index][0] == tag) ? 2'b00 :
                     (cache_valid[index][1] && cache_tag[index][1] == tag) ? 2'b01 : 2'b10;
    wire set = cache_LRU[index] ^ 1;
    reg reading;
    reg writedone;
    // assign busy = (hit == 2'b10 || ) ? 1'b1 : 1'b0;
    // assign busy = 0;
    assign busy = (read_op && hit == 2'b10) ? 1'b1 : (mem_busy);
    reg tmp_busy;
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
            mem_write    <=  1'b0;
            mem_read     <=  1'b0;
            tmp_busy     <=  1'b0;
            read_addr    <=  `ZeroWord;
            reading      <=  1'b0;
        end else begin
            if (write_op) begin
                if (addr < 4096) begin
                    mem_write   <=   1'b1;
                    mem_addr    <=   addr;
                    mem_mask    <=   16'd0;
                    mem_data_o[31:0]    <= `ZeroWord;
                    mem_data_o[63:32]   <= `ZeroWord;  
                    mem_data_o[95:64]   <= `ZeroWord;
                    mem_data_o[127:96]  <= `ZeroWord;
                    case(addr[1:0])
                        2'b00: begin
                            mem_data_o[31:0]    <= data_i;
                            mem_mask[3:0]       <= mask;
                        end
                        2'b01: begin
                            mem_data_o[63:32]    <= data_i;
                            mem_mask[7:4]       <= mask;
                        end
                        2'b10: begin
                            mem_data_o[95:64]    <= data_i;
                            mem_mask[11:8]       <= mask;
                        end
                        2'b11: begin
                            mem_data_o[127:96]    <= data_i;
                            mem_mask[15:12]       <= mask;
                        end
                    endcase
                    tmp_busy            <= 1'b1;
                end else if (hit < 2'b10) begin
                    if (mask[3] == 1'b1) begin
                        cache_data[index][hit][select[3:2]][31:24] <= data_i[31:24];
                    end
                    if (mask[2] == 1'b1) begin
                        cache_data[index][hit][select[3:2]][23:16] <= data_i[23:16];
                    end
                    if (mask[1] == 1'b1) begin
                        cache_data[index][hit][select[3:2]][15:8]  <= data_i[15:8];
                    end
                    if (mask[0] == 1'b1) begin
                        cache_data[index][hit][select[3:2]][7:0]   <= data_i[7:0];
                    end
                    cache_LRU[index]         <= hit;
                    cache_dirty[index][hit]  <= 1'b1;
                end
            end
            else begin
                mem_write    <=  1'b0;
                if (tmp_busy && mem_done) tmp_busy <= 1'b0;
            end
        end
    end

    always @(CLK) begin
        if (hit == 2'b10 && addr >= 4096) begin
            mem_read    <=   1'b1;
            mem_addr    <=   {addr[31:4], 4'b0000};
            read_addr   <=   addr;
            reading     <=   1'b1;
            if (cache_dirty[index][set]) begin
                mem_write   <=   1'b1;
                mem_mask    <=   16'hffff;
                mem_data_o[31:0]    <= cache_data[index][set][0];
                mem_data_o[63:32]   <= cache_data[index][set][1];
                mem_data_o[95:64]   <= cache_data[index][set][2];
                mem_data_o[127:96]  <= cache_data[index][set][3];
                // mem_data_o[159:128] <= cache_data[index][set][4];
                // mem_data_o[191:160] <= cache_data[index][set][5];
                // mem_data_o[223:192] <= cache_data[index][set][6];
                // mem_data_o[255:224] <= cache_data[index][set][7];
            end else begin
                mem_write   <=   1'b0;
                mem_mask    <=   16'd0;
                mem_data_o[31:0]    <= `ZeroWord;
                mem_data_o[63:32]   <= `ZeroWord;
                mem_data_o[95:64]   <= `ZeroWord;
                mem_data_o[127:96]  <= `ZeroWord;
                // mem_data_o[159:128] <= `ZeroWord;
                // mem_data_o[191:160] <= `ZeroWord;
                // mem_data_o[223:192] <= `ZeroWord;
                // mem_data_o[255:224] <= `ZeroWord;
            end
            if (mem_done && reading && !tmp_busy) begin
                cache_data[index][set][0] <= mem_data_i[31:0];
                cache_data[index][set][1] <= mem_data_i[63:32];
                cache_data[index][set][2] <= mem_data_i[95:64];
                cache_data[index][set][3] <= mem_data_i[127:96];
                // cache_data[index][set][4] <= mem_data_i[159:128];
                // cache_data[index][set][5] <= mem_data_i[191:160];
                // cache_data[index][set][6] <= mem_data_i[223:192];
                // cache_data[index][set][7] <= mem_data_i[255:224];
                cache_valid[index][set]   <= 1'b1;
                cache_tag[index][set]     <= tag;
                cache_dirty[index][set]   <= 1'b0;
                mem_read    <=   1'b0;
                mem_addr    <=   `ZeroWord;
                read_addr   <=   `ZeroWord;
                reading     <=   1'b0;
            end
        end
        else if (addr >= 4096) begin
            mem_read    <=   1'b0;
            mem_write   <=   1'b0;
            mem_addr    <=    `ZeroWord;
            mem_data_o[31:0]    <= `ZeroWord;
            mem_data_o[63:32]   <= `ZeroWord;
            mem_data_o[95:64]   <= `ZeroWord;
            mem_data_o[127:96]  <= `ZeroWord;
            // mem_data_o[159:128] <= `ZeroWord;
            // mem_data_o[191:160] <= `ZeroWord;
            // mem_data_o[223:192] <= `ZeroWord;
            // mem_data_o[255:224] <= `ZeroWord;
        end
    end
    
    always @ (*) begin
        if(read_op) begin
            if (hit < 2'b10) begin
                data_o           = cache_data[index][hit][select[3:2]];
                cache_LRU[index] = hit;
            end 
        end else begin
            data_o = `ZeroWord;
        end
    end

endmodule
