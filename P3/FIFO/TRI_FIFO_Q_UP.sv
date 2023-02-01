`timescale 1ns / 1ps

module TRI_FIFO_Q_UP
#(
    parameter BIT_WIDTH             = 32,
    parameter TRI_LENGTH            = 16
)   
(   
    input  logic                                     clk,
    input  logic                                     rstn,
    input  logic  [TRI_LENGTH-1:0]                   enable_in,        // Input enable signal
    input  logic  [TRI_LENGTH-1:0][BIT_WIDTH-1:0]    data_in,          // Input data
    output logic  [TRI_LENGTH-1:0]                   enable_out,       // Input enable signal
    output logic  [TRI_LENGTH-1:0][BIT_WIDTH-1:0]    data_out          // Output data
);

    genvar i;

    generate
        for (i = 0; i < TRI_LENGTH; i++) begin : TRI_FIFO_gen
            FIFO_Q #(
                .DATA_WIDTH (BIT_WIDTH),
                .FIFO_DEPTH (i+1)
            ) FIFO (
                .clk (clk),
                .rstn (rstn),
                .enable_in (enable_in[i]), 
                .data_in (data_in[i]),   
                .enable_out (enable_out[i]),
                .data_out (data_out[i]) 
            );
        end
    endgenerate

endmodule