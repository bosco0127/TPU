`timescale 1ns / 100ps

module TB_Multiplier #(
    parameter FEAT_BIT = 16,
    parameter WEIGHT_BIT = 8,
    parameter OUT_BIT = 32
);
    logic [FEAT_BIT-1:0] A;
    logic [WEIGHT_BIT-1:0] B;
    logic [OUT_BIT-1:0] M;

    Multiplier_8bit M1(
        .A (A),
        .B (B),
        .M (M)
    );

    logic signed [FEAT_BIT-1:0] A_init;
    logic signed [WEIGHT_BIT:0] B_init;
    logic signed [OUT_BIT-1:0] M_ans;

    assign A = A_init;
    assign B = B_init;

    initial begin
        #500 $finish();
    end

    initial begin
        A_init = -256;
        B_init = 127;
        M_ans = A_init * B_init;
        #10
        if (M == M_ans) begin
            $display("PASS");
        end
        else begin
            $display("FAIL");
        end
    end

endmodule