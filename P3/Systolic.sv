/////////////////////////////////////////////////////////////////////
//
// EE488(G) Project 3
// Title: Systolic.sv
//
/////////////////////////////////////////////////////////////////////
 
`timescale 1 ns / 1 ps

module Systolic 
#(
    // logic parameter
    parameter MAC_ROW                           = 16,
    parameter MAC_COL                           = 16,
    parameter W_BITWIDTH                        = 8,
    parameter IFMAP_BITWIDTH                    = 16,
    parameter OFMAP_BITWIDTH                    = 32,
    parameter W_ADDR_BIT                        = 11,
    parameter IFMAP_ADDR_BIT                    = 9,
    parameter OFMAP_ADDR_BIT                    = 10,
    // operation parameter
    parameter OFMAP_CAHNNEL_NUM                 = 64,
    parameter IFMAP_CAHNNEL_NUM                 = 32,
    parameter WEIGHT_WIDTH                      = 3,
    parameter WEIGHT_HEIGHT                     = 3,
    parameter IFMAP_WIDTH                       = 16,
    parameter IFMAP_HEIGHT                      = 16,
    parameter OFMAP_WIDTH                       = 14,
    parameter OFMAP_HEIGHT                      = 14,
    // initialization data path
    parameter IFMAP_DATA_PATH                   = "",
    parameter WEIGHT_DATA_PATH                  = "",
    parameter OFMAP_DATA_PATH                   = ""
)
(
    input  logic                                clk,
    input  logic                                rstn,

    // do not modify this port: for verification at simulation
    input  logic [OFMAP_ADDR_BIT-1:0]           test_output_addr_in,
    input  logic                                test_check_in,
    output logic [MAC_COL*OFMAP_BITWIDTH-1:0]   test_output_out,

    input  logic                                start_in,

    output logic                                finish_out

);


    logic [MAC_COL-1:0][W_BITWIDTH-1:0]         w_data;
    logic [W_ADDR_BIT-1:0]                      w_addr;

    logic [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0]     ifmap_data;
    logic [IFMAP_ADDR_BIT-1:0]                  ifmap_addr;

    logic [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]     ofmap_wdata;
    logic [OFMAP_ADDR_BIT-1:0]                  ofmap_addr;
    logic                                       ofmap_wen;

    logic [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]     psum_data;
    logic [OFMAP_ADDR_BIT-1:0]                  psum_addr;
    logic [OFMAP_ADDR_BIT-1:0]                  psum_addr_mux;

    // your code here








    // verificate functionality
    assign test_output_out                      = psum_data;
    assign psum_addr_mux                        = test_check_in ? test_output_addr_in : psum_addr;

    // Memory instances
    ifmap_mem i_mem
    (
        .address                                (ifmap_addr),
        .clock                                  (clk),
        .data                                   ({(IFMAP_BITWIDTH*MAC_ROW){1'b0}}),
        .wren                                   (1'b0),
        .q                                      (ifmap_data)
    );

    weight_mem w_mem
    (
        .address                                (w_addr),
        .clock                                  (clk),
        .data                                   ({(W_BITWIDTH*MAC_COL){1'b0}}),
        .wren                                   ('b0),
        .q                                      (w_data)
    );

    ofmap_mem o_mem
    (
        .clock                                  (clk),            
        .data                                   (ofmap_wdata),            
        .rdaddress                              (psum_addr_mux),                
        .wraddress                              (ofmap_addr),                
        .wren                                   (ofmap_wen),            
        .q                                      (psum_data)
    );

endmodule