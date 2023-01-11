module Multiplier #(
    parameter A_BIT = 16,
    parameter B_BIT = 8,
    parameter OUT_BIT = 32
) (
    input logic [A_BIT-1:0] A,
    input logic [B_BIT-1:0] B,

    output logic [OUT_BIT-1:0] M
);

    // AND logic
    logic [A_BIT-1:0] AND [B_BIT-1:0];
    // S logic
    logic [A_BIT-1:0] S [B_BIT-2:0];
    // Cout logic
    logic Cout [B_BIT-2:0];
    // Generate Variable
    genvar i;
    genvar j;

    // AND logic assignment
    generate
        for (i = 0; i < B_BIT; i=i+1) begin : AND_Assign_i
            for (j = 0; j < A_BIT; j=j+1) begin : AND_Assign_j
                assign AND[i][j] = A[j] & B[i]; 
            end
        end
    endgenerate

    // Output Assignment for Unsigned Multiplication
    assign M[0] = AND[0][0];
    generate
        for (i = 1; i < B_BIT - 1; i=i+1) begin : M_Assign_1
            assign M[i] = S[i-1][0];
        end
    endgenerate
    assign M[A_BIT+B_BIT-2:B_BIT-1] = S[B_BIT-2];
    generate
        for (i = A_BIT+B_BIT-1; i < OUT_BIT; i=i+1) begin : M_Assign_2
            if (i == A_BIT+B_BIT-1) begin
                assign M[A_BIT+B_BIT-1] = Cout[B_BIT-2]; 
            end else begin
                assign M[i] = 1'b0;
            end
        end
    endgenerate

    // 2D Full Adder Connection
    generate
        for (i = 0; i < B_BIT-1; i=i+1) begin : Adder_Chain_gen
            if (i) begin
                Adder #(
                    .OPERAND_BIT (A_BIT)
                ) AdderX (
                    .A ({1'b0,S[i-1][A_BIT-1:1]}),
                    .B (AND[i+1]),
                    .Cin (1'b0),
                    .S (S[i]),
                    .Cout (Cout[i])
                );
            end else begin
                Adder #(
                    .OPERAND_BIT (A_BIT)
                ) Adder0 (
                    .A ({1'b0,AND[i][A_BIT-1:1]}),
                    .B (AND[i+1]),
                    .Cin (1'b0),
                    .S (S[i]),
                    .Cout (Cout[i])
                );
            end
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