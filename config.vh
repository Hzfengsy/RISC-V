`define INST_WIDTH  31:0
`define ADDR_WIDTH  31:0
`define DATA_WIDTH  31:0
`define REG_WIDTH    4:0
`define ALU_OP_WIDTH 4:0
`define BYTE_WIDTH   7:0

`define DataMemNum 131071
`define InstMemNum 131071
`define DataMemNumLog2 17
`define InstMemNumLog2 17

`define ZeroWord 32'h00000000
`define ZeroReg  5'b00000

`define Zero_OP  2'b00
`define Reg_OP   2'b01
`define Imm_OP   2'b10
`define PC_OP    2'b11

`define ALU_NOP     0
`define ALU_LUI     1
`define ALU_AUIPC   2
`define ALU_JMP     3
`define ALU_BRANCH  4
`define ALU_LB      5
`define ALU_LH      6
`define ALU_LW      7
`define ALU_LBU     8
`define ALU_LHU     9
`define ALU_SB      10
`define ALU_SH      11
`define ALU_SW      12
`define ALU_AND     13
`define ALU_OR      14
`define ALU_ADD     15
`define ALU_XOR     16
`define ALU_SLL     17
`define ALU_SRL     18
`define ALU_SRA     19
`define ALU_SUB     20
`define ALU_SEQ     21
`define ALU_SLT     22
`define ALU_SLTU    23
`define ALU_MEM     24

//==================  Instruction opcode in RISC-V ================== 
`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_OP_IMM   7'b0010011
`define OP_OP       7'b0110011
`define OP_MISC_MEM 7'b0001111

//================== Instruction funct3 in RISC-V ================== 
// JALR
`define FUNCT3_JALR 3'b000
// BRANCH
`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111
// LOAD
`define FUNCT3_LB   3'b000
`define FUNCT3_LH   3'b001
`define FUNCT3_LW   3'b010
`define FUNCT3_LBU  3'b100
`define FUNCT3_LHU  3'b101
// STORE
`define FUNCT3_SB   3'b000
`define FUNCT3_SH   3'b001
`define FUNCT3_SW   3'b010
// OP-IMM
`define FUNCT3_ADDI      3'b000
`define FUNCT3_SLTI      3'b010
`define FUNCT3_SLTIU     3'b011
`define FUNCT3_XORI      3'b100
`define FUNCT3_ORI       3'b110
`define FUNCT3_ANDI      3'b111
`define FUNCT3_SLLI      3'b001
`define FUNCT3_SRLI_SRAI 3'b101
// OP
`define FUNCT3_ADD_SUB 3'b000
`define FUNCT3_SLL     3'b001
`define FUNCT3_SLT     3'b010
`define FUNCT3_SLTU    3'b011
`define FUNCT3_XOR     3'b100
`define FUNCT3_SRL_SRA 3'b101
`define FUNCT3_OR      3'b110
`define FUNCT3_AND     3'b111
// MISC-MEM
`define FUNCT3_FENCE  3'b000
`define FUNCT3_FENCEI 3'b001

//================== Instruction funct7 in RISC-V ================== 
`define FUNCT7_SLLI 7'b0000000
// SRLI_SRAI
`define FUNCT7_SRLI 7'b0000000
`define FUNCT7_SRAI 7'b0100000
// ADD_SUB
`define FUNCT7_ADD  7'b0000000
`define FUNCT7_SUB  7'b0100000
`define FUNCT7_SLL  7'b0000000
`define FUNCT7_SLT  7'b0000000
`define FUNCT7_SLTU 7'b0000000
`define FUNCT7_XOR  7'b0000000
// SRL_SRA
`define FUNCT7_SRL 7'b0000000
`define FUNCT7_SRA 7'b0100000
`define FUNCT7_OR  7'b0000000
`define FUNCT7_AND 7'b0000000

//================== Data Cache ================== 
`define SET_WIDTH       1:0
`define SET_NUM           2
`define TAG_WIDTH      21:0
`define INDEX_WIDTH     5:0
`define SELECT_WIDTH    3:0
`define DATA_ROW_WIDTH 63:0
`define DATA_ROWS        64
`define DATA_COL_WIDTH  3:0
`define DATA_COLS         4
`define BENCH_WIDTH   127:0

