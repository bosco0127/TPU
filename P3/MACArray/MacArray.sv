/////////////////////////////////////////////////////////////////////
//
// EE878(B) Project 1
// Title: MacArray.sv
//
/////////////////////////////////////////////////////////////////////
`include "MAC.sv"

//`define DEBUG
//`define DEBUG_BY_VALUE

`timescale 1 ns / 1 ps

module MacArray
#(
    parameter MAC_ROW                                                   = 16,
    parameter MAC_COL                                                   = 16,
    parameter IFMAP_BITWIDTH                                            = 16,
    parameter W_BITWIDTH                                                = 8,
    parameter OFMAP_BITWIDTH                                            = 32
)
(
    input  logic                                                        clk,
    input  logic                                                        rstn,

    input  logic                                                        w_prefetch_in,
    input  logic                                                        w_enable_in,
    input  logic [MAC_COL-1:0][W_BITWIDTH-1:0]                          w_data_in,

    input  logic                                                        ifmap_start_in,
    input  logic [MAC_ROW-1:0]                                          ifmap_enable_in,
    input  logic [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0]                      ifmap_data_in,

    output logic [MAC_COL-1:0]                                          ofmap_valid_out,
    output logic [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]                      ofmap_data_out
);

    // your code here
    
    // Internal Wire
    logic [W_BITWIDTH]     w_internal_wire     [MAC_ROW-1:0][MAC_COL-1:0];
    logic [IFMAP_BITWIDTH] ifmap_internal_wire [MAC_ROW-1:0][MAC_COL-1:0];
    logic [OFMAP_BITWIDTH] ofmap_internal_wire [MAC_ROW-1:0][MAC_COL-1:0];
    logic ifmap_internal_enable_wire           [MAC_ROW-1:0][MAC_COL-1:0];
    logic ofmap_internal_valid_wire            [MAC_ROW-1:0][MAC_COL-1:0];

    // Generation Variable
    genvar row_idx;
    genvar col_idx;

    // Ofmap_valid_out wire assignment
    generate
        for (col_idx = 0; col_idx < MAC_COL; col_idx = col_idx + 1) begin : ofmap_valid_out_gen
            assign ofmap_valid_out[col_idx] = ofmap_internal_valid_wire[MAC_ROW-1][col_idx];
            assign ofmap_data_out[col_idx]  = ofmap_internal_wire[MAC_ROW-1][col_idx];
        end
    endgenerate

    // MAC array generation
    generate
        for (row_idx = 0; row_idx < MAC_ROW; row_idx = row_idx + 1) begin : MAC_Array_Row_gen
            for (col_idx = 0; col_idx < MAC_COL; col_idx = col_idx + 1) begin : MAC_Array_Col_gen
                if (row_idx == 0) begin
                    if (col_idx == 0) begin
                        MAC MAC_element00 (
                            .clk (clk),
                            .rstn (rstn),
                            .w_prefetch_in (w_prefetch_in),
                            .w_enable_in (w_enable_in),
                            .ifmap_start_in (ifmap_start_in),
                            .ifmap_enable_in (ifmap_enable_in[row_idx]),
                            .MAC_valid_in (1'b1),
                            .w_data_in (w_data_in[col_idx]),
                            .ifmap_data_in (ifmap_data_in[row_idx]),
                            .MAC_data_in (0),
                            .ifmap_enable_out (ifmap_internal_enable_wire[row_idx][col_idx]),
                            .MAC_valid_out (ofmap_internal_valid_wire[row_idx][col_idx]),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end else begin
                        MAC MAC_element0X (
                            .clk (clk),
                            .rstn (rstn),
                            .w_prefetch_in (w_prefetch_in),
                            .w_enable_in (w_enable_in),
                            .ifmap_start_in (ifmap_start_in),
                            .ifmap_enable_in (ifmap_internal_enable_wire[row_idx][col_idx-1]),
                            .MAC_valid_in (1'b1),
                            .w_data_in (w_data_in[col_idx]),
                            .ifmap_data_in (ifmap_internal_wire[row_idx][col_idx-1]),
                            .MAC_data_in (0),
                            .ifmap_enable_out (ifmap_internal_enable_wire[row_idx][col_idx]),
                            .MAC_valid_out (ofmap_internal_valid_wire[row_idx][col_idx]),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end
                end else begin
                    if (col_idx == 0) begin
                        MAC MAC_elementX0 (
                            .clk (clk),
                            .rstn (rstn),
                            .w_prefetch_in (w_prefetch_in),
                            .w_enable_in (w_enable_in),
                            .ifmap_start_in (ifmap_start_in),
                            .ifmap_enable_in (ifmap_enable_in[row_idx]),
                            .MAC_valid_in (ofmap_internal_valid_wire[row_idx-1][col_idx]),
                            .w_data_in (w_internal_wire[row_idx-1][col_idx]),
                            .ifmap_data_in (ifmap_data_in[row_idx]),
                            .MAC_data_in (ofmap_internal_wire[row_idx-1][col_idx]),
                            .ifmap_enable_out (ifmap_internal_enable_wire[row_idx][col_idx]),
                            .MAC_valid_out (ofmap_internal_valid_wire[row_idx][col_idx]),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end else begin
                        MAC MAC_elementXX (
                            .clk (clk),
                            .rstn (rstn),
                            .w_prefetch_in (w_prefetch_in),
                            .w_enable_in (w_enable_in),
                            .ifmap_start_in (ifmap_start_in),
                            .ifmap_enable_in (ifmap_internal_enable_wire[row_idx][col_idx-1]),
                            .MAC_valid_in (ofmap_internal_valid_wire[row_idx-1][col_idx]),
                            .w_data_in (w_internal_wire[row_idx-1][col_idx]),
                            .ifmap_data_in (ifmap_internal_wire[row_idx][col_idx-1]),
                            .MAC_data_in (ofmap_internal_wire[row_idx-1][col_idx]),
                            .ifmap_enable_out (ifmap_internal_enable_wire[row_idx][col_idx]),
                            .MAC_valid_out (ofmap_internal_valid_wire[row_idx][col_idx]),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end
                end
            end
        end
    endgenerate

    int i,j;
    `ifdef DEBUG
    always_ff @ (posedge clk) begin
        if (|ifmap_enable_in | |ofmap_valid_out) begin
            $display("***********************************");
            for (i = 0; i < MAC_ROW; i++) begin
                $display("%b %b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b %b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b",ifmap_enable_in[i],ifmap_internal_enable_wire[i][0],ifmap_internal_enable_wire[i][1]
                ,ifmap_internal_enable_wire[i][2],ifmap_internal_enable_wire[i][3],ifmap_internal_enable_wire[i][4],ifmap_internal_enable_wire[i][5]
                ,ifmap_internal_enable_wire[i][6],ifmap_internal_enable_wire[i][7],ifmap_internal_enable_wire[i][8],ifmap_internal_enable_wire[i][9]
                ,ifmap_internal_enable_wire[i][10],ifmap_internal_enable_wire[i][11],ifmap_internal_enable_wire[i][12],ifmap_internal_enable_wire[i][13]
                ,ifmap_internal_enable_wire[i][14],ifmap_internal_enable_wire[i][15],
                ofmap_internal_valid_wire[i][0],ofmap_internal_valid_wire[i][1],ofmap_internal_valid_wire[i][2],ofmap_internal_valid_wire[i][3]
                ,ofmap_internal_valid_wire[i][4],ofmap_internal_valid_wire[i][5],ofmap_internal_valid_wire[i][6],ofmap_internal_valid_wire[i][7]
                ,ofmap_internal_valid_wire[i][8],ofmap_internal_valid_wire[i][9],ofmap_internal_valid_wire[i][10],ofmap_internal_valid_wire[i][11]
                ,ofmap_internal_valid_wire[i][12],ofmap_internal_valid_wire[i][13],ofmap_internal_valid_wire[i][14],ofmap_internal_valid_wire[i][15]);
            end
        end
    end
    `endif

    `ifdef DEBUG_BY_VALUE
    always_ff @ (posedge clk) begin
        if (w_enable_in |ifmap_enable_in | |ofmap_valid_out) begin
            $display("***WEIGHT***********************************************************************************************************************************");
            for (i = 0; i < MAC_ROW; i++) begin
                $display("%8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x",
                w_internal_wire[i][0],w_internal_wire[i][1],w_internal_wire[i][2],w_internal_wire[i][3]
                ,w_internal_wire[i][4],w_internal_wire[i][5],w_internal_wire[i][6],w_internal_wire[i][7]
                ,w_internal_wire[i][8],w_internal_wire[i][9],w_internal_wire[i][10],w_internal_wire[i][11]
                ,w_internal_wire[i][12],w_internal_wire[i][13],w_internal_wire[i][14],w_internal_wire[i][15]);
            end
            $display("***IFMAP************************************************************************************************************************************");
            for (i = 0; i < MAC_ROW; i++) begin
                $display("%8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x",
                ifmap_internal_wire[i][0],ifmap_internal_wire[i][1],ifmap_internal_wire[i][2],ifmap_internal_wire[i][3]
                ,ifmap_internal_wire[i][4],ifmap_internal_wire[i][5],ifmap_internal_wire[i][6],ifmap_internal_wire[i][7]
                ,ifmap_internal_wire[i][8],ifmap_internal_wire[i][9],ifmap_internal_wire[i][10],ifmap_internal_wire[i][11]
                ,ifmap_internal_wire[i][12],ifmap_internal_wire[i][13],ifmap_internal_wire[i][14],ifmap_internal_wire[i][15]);
            end
            $display("***OFMAP************************************************************************************************************************************");
            for (i = 0; i < MAC_ROW; i++) begin
                $display("%8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x %8x",
                ofmap_internal_wire[i][0],ofmap_internal_wire[i][1],ofmap_internal_wire[i][2],ofmap_internal_wire[i][3]
                ,ofmap_internal_wire[i][4],ofmap_internal_wire[i][5],ofmap_internal_wire[i][6],ofmap_internal_wire[i][7]
                ,ofmap_internal_wire[i][8],ofmap_internal_wire[i][9],ofmap_internal_wire[i][10],ofmap_internal_wire[i][11]
                ,ofmap_internal_wire[i][12],ofmap_internal_wire[i][13],ofmap_internal_wire[i][14],ofmap_internal_wire[i][15]);
            end
        end
    end
    `endif

endmodule