`timescale 1ns / 1ps

module multiplier (
    input  logic [31:0] DIN1_i,
    input  logic [31:0] DIN2_i,
    output logic [63:0] DOUT_o
);

    // ---------------------------------------

    // internal signals
    logic [32:0] rca_in1 [0:31];
    logic [32:0] rca_in2 [0:31];
    logic [32:0] rca_out [0:31];
    logic        c_in    [0:31];
    logic        c_out   [0:31];
    logic [63:0] data_out;
    
    // ---------------------------------------
    
    // 32 x 33bit-adder instantiation
    adder_RCA_33b adders[0:31](
        .C_i     ( c_in    ),
        .A_33b_i ( rca_in1 ),
        .B_33b_i ( rca_in2 ),
        .S_33b_o ( rca_out ),
        .C_o     ( c_out   )          // c_out unused
    );
    
    // wiring logic for adders' inputs/outputs
    genvar i;
    generate
        for (i = 0; i < 31; i++) begin
            assign rca_in1[i] = (DIN2_i[i]) ? {DIN1_i[31], DIN1_i} : 33'b0;
            assign c_in[i] = 1'b0;
            assign rca_in2[i + 1] = {rca_out[i][32], rca_out[i][32:1]};
            assign data_out[i] = rca_out[i][0];
        end
    endgenerate

    // initial addition input2
    assign rca_in2[0] = 33'b0;
    
    // last addition input1 logic
    assign rca_in1[31] = (DIN2_i[31]) ? ~{DIN1_i[31], DIN1_i} : 33'b0;      // inversion for 2's complement
    assign c_in[31] = DIN2_i[31];                                           // add +1 for 2's complement

    // output
    assign data_out[63:31] = rca_out[31];
    assign DOUT_o = data_out;

endmodule
