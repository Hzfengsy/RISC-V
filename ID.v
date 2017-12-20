`timescale 1ns / 1ps
`include "config.vh"

module ID
(
    input RST,
    input [`ADDR_WIDTH] addr, 
    input [`INST_WIDTH] inst_i,
    input [`DATA_WIDTH] reg1_data, 
    input [`DATA_WIDTH] reg2_data,

    //solve load problem
    input [`ALU_OP_WIDTH] ex_aluop,

    input               ex_reg_op,
	input [`DATA_WIDTH] ex_data,
	input [`REG_WIDTH]  ex_rd,

    //to mem step
    input               mem_reg_op,
	input [`DATA_WIDTH] mem_data,
	input [`REG_WIDTH]  mem_rd,

    //when last inst is branch or jmp
    input is_in_delayslot_i,

    //send to regs
    output reg [1:0]        reg1_op,               //0-Zero, 1-reg, 2-imm, 3-pc
    output reg [1:0]        reg2_op,
    output reg [`REG_WIDTH] reg1_addr,
    output reg [`REG_WIDTH] reg2_addr,

    output reg [`ALU_OP_WIDTH] ALU_op,
    output reg [`DATA_WIDTH]   src_1,
    output reg [`DATA_WIDTH]   src_2,
    output reg [`REG_WIDTH]    rd,
    output reg                 write_op,
    output wire[`DATA_WIDTH]   inst_o,

    output reg                 next_inst_in_delayslot,
	output reg                 branch_flag,
	output reg[`DATA_WIDTH]    branch_target_address,       
	output reg[`DATA_WIDTH]    link_addr,
	output reg                 is_in_delayslot_o,
	output wire                stallreq
);
    
    reg instvalid;
    wire[`DATA_WIDTH] pc_plus_8;
    wire[`DATA_WIDTH] pc_plus_4;
    wire[`DATA_WIDTH] imm_JAL;
    reg [`DATA_WIDTH] imm;
    wire [6:0] funct7 = inst_i[31:25];
    wire [2:0] funct3 = inst_i[14:12];
    wire [6:0] opcode = inst_i[6:0];
    wire [`REG_WIDTH] rs1 = inst_i[19:15];
    wire [`REG_WIDTH] rs2 = inst_i[24:20];
    wire [`REG_WIDTH] rd_ = inst_i[11:7];

    reg stallreq_for_reg1_loadrelate;
    reg stallreq_for_reg2_loadrelate;
    wire pre_inst_is_load;

    assign pc_plus_8 = addr + 8;
    assign pc_plus_4 = addr + 4;
    assign imm_JAL = {11'b0, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};  
    assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;

    //assign pre_inst_is_load = 
    assign inst_o = inst_i;

    

    always @(*) begin
        if (RST) begin
            ALU_op                 <= `ALU_NOP;
			rd                     <= 5'b00000;
			write_op               <= 1'b0;
			instvalid              <= 1;
			reg1_op                <= `Zero_OP;
			reg2_op                <= `Zero_OP;
			reg1_addr              <= 5'b00000;
			reg2_addr              <= 5'b00000;
			imm                    <= 32'h0;	
			link_addr              <= `ZeroWord;
			branch_target_address  <= `ZeroWord;
			branch_flag            <= 1'b0;
			next_inst_in_delayslot <= 1'b0;	
        end else begin
            case (opcode)
                `OP_LUI: begin
                    ALU_op                 <= `ALU_LUI;
			        rd                     <= rd_;
			        write_op               <= 1'b1;
			        instvalid              <= 1;
			        reg1_op                <= `Imm_OP;
			        reg2_op                <= `Zero_OP;
			        reg1_addr              <= 1'b00000;
			        reg2_addr              <= `ZeroReg;
			        imm                    <= {inst_i[31:12], 12'd0};	
			        link_addr              <= `ZeroWord;
			        branch_target_address  <= `ZeroWord;
			        branch_flag            <= 1'b0;
			        next_inst_in_delayslot <= 1'b0;
                end
                `OP_AUIPC: begin
                    ALU_op                 <= `ALU_AUIPC;
			        rd                     <= rd_;
			        write_op               <= 1'b1;
			        instvalid              <= 1;
			        reg1_op                <= `Imm_OP;
			        reg2_op                <= `PC_OP;
			        reg1_addr              <= 1'b00000;
			        reg2_addr              <= `ZeroReg;
			        imm                    <= {inst_i[31:12], 12'd0};	
			        link_addr              <= `ZeroWord;
			        branch_target_address  <= `ZeroWord;
			        branch_flag            <= 1'b0;
			        next_inst_in_delayslot <= 1'b0;
                end
                `OP_JAL: begin
                    ALU_op                 <= `ALU_JMP;
			        rd                     <= rd_;
			        write_op               <= 1'b1;
			        instvalid              <= 1;
			        reg1_op                <= `Zero_OP;
			        reg2_op                <= `Zero_OP;
			        reg1_addr              <= `ZeroReg;
			        reg2_addr              <= `ZeroReg;
			        imm                    <= `ZeroWord;	
			        link_addr              <= pc_plus_4;
			        branch_target_address  <= addr + imm_JAL;
			        branch_flag            <= 1'b1;
			        next_inst_in_delayslot <= 1'b0;

                end
                `OP_JALR: begin
                    ALU_op                 <= `ALU_JMP;
			        rd                     <= rd_;
			        write_op               <= 1'b1;
			        instvalid              <= 1;
			        reg1_op                <= `Reg_OP;
			        reg2_op                <= `Zero_OP;
			        reg1_addr              <= rs1;
			        reg2_addr              <= `ZeroReg;
			        imm                    <= `ZeroWord;	
			        link_addr              <= pc_plus_4;
			        branch_target_address  <= reg1_data + {20'd0, inst_i[31:20]};
			        branch_flag            <= 1'b1;
			        next_inst_in_delayslot <= 1'b0;
                end

                `OP_OP_IMM: begin
                    rd                     <= rd_;
			        write_op               <= 1'b1;
			        instvalid              <= 1;
			        reg1_op                <= `Reg_OP;
			        reg2_op                <= `Imm_OP;
			        reg1_addr              <= rs1;
			        reg2_addr              <= `ZeroReg;
			        link_addr              <= `ZeroWord;
			        branch_target_address  <= `ZeroWord;
			        branch_flag            <= 1'b0;
			        next_inst_in_delayslot <= 1'b0;
                    case (funct3)
                        `FUNCT3_ADDI: begin
                            ALU_op                 <= `ALU_ADD;
                            imm                    <= {20'd0, inst_i[31:20]};	
                        end
                        `FUNCT3_SLTI: begin
                            ALU_op                 <= `ALU_SLT;
                            imm                    <= {20'd0, inst_i[31:20]};	
                        end
                        `FUNCT3_SLTIU: begin
                            ALU_op                 <= `ALU_SLTU;
                            imm                    <= {20'd0, inst_i[31:20]};	
                        end
                        `FUNCT3_XORI: begin
                            ALU_op                 <= `ALU_XOR;
                            imm                    <= {20'd0, inst_i[31:20]};	
                        end
                        `FUNCT3_ORI: begin
                            ALU_op                 <= `ALU_OR;
                            imm                    <= {20'd0, inst_i[31:20]};	
                        end
                        `FUNCT3_ANDI: begin
                            ALU_op                 <= `ALU_AND;
                            imm                    <= {20'd0, inst_i[31:20]};	
                        end
                        `FUNCT3_SLLI: begin
                            ALU_op                 <= `ALU_SLL;
                            imm                    <= {27'd0, inst_i[24:20]};	
                        end
                        `FUNCT3_SRLI_SRAI: begin
                            case (funct7)
                                `FUNCT7_SRLI :     ALU_op <= `ALU_SRL;
                                `FUNCT7_SRAI :     ALU_op <= `ALU_SRA;
                            endcase
                            imm                    <= {27'd0, inst_i[24:20]};
                        end
                    endcase
                end

                `OP_OP: begin
                    rd                     <= rd_;
			        write_op               <= 1'b1;
			        instvalid              <= 1;
			        reg1_op                <= `Reg_OP;
			        reg2_op                <= `Reg_OP;
			        reg1_addr              <= rs1;
			        reg2_addr              <= rs2;
                    imm                    <= `ZeroWord;
			        link_addr              <= `ZeroWord;
			        branch_target_address  <= `ZeroWord;
			        branch_flag            <= 1'b0;
			        next_inst_in_delayslot <= 1'b0;
                    case (funct3)
                        `FUNCT3_ADD_SUB: begin
                            case (funct7)
                                `FUNCT7_ADD :     ALU_op <= `ALU_ADD;
                                `FUNCT7_SUB :     ALU_op <= `ALU_SUB;
                            endcase
                        end
                        `FUNCT3_SLL: begin
                            ALU_op                 <= `ALU_SLL;
                        end
                        `FUNCT3_SLT: begin
                            ALU_op                 <= `ALU_SLT;
                        end
                        `FUNCT3_SLTU: begin
                            ALU_op                 <= `ALU_SLTU;
                        end
                        `FUNCT3_XOR: begin
                            ALU_op                 <= `ALU_XOR;
                        end
                        `FUNCT3_OR: begin
                            ALU_op                 <= `ALU_OR;
                        end
                        `FUNCT3_AND: begin
                            ALU_op                 <= `ALU_AND;
                        end
                        `FUNCT3_SRL_SRA: begin
                            case (funct7)
                                `FUNCT7_SRL :     ALU_op <= `ALU_SRL;
                                `FUNCT7_SRA :     ALU_op <= `ALU_SRA;
                            endcase
                        end
                    endcase
                end
                default: begin
                    ALU_op                 <= `ALU_NOP;
                    rd                     <= 5'b00000;
                    write_op               <= 1'b0;
                    instvalid              <= 1;
                    reg1_op                <= 2'b00;
                    reg2_op                <= 2'b00;
                    reg1_addr              <= 5'b00000;
                    reg2_addr              <= 5'b00000;
                    imm                    <= 32'h0;    
                    link_addr              <= `ZeroWord;
                    branch_target_address  <= `ZeroWord;
                    branch_flag            <= 1'b0;
                    next_inst_in_delayslot <= 1'b0;    
                end    
            endcase
        end
    end

    // always @(*) begin
    //     stallreq_for_reg1_loadrelate <= 1'b0;
    //     if (RST) begin
    //         src_1 <= `ZeroWrod;
    //     end else if (pre_inst_is_load && ex_reg_op == reg1_addr && reg1_op) begin
	// 	    stallreq_for_reg1_loadrelate <= 1'b1;
    //     end else if (reg1_op && ex_reg_op && (ex_rd == reg1_addr)) begin
	// 		src_1 <= ex_data;
    //     end else if (reg1_op && mem_reg_op && (mem_rd == reg1_addr)) begin
	// 		src_1 <= mem_data;
    //     end else if (reg1_op) begin
    //         src_1 <= reg1_data;
    //     end else if (!reg1_op) begin
    //         src_1 <= imm;
    //     end
    // end

    always @(*) begin
        stallreq_for_reg1_loadrelate <= 1'b0;
        if (RST) begin
            src_1 <= `ZeroReg;
        end else begin
            case (reg1_op)
                `Zero_OP: begin
                    src_1 <= `ZeroWord;
                end
                `Reg_OP: begin
                    if (pre_inst_is_load && ex_reg_op == reg1_addr) begin
                        stallreq_for_reg1_loadrelate <= 1'b1;
                    end else if (ex_reg_op && (ex_rd == reg1_addr)&& (reg1_addr != `ZeroReg)) begin
                        src_1 <= ex_data;
                    end else if (mem_reg_op && (mem_rd == reg1_addr)&& (reg1_addr != `ZeroReg)) begin
                        src_1 <= mem_data;
                    end else begin
                        src_1 <= reg1_data;
                    end
                end
                `Imm_OP: begin
                    src_1 <= imm;
                end
                `PC_OP: begin
                    src_1 <= addr;
                end
            endcase
		end
    end

    always @(*) begin
        stallreq_for_reg2_loadrelate <= 1'b0;
        if (RST) begin
            src_2 <= `ZeroReg;
        end else begin
            case (reg2_op)
                `Zero_OP: begin
                    src_2 <= `ZeroWord;
                end
                `Reg_OP: begin
                    if (pre_inst_is_load && ex_reg_op == reg2_addr) begin
                        stallreq_for_reg2_loadrelate <= 1'b1;
                    end else if (ex_reg_op && (ex_rd == reg2_addr) && (reg2_addr != `ZeroReg)) begin
                        src_2 <= ex_data;
                    end else if (mem_reg_op && (mem_rd == reg2_addr)&& (reg2_addr != `ZeroReg)) begin
                        src_2 <= mem_data;
                    end else begin
                        src_2 <= reg2_data;
                    end
                end
                `Imm_OP: begin
                    src_2 <= imm;
                end
                `PC_OP: begin
                    src_2 <= addr;
                end
            endcase
		end
    end

    always @(*) begin
		if(RST) begin
			is_in_delayslot_o <= 1'b0;
		end else begin
		    is_in_delayslot_o <= is_in_delayslot_i;		
	  end
	end

endmodule
