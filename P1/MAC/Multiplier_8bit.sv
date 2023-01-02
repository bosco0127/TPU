module Multiplier_8bit #(
    parameter FEAT_BIT = 16,
    parameter WEIGHT_BIT = 8,
    parameter OUT_BIT = 32
) (
    input logic [FEAT_BIT-1:0] A,
    input logic [WEIGHT_BIT-1:0] B,

    output logic [OUT_BIT-1:0] M
);

    // AND logic
    logic [FEAT_BIT-1:0] AND [WEIGHT_BIT-1:0];
    // S logic
    logic [FEAT_BIT+WEIGHT_BIT-2:0] S0;
    logic [FEAT_BIT+WEIGHT_BIT-3:0] S1;
    logic [FEAT_BIT+WEIGHT_BIT-4:0] S2;
    logic [FEAT_BIT+WEIGHT_BIT-5:0] S3;
    logic [FEAT_BIT+WEIGHT_BIT-6:0] S4;
    logic [FEAT_BIT+WEIGHT_BIT-7:0] S5;
    logic [FEAT_BIT+WEIGHT_BIT-8:0] S6;
    // Cout logic
    logic Cout0 [WEIGHT_BIT-1:0];
    logic Cout1 [WEIGHT_BIT-2:0];
    logic Cout2 [WEIGHT_BIT-3:0];
    logic Cout3 [WEIGHT_BIT-4:0];
    logic Cout4 [WEIGHT_BIT-5:0];
    logic Cout5 [WEIGHT_BIT-6:0];
    logic Cout6 [WEIGHT_BIT-7:0];
    // Generate Variable
    genvar i;
    genvar j;

    // AND logic assignment
    generate
        for (i = 0; i < WEIGHT_BIT; i=i+1) begin :AND_Assign_i
            for (j = 0; j < FEAT_BIT; j=j+1) begin :AND_Assign_j
                if (i < WEIGHT_BIT-1) begin
                    assign AND[i][j] = A[j] & B[i];
                end else begin
                    assign AND[i][j] = ~(A[j] & B[i]);
                end
            end
        end
    endgenerate

    // Output Assignment for Signed Multiplication
    assign M[0] = AND[0][0];
    assign M[1] = S0[0];
    assign M[2] = S1[0];
    assign M[3] = S2[0];
    assign M[4] = S3[0];
    assign M[5] = S4[0];
    assign M[6] = S5[0];
    assign M[FEAT_BIT+WEIGHT_BIT-1:WEIGHT_BIT-1] = S6;
    assign M[OUT_BIT-1:FEAT_BIT+WEIGHT_BIT] = {(OUT_BIT-FEAT_BIT-WEIGHT_BIT){S6[FEAT_BIT+WEIGHT_BIT-8]}};

    // Adder0
    Adder_16bit A0 (
        .A ({AND[0][FEAT_BIT-1],AND[0][FEAT_BIT-1:1]}),
        .B (AND[1]),
        .Cin (1'b0),
        .S (S0[FEAT_BIT-1:0]),
        .Cout (Cout0[0])
    );
    generate
        for(i = 0; i < WEIGHT_BIT-1; i=i+1) begin : S0_gen
            FullAdder FA01 (
                .A (AND[0][FEAT_BIT-1]),
                .B (AND[1][FEAT_BIT-1]),
                .Cin (Cout0[i]),
                .S (S0[FEAT_BIT+i]),
                .Cout (Cout0[i+1])
            );
        end
    endgenerate

    // Adder1
    Adder_16bit A1 (
        .A (S0[FEAT_BIT:1]),
        .B (AND[2]),
        .Cin (1'b0),
        .S (S1[FEAT_BIT-1:0]),
        .Cout (Cout1[0])
    );
    generate
        for(i = 0; i < WEIGHT_BIT-2; i=i+1) begin : S1_gen
            FullAdder FA11 (
                .A (S0[FEAT_BIT+1+i]),
                .B (AND[2][FEAT_BIT-1]),
                .Cin (Cout1[i]),
                .S (S1[FEAT_BIT+i]),
                .Cout (Cout1[i+1])
            );
        end
    endgenerate

    // Adder2
    Adder_16bit A2 (
        .A (S1[FEAT_BIT:1]),
        .B (AND[3]),
        .Cin (1'b0),
        .S (S2[FEAT_BIT-1:0]),
        .Cout (Cout2[0])
    );
    generate
        for(i = 0; i < WEIGHT_BIT-3; i=i+1) begin : S2_gen
            FullAdder FA21 (
                .A (S1[FEAT_BIT+1+i]),
                .B (AND[3][FEAT_BIT-1]),
                .Cin (Cout2[i]),
                .S (S2[FEAT_BIT+i]),
                .Cout (Cout2[i+1])
            );
        end
    endgenerate

    // Adder3
    Adder_16bit A3 (
        .A (S2[FEAT_BIT:1]),
        .B (AND[4]),
        .Cin (1'b0),
        .S (S3[FEAT_BIT-1:0]),
        .Cout (Cout3[0])
    );
    generate
        for(i = 0; i < WEIGHT_BIT-4; i=i+1) begin : S3_gen
            FullAdder FA31 (
                .A (S2[FEAT_BIT+1+i]),
                .B (AND[4][FEAT_BIT-1]),
                .Cin (Cout3[i]),
                .S (S3[FEAT_BIT+i]),
                .Cout (Cout3[i+1])
            );  
        end
    endgenerate

    // Adder4
    Adder_16bit A4 (
        .A (S3[FEAT_BIT:1]),
        .B (AND[5]),
        .Cin (1'b0),
        .S (S4[FEAT_BIT-1:0]),
        .Cout (Cout4[0])
    );
    generate
        for(i = 0; i < WEIGHT_BIT-5; i=i+1) begin : S4_gen
            FullAdder FA41 (
                .A (S3[FEAT_BIT+1+i]),
                .B (AND[5][FEAT_BIT-1]),
                .Cin (Cout4[i]),
                .S (S4[FEAT_BIT+i]),
                .Cout (Cout4[i+1])
            );
        end
    endgenerate
    
    // Adder5
    Adder_16bit A5 (
        .A (S4[FEAT_BIT:1]),
        .B (AND[6]),
        .Cin (1'b0),
        .S (S5[FEAT_BIT-1:0]),
        .Cout (Cout5[0])
    );
    generate
        for(i = 0; i < WEIGHT_BIT-6; i=i+1) begin : S5_gen
            FullAdder FA51 (
                .A (S4[FEAT_BIT+1+i]),
                .B (AND[6][FEAT_BIT-1]),
                .Cin (Cout5[i]),
                .S (S5[FEAT_BIT+i]),
                .Cout (Cout5[i+1])
            );
        end
    endgenerate

    // Adder6
    Adder_16bit A6 (
        .A (S5[FEAT_BIT:1]),
        .B (AND[WEIGHT_BIT-1]),
        .Cin (1'b1),
        .S (S6[FEAT_BIT-1:0]),
        .Cout (Cout6[0])
    );
    generate
        for (i = 0; i < WEIGHT_BIT-WEIGHT_BIT+1; i=i+1) begin : S6_gen
            FullAdder FA61 (
                .A (S5[FEAT_BIT+1]),
                .B (AND[WEIGHT_BIT-1][FEAT_BIT-1]),
                .Cin (Cout6[0]),
                .S (S6[FEAT_BIT]),
                .Cout (Cout6[1])
            );
        end
    endgenerate

    /*integer k;
    always @ (*) begin
        for(k=0; k < 8; k=k+1) begin
            $display("AND[%1d]=%b",k,AND[k]);
        end
        $display("S0=%b",S0);
        $display("S1=%b",S1);
        $display("S2=%b",S2);
        $display("S3=%b",S3);
        $display("S4=%b",S4);
        $display("S5=%b",S5);
        $display("S6=%b",S6);
        $display("Cout5[0]=%b",Cout5[0]);
    end*/

endmodule