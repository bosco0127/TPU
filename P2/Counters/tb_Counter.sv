`timescale 1ns / 100ps

module TB_MAC #(
    parameter MAX_NUM_1 = 10,
    parameter MAX_NUM_2 = 9
);
    logic clk;
    logic rstn;

    logic enable_1;
    logic [31:0] MAX_1;
    logic [31:0] Count_1;
    logic isMAX_1;

    logic enable_2;
    logic [31:0] MAX_2;
    logic [31:0] Count_2;
    logic isMAX_2;

    Counter Counter1 (
        .clk (clk),
        .rstn (rstn),
        .enable (enable_1),
        .MAX (MAX_1),
        .Count (Count_1),
        .isMAX (isMAX_1)
    );

    Counter Counter2 (
        .clk (clk),
        .rstn (rstn),
        .enable (enable_2),
        .MAX (MAX_2),
        .Count (Count_2),
        .isMAX (isMAX_2)
    );

    /**************CLOCK & RESET Negative GENERATION**************/
    logic clock_q = 1'b0;
    logic reset_n_q = 1'b0;

    initial begin
        enable_1 <= 1'b0;
        #5 clock_q <= 1'b1;
        #101 reset_n_q <= 1'b1;
        /***COUNTER TEST***/
        @(posedge clk);
        enable_1 <= 1'b1;
        #1000;
        @(posedge clk);
        enable_1 <= 1'b0;
        #5
        @(posedge clk);
        reset_n_q <= 1'b0;
        /***COUNTER TEST***/
        $finish();
    end

    always @(clock_q)
        #5 clock_q <= ~clock_q;

    assign clk = clock_q;
    assign rstn = reset_n_q;
    /**************CLOCK & RESET Negative GENERATION**************/

    /**************TEST**************/
    assign MAX_1 = MAX_NUM_1;
    assign MAX_2 = MAX_NUM_2;
    assign enable_2 = isMAX_1;

endmodule