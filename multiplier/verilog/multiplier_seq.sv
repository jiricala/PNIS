`timescale 1ns / 1ps

// ----------------------------------------------------------------------------
//  MULTIPLIER (32b x 32b) - SEQUENTIAL DESIGN
// ----------------------------------------------------------------------------

module multiplier_seq(
        input  logic        RSTN_i,
        input  logic        CLK_i,
        input  logic        EN_i,
        input  logic [31:0] DIN1_i,
        input  logic [31:0] DIN2_i,
        output logic        BUSY_o,
        output logic        VALID_o,
        output logic [63:0] DOUT_o
    );
    
    // --------------------------------------------------------------

    reg   [5:0] cntr;
    reg         busy;
    reg         valid;
    
    reg  [31:0] din1_reg;
    reg  [31:0] din1_mux;
    reg  [31:0] din2_sreg;
    reg  [63:0] calc_sreg;
    
    wire        c_in;
    wire        c_out;
    wire [32:0] rca_in1;
    wire [32:0] rca_in2;
    wire [32:0] rca_out;    

    //--- INPUT DATA REGISTERS & SHIFT REGISTERS --------------------
    always @(posedge CLK_i or negedge RSTN_i) begin
        if (!RSTN_i) begin                          // async reset
            din1_reg  <= 32'b0;
            din2_sreg <= 32'b0;
            calc_sreg <= 64'b0;
        end else begin                              // CLK_i posedge
            if (busy) begin                             // if multiplication is in progress
                din2_sreg <= {1'b0, din2_sreg[31:1]};       // shift-register for data2 input
                calc_sreg <= {rca_out, calc_sreg[31:1]};    // register to store intermediate calculation from adder in each cycle
                                                                    // 33 MSB loaded by adder result, 31 LSB works as shift-register
            end else if (EN_i) begin                    // if new multiplication initiated
                din1_reg  <= DIN1_i;
                din2_sreg <= DIN2_i;
                calc_sreg <= 64'b0;
            end
        end
    end
    
    //--- CONTROL SIGNALS -------------------------------------------
    always @(posedge CLK_i or negedge RSTN_i) begin
        if (!RSTN_i) begin              // async reset
            busy  = 1'b0;
            valid = 1'b0;
            cntr  = 6'b0;
        end else begin                  // CLK_i posedge
            if (cntr[5]) begin              // if 32 cycles completed
                busy  = 1'b0;
                valid = 1'b1;
            end else if (EN_i) begin        // if new multiplication initiated
                busy  = 1'b1;
                valid = 1'b0;
            end
            
            //--- internal counter ---
            if (cntr[5]) begin
                cntr = 0;
            end else if (EN_i || busy) begin
                cntr++;
            end
        end
  
    end
    
    //--- ADDER SIGNALS ---------------------------------------------
    adder_RCA_33b adder(
            .C_i( c_in ), 
            .A_33b_i( rca_in1 ), 
            .B_33b_i( rca_in2 ), 
            .S_33b_o( rca_out ), 
            .C_o( c_out ) 
        );
        
    assign c_in     = cntr[5] & din2_sreg[0];                               // if last cycle of multiplicand addition => add 1 (to achieve 2s complement)
    assign din1_mux = cntr[5] ? ~din1_reg : din1_reg;                       // if last cycle of multiplicand addition => invert (to achieve 2s complement)
    assign rca_in1  = din2_sreg[0] ? {din1_mux[31], din1_mux} : 33'b0;      // set input when respective bit in multiplier is '1' (multiplicand will be added)
    assign rca_in2  = {calc_sreg[63], calc_sreg[63:32]};                    // sum of all previous additions (two MSBs are same) 
    
    //--- OUTPUT SIGNALS --------------------------------------------
    assign BUSY_o  = busy;
    assign VALID_o = valid;
    assign DOUT_o  = calc_sreg;
    
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
