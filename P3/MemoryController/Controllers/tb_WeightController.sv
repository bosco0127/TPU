`timescale 1ns / 1ps

module TB_WeightController #(
    // logic parameter
    parameter MAC_ROW                                           = 16,
    parameter MAC_COL                                           = 16,
    parameter W_BITWIDTH                                        = 8,
    parameter IFMAP_BITWIDTH                                    = 16,
    parameter OFMAP_BITWIDTH                                    = 32,
    parameter W_ADDR_BIT                                        = 11,
    parameter IFMAP_ADDR_BIT                                    = 9,
    parameter OFMAP_ADDR_BIT                                    = 10,
    // operation parameter
    parameter OFMAP_CHANNEL_NUM                                 = 64,
    parameter IFMAP_CHANNEL_NUM                                 = 32,
    parameter WEIGHT_WIDTH                                      = 3,
    parameter WEIGHT_HEIGHT                                     = 3,
    parameter IFMAP_WIDTH                                       = 16,
    parameter IFMAP_HEIGHT                                      = 16,
    parameter OFMAP_WIDTH                                       = 14,
    parameter OFMAP_HEIGHT                                      = 14
);
    logic                  clk;
    logic                  rstn;
    logic                  start_in;
    logic                  I_CH_MAC_ROW_isMAX;
    logic                  I_CH_MAC_ROW_isNext;
    logic [31:0]           O_CH_MAC_COL_count;
    logic [31:0]           I_CH_MAC_ROW_count;
    logic                  MAC_COL_isMAX;
    logic                  MAC_COL_isNext;
    logic                  w_prefetch_out;
    logic [W_ADDR_BIT-1:0] w_addr_out;
    logic                  w_read_en_out;
    logic                  W_H_isMAX;
    logic                  W_H_isNext;

    logic                  O_CH_MAC_COL_isMAX;
    logic                  O_CH_MAC_COL_isNext;
    
    WeightController WeightController0 (
        .clk (clk),
        .rstn (rstn),
        .start_in (start_in),
        .I_CH_MAC_ROW_isMAX (I_CH_MAC_ROW_isMAX),
        .I_CH_MAC_ROW_isNext (I_CH_MAC_ROW_isNext),
        .O_CH_MAC_COL_count (O_CH_MAC_COL_count),
        .I_CH_MAC_ROW_count (I_CH_MAC_ROW_count),
        .MAC_COL_isMAX (MAC_COL_isMAX),
        .MAC_COL_isNext (MAC_COL_isNext),
        .w_prefetch_out (w_prefetch_out),
        .w_addr_out (w_addr_out),
        .w_read_en_out (w_read_en_out),
        .W_H_isMAX (W_H_isMAX),
        .W_H_isNext (W_H_isNext)
    );

    Counter O_CH_MAC_COL_Counter (
        .clk ((clk & ~rstn) | (rstn & MAC_COL_isNext)),
        .rstn (rstn),
        .enable (MAC_COL_isMAX),
        .MAX (OFMAP_CHANNEL_NUM/MAC_COL),
        .Count (O_CH_MAC_COL_count),
        .isMAX (O_CH_MAC_COL_isMAX),
        .isNext (O_CH_MAC_COL_isNext)
    );

    Counter I_CH_MAC_ROW_Counter (
        .clk ((clk & ~rstn) | (rstn & O_CH_MAC_COL_isNext)),
        .rstn (rstn),
        .enable (O_CH_MAC_COL_isMAX),
        .MAX (IFMAP_CHANNEL_NUM/MAC_ROW),
        .Count (I_CH_MAC_ROW_count),
        .isMAX (I_CH_MAC_ROW_isMAX),
        .isNext (I_CH_MAC_ROW_isNext)
    );

    /**************CLOCK & RESET Negative GENERATION**************/
    logic clock_q = 1'b0;
    logic reset_n_q = 1'b0;

    initial begin
        start_in <= 1'b0;
        #5 clock_q <= 1'b1;
        #101 reset_n_q <= 1'b1;
        /***TEST START***/
        @(posedge clk);
        start_in <= 1'b1;
        @(posedge clk);
        start_in <= 1'b0;
        #195
        @(posedge clk);
        start_in <= 1'b1;
        @(posedge clk);
        start_in <= 1'b0;
        /***TEST START***/
    end

    always @(clock_q)
        #5 clock_q <= ~clock_q;

    assign clk = clock_q;
    assign rstn = reset_n_q;
    /**************CLOCK & RESET Negative GENERATION**************/

    /**************TEST**************/
    always @(*) begin
        if (W_H_isNext) begin
            @(posedge clk);
            $finish();
        end
    end
endmodule