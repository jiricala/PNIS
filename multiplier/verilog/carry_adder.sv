`timescale 1ns / 1ps


module carry_adder(
        input  logic C_i,
        input  logic A_i,
        input  logic B_i,
        output logic S_o,
        output logic C_o
    );
    
    logic and1;
    logic and2;
    logic xor1;
    logic xor2;
    
    assign and1 = A_i & B_i;
    assign xor1 = A_i ^ B_i;
    assign and2 = C_i & xor1;
    assign S_o  = C_i ^ xor1;
    assign C_o  = and1 | and2;
    
endmodule
