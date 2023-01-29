`timescale 1ns / 100ps

module MAC 
#(
    parameter IFMAP_BITWIDTH = 16,
    parameter W_BITWIDTH     = 8,
    parameter OFMAP_BITWIDTH = 32
)
(
    // Input Control Signals
    input logic signed clk, // Clock signal
    input logic signed rstn, // Reset Negative signal
    input logic w_prefetch_in,
    input logic w_enable_in,
    input logic ifmap_start_in,
    input logic ifmap_enable_in,
    input logic MAC_valid_in,

    // Input Datapath
    input logic signed [W_BITWIDTH-1:0] w_data_in, // input weight data
    input logic signed [IFMAP_BITWIDTH-1:0] ifmap_data_in, // input feature map data
    input logic signed [OFMAP_BITWIDTH-1:0] MAC_data_in, // input previous MAC result

    // Outuput Control Signal
    output logic ifmap_enable_out,
    output logic MAC_valid_out,

    // Output Datapath
    output logic signed [W_BITWIDTH-1:0] w_data_out, // output weight data
    output logic signed [IFMAP_BITWIDTH-1:0] ifmap_data_out, // output feature map data
    output logic signed [OFMAP_BITWIDTH-1:0] MAC_data_out // MAC result output

);

    // Multiplier & 32bit-Adder output
    logic signed [IFMAP_BITWIDTH-1:0] ifmap_wire;
    //logic signed [W_BITWIDTH-1:0] w_wire;
    logic signed [OFMAP_BITWIDTH-1:0] MAC_wire; 
    logic signed [OFMAP_BITWIDTH-1:0] MUL_OUT;
    logic signed [OFMAP_BITWIDTH-1:0] ADD_OUT;
    logic Cout;

    // MAC registers
    // Control
    logic ifmap_enable_reg;
    logic MAC_valid_reg;
    // Datapath
    logic signed [IFMAP_BITWIDTH-1:0] ifmap_reg;
    logic signed [W_BITWIDTH-1:0] w_reg;
    logic signed [OFMAP_BITWIDTH-1:0] MAC_reg;

    /********Weight Register Controller********/
    // Wire
    logic stalln_w;
    logic Trigger_w;
    logic clk_Trigger_w;
    logic w_stall_Trigger;
    logic D_w;
    // Register
    logic Q_w;

    // Wire Assignment
    assign Trigger_w = w_stall_Trigger | clk_Trigger_w;
    assign clk_Trigger_w = clk & (~rstn);
    assign w_stall_Trigger = rstn & ((w_prefetch_in & (~Q_w)) | (Q_w & (~stalln_w)));
    assign D_w = rstn & (~Q_w);
    assign stalln_w = Q_w & w_enable_in;

    always_ff @(posedge Trigger_w) begin : WRC
        Q_w <= D_w;
    end
    /********Weight Register Controller********/

    /********IFMAP Register Controller********/
    // Wire
    logic stalln_ifmap;
    logic Trigger_ifmap;
    logic clk_Trigger_ifmap;
    logic ifmap_stall_Trigger;
    logic D_ifmap;
    // Register
    logic Q_ifmap;

    // Wire Assignment
    assign Trigger_ifmap = ifmap_stall_Trigger | clk_Trigger_ifmap;
    assign clk_Trigger_ifmap = clk & (~rstn);
    assign ifmap_stall_Trigger = rstn & ((ifmap_start_in & (~Q_ifmap)) | (Q_ifmap & (~stalln_ifmap)));
    assign D_ifmap = rstn & (~Q_ifmap);
    assign stalln_ifmap = Q_ifmap & ifmap_enable_in;

    always_ff @(posedge Trigger_ifmap) begin : IRC
        Q_ifmap <= D_ifmap;
    end
    /********IFMAP Register Controller********/

    // Generate Value
    genvar idx;

    // Input feature map register
    always_ff @(posedge clk ) begin : IFMAP_REG
        if (rstn) begin
            ifmap_enable_reg <= ifmap_enable_in;
            if (stalln_ifmap) begin
                ifmap_reg <= ifmap_data_in;
            end else begin
                ifmap_reg <= ifmap_reg;
            end
        end else begin
            ifmap_reg <= {IFMAP_BITWIDTH{1'b0}};
            ifmap_enable_reg <= 1'b0;
        end
    end

    // Input weight register
    always_ff @(posedge clk ) begin : W_REG
        if (rstn) begin
            if (stalln_w) begin
                w_reg <= w_data_in;
            end else begin
                w_reg <= w_reg;
            end
        end else begin
            w_reg <= {W_BITWIDTH{1'b0}};
        end
    end

    // wire signed Assignment
    assign w_data_out = w_reg;
    assign ifmap_data_out = ifmap_reg;
    assign MAC_data_out = MAC_reg;
    assign ifmap_enable_out = ifmap_enable_reg;
    assign MAC_valid_out = MAC_valid_reg;

    // Multiplier
/*
    Multiplier_8bit MULTIPLIER (
        .A (ifmap_reg),
        .B (w_reg),
        .M (MUL_OUT)
    );
*/
    assign MUL_OUT = w_reg * ifmap_reg;

    // 32-bit Adder
/*
    Adder_32bit ADDER (
        .A (MUL_OUT),
        .B (MAC_data_in),
        .Cin (1'b0),
        .S (ADD_OUT),
        .Cout (Cout)
    );
*/
    assign ADD_OUT = MUL_OUT + MAC_data_in;
    
    // Output MAC result register
    always_ff @(posedge clk ) begin : OFMAP_REG
        if (rstn) begin
            MAC_reg <= ADD_OUT;
            MAC_valid_reg <= ifmap_enable_reg & MAC_valid_in;
        end else begin
            MAC_reg <= {OFMAP_BITWIDTH{1'b0}};
            MAC_valid_reg <= 1'b0;
        end
    end

    /*always_ff @ (posedge clk) begin
        #1
        $display("w_data_in =%d\tifmap_data_in =%d\tMAC_data_in =%d",w_data_in,ifmap_data_in,MAC_data_in);
        $display("w_reg     =%d\tifmap_reg     =%d\tADD_OUT     =%d",w_reg,ifmap_reg,ADD_OUT);
        $display("w_data_out=%d\tifmap_data_out=%d\tMAC_data_out=%d",w_data_out,ifmap_data_out,MAC_data_out);
    end*/

endmodule