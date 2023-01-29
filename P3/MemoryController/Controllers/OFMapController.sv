/////////////////////////////////////////////////////////////////////
//
// EE488(G) Project 2
// Title: MemoryController.sv
//
/////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module OFMapController
#(
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

    input  logic                                                ofmap_ready_in,

    output logic [OFMAP_ADDR_BIT-1:0]                           ofmap_addr_out,
    output logic                                                ofmap_write_en_out,
    output logic                                                ofmap_write_done_out
);

    // Wires
    // isMAX & isNext wires
    logic O_W_isMAX;
    logic O_W_isNext;
    logic O_H_isMAX;
    logic O_H_isNext;
    logic O_CH_MAC_COL_isMAX;
    logic O_CH_MAC_COL_isNext;
    // Counter wires
    logic [31:0] O_W_count;
    logic [31:0] O_H_count;
    logic [31:0] O_CH_MAC_COL_count;

    // Wire assignment
    assign ofmap_write_en_out = ofmap_ready_in;
    assign ofmap_write_done_out = O_H_isMAX & O_W_isMAX & O_CH_MAC_COL_isMAX;

    // O_W Counter
    Counter O_W_Counter (
        .clk (clk),
        .rstn (rstn),
        .enable (ofmap_ready_in),
        .MAX (OFMAP_WIDTH),
        .Count (O_W_count),
        .isMAX (O_W_isMAX),
        .isNext (O_W_isNext)
    );

    // O_H Counter
    Counter O_H_Counter (
        .clk ((clk & ~rstn) | (rstn & O_W_isNext)),
        .rstn (rstn),
        .enable (O_W_isMAX),
        .MAX (OFMAP_HEIGHT),
        .Count (O_H_count),
        .isMAX (O_H_isMAX),
        .isNext (O_H_isNext)
    );

    // O_CH_MAC_COL_Counter: Count numbers from 0 to (OFMAP_CHANNEL_NUM/MAC_COL - 1)
    Counter O_CH_MAC_COL_Counter (
        .clk ((clk & ~rstn) | (rstn & O_H_isNext)),
        .rstn (rstn),
        .enable (O_H_isMAX),
        .MAX (OFMAP_CHANNEL_NUM/MAC_COL),
        .Count (O_CH_MAC_COL_count),
        .isMAX (O_CH_MAC_COL_isMAX),
        .isNext (O_CH_MAC_COL_isNext)
    );

    // Address Generator
    always_comb begin : Address_Generator
        ofmap_addr_out = O_W_count*(OFMAP_CHANNEL_NUM/MAC_COL)
                       + O_H_count*(OFMAP_CHANNEL_NUM/MAC_COL)*OFMAP_WIDTH
                       + O_CH_MAC_COL_count;
    end

endmodule
