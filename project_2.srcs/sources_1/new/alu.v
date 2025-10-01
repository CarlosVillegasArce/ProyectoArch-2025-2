`timescale 1ns / 1ps
module alu(
A,
B,
ALUControl,
Result,
ALUFlags);

    input [6:0] A, B;
    input [1:0] ALUControl;
    output reg [6:0] Result;
    output wire [3:0] ALUFlags;

    wire neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;

    assign condinvb = ALUControl[0] ? ~B :B;
    assign sum = A + condinvb + ALUControl[0];
    
    always @(*)
    begin
        casex (ALUControl[1:0])//con caseX puedo colocar el "?"
            2'b00: Result = sum;
            2'b01: Result = A & B;
            2'b10: Result = A | B;
            2'b11: Result = A ^ B;
        endcase
    end
    
    assign neg = Result[31];
    assign zero = (Result == 32'b0);
    assign carry = (ALUControl[1] == 1'b0) & sum[32];
    assign overflow = (ALUControl[1] ==1'b0) & ~(A[31] ^ B[31] ^ ALUControl[0]) & (A[31] ^ sum[31]);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule