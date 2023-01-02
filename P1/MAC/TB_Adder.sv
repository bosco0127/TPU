`timescale 1ns / 1ns

module TB_Adder();
    logic [7:0] A;
    logic [7:0] B;
    logic Cin;
    logic [7:0] S;
    logic Cout;

    Adder_8bit A1(
        .A (A),
        .B (B),
        .Cin (Cin),
        .S (S),
        .Cout (Cout)
    );

    logic [7:0] A_init;
    logic [7:0] B_init;
    logic Cin_init;
    logic [7:0] S_ans;

    assign A = A_init;
    assign B = B_init;
    assign Cin = Cin_init;

    initial begin
        #500 $finish();
    end

    initial begin
        A_init = -1;
        B_init = -1;
        Cin_init = 0;
        S_ans = A_init + B_init;
        #10
        if (S == S_ans) begin
            $display("PASS");
        end
        else begin
            $display("FAIL");
        end
    end

endmodule