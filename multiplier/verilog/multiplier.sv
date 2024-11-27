`timescale 1ns / 1ps

module multiplier(
        input  logic        RST,
        input  logic        CLK,
        input  logic        EN_i,
        input  logic [31:0] DIN1_i,
        input  logic [31:0] DIN2_i,
        output logic        BUSY_o,
        output logic        VALID_o,
        output logic [63:0] DOUT_o
    );
    
    reg   [5:0] cntr;
    reg         busy;
    reg         valid;
    
    reg  [31:0] din1_reg;
    reg  [31:0] din2_sreg;
    reg  [63:0] prod_sreg;
    
    wire [31:0] sum_in1;
    wire [31:0] sum_in2;
    wire [32:0] sum_out;
    
    //--- INPUT DATA REGISTERS & SHIFT REGISTERS ------------------------------
    always @(posedge CLK) begin
        if (RST) begin
            din1_reg  <= DIN1_i;
            din2_sreg <= DIN2_i;
            prod_sreg <= 32'b0;
        end else if (busy) begin
            din2_sreg <= {1'b0, din2_sreg[31:1]};       // shift-register for data2 input
            prod_sreg <= {sum_out, prod_sreg[31:1]};    // half shift-register for adder results
        end else if (EN_i) begin
            din1_reg  <= DIN1_i;
            din2_sreg <= DIN2_i;
            prod_sreg <= 32'b0;
        end
    end
    
    //--- CONTROL SIGNALS -------------------------------------------------------
    always @(posedge CLK) begin
        if (RST) begin
            busy  = 1'b0;
            valid = 1'b0;
        end else if (cntr[5]) begin         // if 32 cycles completed
            busy  = 1'b0;
            valid = 1'b1;
        end else if (EN_i) begin            // if new multiplication initiated
            busy  = 1'b1;
            valid = 1'b0;
        end
        
        //--- internal counter ---
        if (RST || cntr[5])
            cntr = 0;
        else if (EN_i || busy)
            cntr++;
    end
    
    adder32b adder(
            .A_32b( sum_in1 ), 
            .B_32b( sum_in2 ), 
            .S_32b( sum_out[31:0] ), 
            .Cout( sum_out[32] ) 
        );
        
    assign sum_in1 = din2_sreg[0] ? din1_reg : 32'b0;
    assign sum_in2 = prod_sreg[63:32];
    
    //--- OUTPUT SIGNALS --------------------------------------------------------
    assign BUSY_o  = busy;
    assign VALID_o = valid;
    assign DOUT_o  = prod_sreg;
    
endmodule
