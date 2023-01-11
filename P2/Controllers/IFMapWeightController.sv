`timescale 1ns / 1ps

module IFMapWeightController #(
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
)
(
    input  logic                                                clk,
    input  logic                                                rstn,

    input  logic                                                start_in,

    output logic                                                w_prefetch_out,
    output logic [W_ADDR_BIT-1:0]                               w_addr_out,
    output logic                                                w_read_en_out,

    output logic                                                ifmap_start_out,
    output logic [IFMAP_ADDR_BIT-1:0]                           ifmap_addr_out,
    output logic                                                ifmap_read_en_out,

    output logic                                                mac_done_out
);

    /************Weight Control Logics************/
    logic                  w_start_in;
    logic                  MAC_COL_isMAX;
    logic                  MAC_COL_isNext;

    /************IFMap Control Logics************/
    logic                      ifmap_start_in;
    logic                      W_Controller_start;
    logic                      O_H_isMAX;
    logic                      O_H_isNext;

    /************External Counter Logics************/
    logic [31:0]           O_CH_MAC_COL_count;
    logic                  O_CH_MAC_COL_isMAX;
    logic                  O_CH_MAC_COL_isNext;
    logic [31:0]           I_CH_MAC_ROW_count;
    logic                  I_CH_MAC_ROW_isMAX;
    logic                  I_CH_MAC_ROW_isNext;
    logic [31:0]           W_W_count;
    logic                  W_W_isMAX;
    logic                  W_W_isNext;
    logic [31:0]           W_H_count;
    logic                  W_H_isMAX;
    logic                  W_H_isNext;

    // Wire assginment
    assign w_start_in = (start_in | W_Controller_start) & ~mac_done_out;
    assign ifmap_start_in = MAC_COL_isMAX;
    assign mac_done_out = W_Controller_start & O_CH_MAC_COL_isMAX & I_CH_MAC_ROW_isMAX & W_W_isMAX & W_H_isMAX;
    
    WeightController WeightController0 (
        .clk (clk),
        .rstn (rstn),
        .w_start_in (w_start_in),
        .O_CH_MAC_COL_count (O_CH_MAC_COL_count),
        .I_CH_MAC_ROW_count (I_CH_MAC_ROW_count),
        .W_W_count (W_W_count),
        .W_H_count (W_H_count),
        .MAC_COL_isMAX (MAC_COL_isMAX),
        .MAC_COL_isNext (MAC_COL_isNext),
        .w_prefetch_out (w_prefetch_out),
        .w_addr_out (w_addr_out),
        .w_read_en_out (w_read_en_out)
    );

    IFMapController IFMapController0 (
        .clk (clk),
        .rstn (rstn),
        .ifmap_start_in (ifmap_start_in),
        .I_CH_MAC_ROW_count (I_CH_MAC_ROW_count),
        .W_W_count (W_W_count),
        .W_H_count (W_H_count),
        .W_Controller_start (W_Controller_start),
        .O_H_isMAX (O_H_isMAX),
        .O_H_isNext (O_H_isNext),
        .ifmap_start_out (ifmap_start_out),
        .ifmap_addr_out (ifmap_addr_out),
        .ifmap_read_en_out (ifmap_read_en_out)
    );

    Counter O_CH_MAC_COL_Counter (
        .clk ((clk & ~rstn) | (rstn & O_H_isNext)),
        .rstn (rstn),
        .enable (O_H_isMAX),
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

    // W_W Counter
    Counter W_W_Counter (
        .clk ((clk & ~rstn) | (rstn & I_CH_MAC_ROW_isNext)),
        .rstn (rstn),
        .enable (I_CH_MAC_ROW_isMAX),
        .MAX (WEIGHT_WIDTH),
        .Count (W_W_count),
        .isMAX (W_W_isMAX),
        .isNext (W_W_isNext)
    );

    // W_H Counter
    Counter W_H_Counter (
        .clk ((clk & ~rstn) | (rstn & W_W_isNext)),
        .rstn (rstn),
        .enable (W_W_isMAX),
        .MAX (WEIGHT_HEIGHT),
        .Count (W_H_count),
        .isMAX (W_H_isMAX),
        .isNext (W_H_isNext)
    );

endmodule