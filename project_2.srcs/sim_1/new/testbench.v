`timescale 1ns / 1ps
module tb_ALU();

    reg [6:0] a, b;
    reg [1:0] ALUControl;

    wire [6:0] Result;
    wire [3:0] ALUFlags;

    ALU uut (
        .A(a),
        .B(b),
        .ALUControl(ALUControl),
        .Result(Result),
        .ALUFlags(ALUFlags)
    );

    initial begin
        // Caso 1: 3 + 5
        a = 3; b = 5; ALUControl = 2'b00;
        #10;

        // Caso 2: 5 - 5
        a = 5; b = 5; ALUControl = 2'b01;
        #10;

        // Caso 3: 8 AND 1
        a = 8; b = 1; ALUControl = 2'b10;
        #10;

        // Caso 4: 5 OR 7
        a = 5; b = 7; ALUControl = 2'b11;
        #10;

        $finish;
    end

endmodule

