`timescale 1ns / 1ps

module adder_RCA_33b(
        input  logic        C_i,
        input  logic [32:0] A_33b_i,
        input  logic [32:0] B_33b_i,
        output logic [32:0] S_33b_o,
        output logic        C_o
    );
    
    // ---------------------------------------
    
    // internal signals
    logic [32:0] carry_out;
    logic [32:0] carry_in;
    
    // ---------------------------------------
    
    // internal wiring
    assign C_o = carry_out[32];
    assign carry_in = {carry_out[31:0], C_i};
    
    // 33 x carry-adder instantiation
    carry_adder adders[32:0] (
        carry_in, 
        A_33b_i, 
        B_33b_i, 
        S_33b_o, 
        carry_out
    );
    
endmodule
