/////////////////////////////////////////////////////////////////////
//
// EE878(B) Project 1
// Title: MacArray.sv
//
/////////////////////////////////////////////////////////////////////

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

    // Generation Variable
    genvar row_idx;
    genvar col_idx;

    // MAC array generation
    generate
        for (row_idx = 0; row_idx < MAC_ROW; row_idx = row_idx + 1) begin : MAC_Array_Row_gen
            for (col_idx = 0; col_idx < MAC_COL; col_idx = col_idx + 1) begin : MAC_Array_Col_gen
                if (row_idx == 0) begin
                    if (col_idx == 0) begin
                        MAC MAC_element00 (
                            .clk (clk),
                            .rstn (rstn),
                            .w_data_in (w_data_in[col_idx]),
                            .ifmap_data_in (ifmap_data_in[row_idx]),
                            .MAC_data_in (0),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end else begin
                        MAC MAC_element0X (
                            .clk (clk),
                            .rstn (rstn),
                            .w_data_in (w_data_in[col_idx]),
                            .ifmap_data_in (ifmap_internal_wire[row_idx][col_idx-1]),
                            .MAC_data_in (0),
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
                            .w_data_in (w_internal_wire[row_idx-1][col_idx]),
                            .ifmap_data_in (ifmap_data_in[row_idx]),
                            .MAC_data_in (0),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end else begin
                        MAC MAC_elementXX (
                            .clk (clk),
                            .rstn (rstn),
                            .w_data_in (w_internal_wire[row_idx-1][col_idx]),
                            .ifmap_data_in (ifmap_internal_wire[row_idx][col_idx-1]),
                            .MAC_data_in (0),
                            .w_data_out (w_internal_wire[row_idx][col_idx]),
                            .ifmap_data_out (ifmap_internal_wire[row_idx][col_idx]),
                            .MAC_data_out (ofmap_internal_wire[row_idx][col_idx])
                        );
                    end
                end
            end
        end
    endgenerate

endmodule