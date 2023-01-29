/////////////////////////////////////////////////////////////////////
//
// EE488(G) Project 2
// Title: MemoryController.sv
//
/////////////////////////////////////////////////////////////////////
//`include "C:\\EE495\\TPU\\P3\\MemoryController\\Counters\\Counter.sv"

`timescale 1 ns / 1 ps

module IFMapController
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

    input  logic                                                ifmap_start_in,

    input  logic [31:0]                                         I_CH_MAC_ROW_count,
    input  logic [31:0]                                         W_W_count,
    input  logic [31:0]                                         W_H_count,

    output logic                                                W_Controller_start,

    output logic                                                O_H_isMAX,
    output logic                                                O_H_isNext,

    output logic                                                ifmap_start_out,
    output logic [IFMAP_ADDR_BIT-1:0]                           ifmap_addr_out,
    output logic                                                ifmap_read_en_out
);

    // Wires
    // isMAX & isNext wires
    logic O_W_isMAX;
    logic O_W_isNext;
    // Counter wires
    logic [31:0] O_W_count;
    logic [31:0] O_H_count;

    // Wire assignment
    assign W_Controller_start = O_H_isMAX & O_W_isMAX;

    // ifmap_start_out Register
    always_ff @( posedge clk ) begin : ifmap_start_out_reg
        if (rstn) begin
            ifmap_start_out <= ifmap_start_in;
        end else begin
            ifmap_start_out <= 1'b0;
        end
    end

    // ifmap_read_en_out Register
    always_ff @( posedge clk ) begin : ifmap_read_en_out_reg
        if (rstn) begin
            ifmap_read_en_out <= (~W_Controller_start) & (ifmap_read_en_out & (~ifmap_start_in) | ifmap_start_in);
        end else begin
            ifmap_read_en_out <= 1'b0;
        end
    end

    // O_W Counter
    Counter O_W_Counter (
        .clk (clk),
        .rstn (rstn),
        .enable (ifmap_read_en_out),
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

    // Address Generator
    always_comb begin : Address_Generator
        ifmap_addr_out = O_W_count*(IFMAP_CHANNEL_NUM/MAC_ROW)
                       + O_H_count*(IFMAP_CHANNEL_NUM/MAC_ROW)*IFMAP_WIDTH
                       + I_CH_MAC_ROW_count
                       + W_W_count*(IFMAP_CHANNEL_NUM/MAC_ROW)
                       + W_H_count*(IFMAP_CHANNEL_NUM/MAC_ROW)*IFMAP_WIDTH;
    end

endmodule
