`timescale 1ns / 1ps


module execute(
    input CLK,
    input RST,
    input next_valid,
    input [31:0] next_addr,
    input next_busy,
    input [31:0] in_inst,
    input in_busy,
    output reg [31:0] addr,
    output reg [31:0] inst,
    output reg valid
    );
    reg [31:0] PC;
    wire [31:0] next_PC;
    assign next_PC = next_valid ? next_addr : PC + 4;
    assign stall = next_busy | in_busy;
    assign addr = next_PC;
    assign valid = !in_busy;
    assign inst = in_inst;
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            PC <= 32'd0;
        end else begin
            if (!stall) PC <= next_PC;
        end
    end
endmodule