`timescale 1ns / 1ps

module FIFO_Q
#(
    parameter DATA_WIDTH                = 32,
    parameter FIFO_DEPTH                = 16
)   
(   
    input  logic                         clk,
    input  logic                         rstn,
    input  logic                         enable_in,         // Input enable signal
    input  logic  [DATA_WIDTH-1:0]       data_in,          // Input data
    output logic                         enable_out,         // Input enable signal
    output logic  [DATA_WIDTH-1:0]       data_out          // Output data
);

    logic [DATA_WIDTH:0]              mem[FIFO_DEPTH-1:0];

    int i;

    assign data_out = mem[FIFO_DEPTH-1][DATA_WIDTH-1:0];
    assign enable_out = mem[FIFO_DEPTH-1][DATA_WIDTH];

    always_ff @(posedge clk) begin
        if(~rstn) begin
            for (i = 0; i < FIFO_DEPTH; i++) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else begin
            for (i = 0; i < FIFO_DEPTH; i++) begin
                if (i == 0) begin
                    mem[i] <= {enable_in,data_in};
                end else begin
                    mem[i] <= mem[i-1];
                end
            end
        end
    end

endmodule