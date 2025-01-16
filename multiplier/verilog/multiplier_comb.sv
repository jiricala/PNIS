`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
//  MULTIPLIER (32b x 32b) - COMBINATIONAL DESIGN
// ----------------------------------------------------------------------------

module multiplier_comb (
    input  logic [31:0] DIN1_i,
    input  logic [31:0] DIN2_i,
    output logic [63:0] DOUT_o
);

    //---------------------------------------------------------------
    
    logic [32:0] rca_in1 [0:31];
    logic [32:0] rca_in2 [0:31];
    logic [32:0] rca_out [0:31];
    logic        c_in    [0:31];
    logic        c_out   [0:31];
    logic [63:0] data_out;
    
    //--- ADDERS' INSTANTIATION (32 x 33bit) ------------------------
    adder_RCA_33b adders[0:31](
        .C_i     ( c_in    ),
        .A_33b_i ( rca_in1 ),
        .B_33b_i ( rca_in2 ),
        .S_33b_o ( rca_out ),
        .C_o     ( c_out   )          // c_out unused
    );
    
    //--- WIRING LOGIC FOR ADDERS' INPUTS/OUTPUTS -------------------
    genvar i;
    generate
        for (i = 0; i < 31; i++) begin
            assign c_in[i] = 1'b0;
            assign rca_in1[i] = (DIN2_i[i]) ? {DIN1_i[31], DIN1_i} : 33'b0;
            assign rca_in2[i + 1] = {rca_out[i][32], rca_out[i][32:1]};
            assign data_out[i] = rca_out[i][0];
        end
    endgenerate

    // initial addition input2
    assign rca_in2[0] = 33'b0;
    
    // last addition input1 logic
    assign rca_in1[31] = (DIN2_i[31]) ? ~{DIN1_i[31], DIN1_i} : 33'b0;      // inversion for 2's complement
    assign c_in[31] = DIN2_i[31];                                           // add +1 for 2's complement

    // last addition output
    assign data_out[63:31] = rca_out[31];

    //--- OUTPUT ----------------------------------------------------
    assign DOUT_o = data_out;

endmodule


// ----------------------------------------------------------------------------
//  ADDER RIPPLE-CARRY (33b)
// ----------------------------------------------------------------------------

module adder_RCA_33b(
        input  logic        C_i,
        input  logic [32:0] A_33b_i,
        input  logic [32:0] B_33b_i,
        output logic [32:0] S_33b_o,
        output logic        C_o
    );
    
    // ---------------------------------------
    
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


// ----------------------------------------------------------------------------
//  CARRY ADDER
// ----------------------------------------------------------------------------

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
