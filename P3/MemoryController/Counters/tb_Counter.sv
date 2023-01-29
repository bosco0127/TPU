`timescale 1ns / 1ps

module TB_Counter #(
    parameter MAX_NUM_1 = 16,
    parameter MAX_NUM_2 = 4,
    parameter MAX_NUM_3 = 14*14*2,
    parameter MAX_NUM_4 = 3
);
    logic clk;
    logic rstn;

    logic enable_1;
    logic [31:0] MAX_1;
    logic [31:0] Count_1;
    logic isMAX_1;
    logic isNext_1;

    logic enable_2;
    logic [31:0] MAX_2;
    logic [31:0] Count_2;
    logic isMAX_2;
    logic isNext_2;

    logic enable_3;
    logic [31:0] MAX_3;
    logic [31:0] Count_3;
    logic isMAX_3;
    logic isNext_3;

    logic enable_4;
    logic [31:0] MAX_4;
    logic [31:0] Count_4;
    logic isMAX_4;
    logic isNext_4;

    Counter Counter1 (
        .clk (clk),
        .rstn (rstn),
        .enable (enable_1),
        .MAX (MAX_1),
        .Count (Count_1),
        .isMAX (isMAX_1),
        .isNext (isNext_1)
    );

    Counter Counter2 (
        .clk ((clk & ~rstn) | (rstn & isNext_1)),
        .rstn (rstn),
        .enable (enable_2),
        .MAX (MAX_2),
        .Count (Count_2),
        .isMAX (isMAX_2),
        .isNext (isNext_2)
    );

    Counter Counter3 (
        .clk ((clk & ~rstn) | (rstn & isNext_2)),
        .rstn (rstn),
        .enable (enable_3),
        .MAX (MAX_3),
        .Count (Count_3),
        .isMAX (isMAX_3),
        .isNext (isNext_3)
    );

    Counter Counter4 (
        .clk ((clk & ~rstn) | (rstn & isNext_3)),
        .rstn (rstn),
        .enable (isMAX_3),
        .MAX (MAX_NUM_4),
        .Count (Count_4),
        .isMAX (isMAX_4),
        .isNext (isNext_4)
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
        #(MAX_NUM_1 * MAX_NUM_2 * MAX_NUM_3 * MAX_NUM_4 * 10);
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
    assign MAX_3 = MAX_NUM_3;
    assign enable_2 = isMAX_1;
    assign enable_3 = isMAX_2;

endmodule