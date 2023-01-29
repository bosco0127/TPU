/////////////////////////////////////////////////////////////////////
//
// EE488(G) Project 2
// Title: MemoryController.sv
//
/////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module MemoryController
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

    input  logic                                                start_in,

    input  logic                                                ofmap_ready_in,

    output logic                                                w_prefetch_out,
    output logic [W_ADDR_BIT-1:0]                               w_addr_out,
    output logic                                                w_read_en_out,

    output logic                                                ifmap_start_out,
    output logic [IFMAP_ADDR_BIT-1:0]                           ifmap_addr_out,
    output logic                                                ifmap_read_en_out,

    output logic                                                mac_done_out,

    output logic [OFMAP_ADDR_BIT-1:0]                           ofmap_addr_out,
    output logic                                                ofmap_write_en_out,
    output logic                                                ofmap_write_done_out
);

    // your code here
    IFMapWeightController IFMapWeightController0 (
        .clk (clk),
        .rstn (rstn),
        .start_in (start_in),
        .w_prefetch_out (w_prefetch_out),
        .w_addr_out (w_addr_out),
        .w_read_en_out (w_read_en_out),
        .ifmap_start_out (ifmap_start_out),
        .ifmap_addr_out (ifmap_addr_out),
        .ifmap_read_en_out (ifmap_read_en_out),
        .mac_done_out (mac_done_out)
    );

    OFMapController OFMapController0 (
        .clk (clk),
        .rstn (rstn),
        .ofmap_ready_in (ofmap_ready_in),
        .ofmap_addr_out (ofmap_addr_out),
        .ofmap_write_en_out (ofmap_write_en_out),
        .ofmap_write_done_out (ofmap_write_done_out)
    );

endmodule
