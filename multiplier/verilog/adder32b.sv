`timescale 1ns / 1ps


module adder32b(
        input  logic [31:0] A_32b,
        input  logic [31:0] B_32b,
        output logic [31:0] S_32b,
        output logic        Cout
    );
    
    wire logic [32:0] carry;
    wire logic [31:0] carry_out;
    wire logic [31:0] carry_in;
    
    assign Cout = carry_out[31];
    
    assign carry_in = {carry_out[30:0], 1'b0};
    
    adder1b adders[31:0] (carry_in, A_32b, B_32b, S_32b, carry_out);
    
endmodule
