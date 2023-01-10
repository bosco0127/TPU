/////////////////////////////////////////////////////////////////////
//
// EE488(G) Project 2
// Title: MemoryController.sv
//
/////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps

module WeightController
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

    input  logic                                                w_start_in,
/*
    input  logic                                                I_CH_MAC_ROW_isMAX,
    input  logic                                                I_CH_MAC_ROW_isNext,
*/
    input  logic [31:0]                                         O_CH_MAC_COL_count,
    input  logic [31:0]                                         I_CH_MAC_ROW_count,
    input  logic [31:0]                                         W_W_count,
    input  logic [31:0]                                         W_H_count,

    output logic                                                MAC_COL_isMAX,
    output logic                                                MAC_COL_isNext,

    output logic                                                w_prefetch_out,
    output logic [W_ADDR_BIT-1:0]                               w_addr_out,
    output logic                                                w_read_en_out
/*
    output logic                                                W_H_isMAX,
    output logic                                                W_H_isNext
*/
);

    // Wires
    // isMAX & isNext Wires
//    logic W_W_isMAX;
//    logic W_W_isNext;
    // Counter Wires
    logic [31:0] MAC_COL_count;
//    logic [31:0] W_W_count;
//    logic [31:0] W_H_count;

    // w_prefetch_out Register
    always_ff @( posedge clk ) begin : w_prefetch_out_reg
        if (rstn) begin
            w_prefetch_out <= w_start_in;
        end else begin
            w_prefetch_out <= 1'b0;
        end
    end

    // w_read_en_out Register /*******************NOT COMPLETED!!!*******************/
    always_ff @( posedge clk ) begin : w_read_en_out_reg
        if (rstn) begin
            if (w_start_in) begin
                w_read_en_out <= 1'b1;
            end else if (MAC_COL_isMAX) begin
                w_read_en_out <= 1'b0;
            end
        end else begin
            w_read_en_out <= 1'b0;
        end
    end

    // MAC_COL Counter
    Counter MAC_COL_Counter (
        .clk (clk),
        .rstn (rstn),
        .enable (w_read_en_out),
        .MAX (MAC_COL),
        .Count (MAC_COL_count),
        .isMAX (MAC_COL_isMAX),
        .isNext (MAC_COL_isNext)
    );
/*
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
*/
    always_comb begin : Address_Generator
        w_addr_out = MAC_COL_count*(OFMAP_CHANNEL_NUM/MAC_COL)
                   + O_CH_MAC_COL_count
                   + I_CH_MAC_ROW_count*(OFMAP_CHANNEL_NUM/MAC_COL)*MAC_ROW
                   + W_W_count*(OFMAP_CHANNEL_NUM/MAC_COL)*IFMAP_CHANNEL_NUM
                   + W_H_count*(OFMAP_CHANNEL_NUM/MAC_COL)*IFMAP_CHANNEL_NUM*WEIGHT_WIDTH;
    end

    /*always @(posedge clk) begin
        if (|W_W_count | |W_H_count) begin
            $display("W_W_count = %d W_H_Count = %d",W_W_count,W_H_count);
        end
    end*/

    /*always @(posedge clk) begin
        @(posedge I_CH_MAC_ROW_isNext)
        $display("W_W_Count = %1d w_addr_out = %1d",W_W_count,w_addr_out);
    end*/

endmodule
