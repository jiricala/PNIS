`timescale 1ns / 1ps


module adder1b(
        input  logic Cin,
        input  logic A,
        input  logic B,
        output logic S,
        output logic Cout
    );
    
    wire and1;
    wire and2;
    wire xor1;
    wire xor2;

    assign and1 = A & B;
    assign xor1 = A ^ B;
    assign and2 = Cin & xor1;
    assign S    = Cin ^ xor1;
    assign Cout = and1 | and2;
    
endmodule
