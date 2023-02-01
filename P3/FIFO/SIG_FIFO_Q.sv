`timescale 1ns / 1ps

module SIG_FIFO_Q
#(
    parameter DATA_WIDTH                = 1,
    parameter FIFO_DEPTH                = 1
)   
(   
    input  logic                         clk,
    input  logic                         rstn,
    input  logic  [DATA_WIDTH-1:0]       sig_in,          // Input data
    output logic  [DATA_WIDTH-1:0]       sig_out          // Output data
);

    logic [DATA_WIDTH-1:0]              mem[FIFO_DEPTH-1:0];

    int i;

    assign sig_out = mem[FIFO_DEPTH-1][DATA_WIDTH-1:0];

    always_ff @(posedge clk) begin
        if(~rstn) begin
            for (i = 0; i < FIFO_DEPTH; i++) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else begin
            for (i = FIFO_DEPTH-1; i >= 0; i--) begin
                if (i == 0) begin
                    mem[i] <= sig_in;
                end else begin
                    mem[i] <= mem[i-1];
                end
            end
        end
    end

endmodule