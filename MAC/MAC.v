`timescale 1ns / 100ps

module MAC 
#(
    parameter IFMAP_BITWIDTH = 16,
    parameter W_BITWIDTH     = 8,
    parameter OFMAP_BITWIDTH = 32
)
(
    input wire signed clk, // Clock signal
    input wire signed rstn, // Reset Negative signal

    input wire signed [W_BITWIDTH-1:0] w_data_in, // input weight data
    input wire signed [IFMAP_BITWIDTH-1:0] ifmap_data_in, // input feature map data
    input wire signed [OFMAP_BITWIDTH-1:0] MAC_data_in, // input previous MAC result

    output wire signed [W_BITWIDTH-1:0] w_data_out, // output weight data
    output wire signed [IFMAP_BITWIDTH-1:0] ifmap_data_out, // output feature map data
    output wire signed [OFMAP_BITWIDTH-1:0] MAC_data_out // MAC result output
);

    // Multiplier & 32bit-Adder output
    wire signed [IFMAP_BITWIDTH-1:0] ifmap_wire;
    wire signed [W_BITWIDTH-1:0] w_wire;
    wire signed [OFMAP_BITWIDTH-1:0] MAC_wire; 
    wire signed [OFMAP_BITWIDTH-1:0] MUL_OUT;
    wire signed [OFMAP_BITWIDTH-1:0] ADD_OUT;
    wire signed Cout;

    // MAC registers
    reg signed [IFMAP_BITWIDTH-1:0] ifmap_reg;
    reg signed [W_BITWIDTH-1:0] w_reg;
    reg signed [OFMAP_BITWIDTH-1:0] MAC_reg;

    // Generate Value
    genvar idx;

    // RESET wire signed Generation
    generate
        for (idx = 0; idx < IFMAP_BITWIDTH; idx = idx + 1) begin : ifmap_rst_gen
            assign ifmap_wire[idx] = rstn & ifmap_data_in[idx];
        end
    endgenerate

    generate
        for (idx = 0; idx < W_BITWIDTH; idx = idx + 1) begin : w_rst_gen
            assign w_wire[idx] = rstn & w_data_in[idx];
        end
    endgenerate

    generate
        for (idx = 0; idx < OFMAP_BITWIDTH; idx = idx + 1) begin : MAC_rst_gen
            assign MAC_wire[idx] = rstn & ADD_OUT[idx];
        end
    endgenerate

    // Input feature map register
    always @(posedge clk ) begin
        ifmap_reg <= ifmap_wire;
    end

    // Input weight register
    always @(posedge clk ) begin
        w_reg <= w_wire;
    end

    // wire signed Assignment
    assign w_data_out = w_reg;
    assign ifmap_data_out = ifmap_reg;
    assign MAC_data_out = MAC_reg;

    // Multiplier
    Multiplier_8bit MULTIPLIER (
        .A (ifmap_reg),
        .B (w_reg),
        .M (MUL_OUT)
    );

    // 32-bit Adder
    Adder_32bit ADDER (
        .A (MUL_OUT),
        .B (MAC_data_in),
        .Cin (1'b0),
        .S (ADD_OUT),
        .Cout (Cout)
    );
    
    // Output MAC result register
    always @(posedge clk ) begin
        MAC_reg <= MAC_wire;
    end

    /*always @ (posedge clk) begin
        #1
        $display("w_data_in =%d\tifmap_data_in =%d\tMAC_data_in =%d",w_data_in,ifmap_data_in,MAC_data_in);
        $display("w_reg     =%d\tifmap_reg     =%d\tADD_OUT     =%d",w_reg,ifmap_reg,ADD_OUT);
        $display("w_data_out=%d\tifmap_data_out=%d\tMAC_data_out=%d",w_data_out,ifmap_data_out,MAC_data_out);
    end*/

endmodule