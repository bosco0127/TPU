/////////////////////////////////////////////////////////////////////
//
// EE488(G) Project 3
// Title: Systolic.sv
//
/////////////////////////////////////////////////////////////////////
`include "MACArray\\MacArray.sv"
`include "MemoryController\\SinglePortRam.sv"
`include "MemoryController\\MemoryController.sv"
`include "FIFO\\FIFO_Q.sv"
`include "FIFO\\SIG_FIFO_Q.sv"
`include "FIFO\\TRI_FIFO_Q_UP.sv"
`include "FIFO\\TRI_FIFO_Q_DOWN.sv"
`include "RWRAM.sv"
 
`timescale 1 ns / 1 ps

//`define W_DEBUG
//`define IFMAP_DEBUG
//`define OFMAP_DEBUG

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

    logic signed [MAC_COL-1:0][W_BITWIDTH-1:0]      w_data;
    logic [W_ADDR_BIT-1:0]                          w_addr;
    logic                                           w_prefetch;
    logic                                           w_read_en;

    logic                                           w_Q_read_en;

    logic signed [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0]  ifmap_data;
    logic [IFMAP_ADDR_BIT-1:0]                      ifmap_addr;
    logic                                           ifmap_start;
    logic                                           ifmap_read_en;

    logic                                           ifmap_Q_read_en;

    logic signed [MAC_ROW-1:0][IFMAP_BITWIDTH-1:0]  Q_1_data;
    logic [MAC_ROW-1:0]                             Q_1_read_en;

    logic                                           mac_done;

    logic signed [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]  MAC_data;
    logic [MAC_COL-1:0]                             MAC_write_en;
    logic                                           MAC_write_en_neg;

    logic signed [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]  Q_2_data;
    logic [MAC_COL-1:0]                             Q_2_write_en;

    logic [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]         ofmap_wdata;
    logic [OFMAP_ADDR_BIT-1:0]                      ofmap_addr;
    logic                                           ofmap_wen;
    logic                                           ofmap_ready;
    logic                                           ofmap_write_done;

    logic signed [MAC_COL-1:0][OFMAP_BITWIDTH-1:0]  psum_data;
    logic [OFMAP_ADDR_BIT-1:0]                      psum_addr;
    logic [OFMAP_ADDR_BIT-1:0]                      psum_addr_mux;

    genvar i;

    logic need_to_modify_1;
    logic need_to_modify_2;

    // Need To Modify
    assign finish_out = need_to_modify_2;

    // your code here
    assign MAC_write_en_neg = ~(|MAC_write_en);
    MemoryController MemoryController (
        .clk                  (clk),
        .rstn                 (rstn),
        .start_in             (start_in),
        .ofmap_ready_in       (ofmap_ready),
        .MAC_write_en_neg     (MAC_write_en_neg & (~finish_out)),
        .w_prefetch_out       (w_prefetch),
        .w_addr_out           (w_addr),
        .w_read_en_out        (w_read_en),
        .ifmap_start_out      (ifmap_start),
        .ifmap_addr_out       (ifmap_addr),
        .ifmap_read_en_out    (ifmap_read_en),
        .mac_done_out         (mac_done),
        .ofmap_addr_out       (ofmap_addr),
        .ofmap_write_en_out   (ofmap_wen),
        .ofmap_write_done_out (ofmap_write_done)
    );

    SIG_FIFO_Q W_SIG_FIFO (
        .clk        (clk),
        .rstn       (rstn),
        .sig_in     (w_read_en),
        .sig_out    (w_Q_read_en)
    );

    SIG_FIFO_Q IFMAP_SIG_FIFO (
        .clk        (clk),
        .rstn       (rstn),
        .sig_in     (ifmap_read_en),
        .sig_out    (ifmap_Q_read_en)
    );

    TRI_FIFO_Q_UP #(
        .BIT_WIDTH  (IFMAP_BITWIDTH),
        .TRI_LENGTH (MAC_ROW)
    ) TRI_FIFO_Q_1 (
        .clk        (clk),
        .rstn       (rstn),
        .enable_in  ({MAC_ROW{ifmap_Q_read_en}}),
        .data_in    ({ifmap_data[0],ifmap_data[1],ifmap_data[2],ifmap_data[3]
                    ,ifmap_data[4],ifmap_data[5],ifmap_data[6],ifmap_data[7]
                    ,ifmap_data[8],ifmap_data[9],ifmap_data[10],ifmap_data[11]
                    ,ifmap_data[12],ifmap_data[13],ifmap_data[14],ifmap_data[15]}),  
        .enable_out (Q_1_read_en),
        .data_out   (Q_1_data)
    );

    MacArray MacArray (
        .clk             ( clk           ),
        .rstn            ( rstn          ),
        .w_prefetch_in   ( w_prefetch    ),
        .w_enable_in     ( w_Q_read_en   ),
        .w_data_in       ( w_data        ),
        .ifmap_start_in  ( ifmap_start   ),
        .ifmap_enable_in ( Q_1_read_en   ),
        .ifmap_data_in   ( Q_1_data      ),
        .ofmap_valid_out ( MAC_write_en  ),
        .ofmap_data_out  ( MAC_data      )
    );

    TRI_FIFO_Q_DOWN #(
        .BIT_WIDTH  (OFMAP_BITWIDTH),
        .TRI_LENGTH (MAC_COL)
    ) TRI_FIFO_Q_2 (
        .clk        (clk),
        .rstn       (rstn),
        .enable_in  (MAC_write_en),
        .data_in    (MAC_data),  
        .enable_out (Q_2_write_en),
        .data_out   (Q_2_data)
    );

    // Partial Sum
    assign ofmap_ready = &Q_2_write_en;
    assign psum_addr = ofmap_addr;
    generate
        for (i = 0; i < MAC_COL; i++) begin : ADD_gen
            assign ofmap_wdata[i] = psum_data[i] + Q_2_data[i];
        end
    endgenerate

    // verificate functionality
    assign test_output_out                      = psum_data;
    assign psum_addr_mux                        = test_check_in ? test_output_addr_in : psum_addr;

    always_comb begin
        if (rstn) begin
            if(mac_done) begin
                need_to_modify_1 = 1'b1;
            end
            if (need_to_modify_1 & ofmap_write_done) begin
                need_to_modify_2 = 1'b1;
            end            
        end else begin
            need_to_modify_1 = 1'b0;
            need_to_modify_2 = 1'b0;
        end
    end

    // Memory instances
    SinglePortRam #(
        .BIT_WIDTH      (IFMAP_BITWIDTH),
        .RAM_WIDTH      (MAC_ROW),
        .RAM_ADDR_BITS  (IFMAP_ADDR_BIT),
        .INIT_FILE_NAME (IFMAP_DATA_PATH)
    )
    i_mem
    (
        .addr_in                                (ifmap_addr),
        .clk                                    (clk),
        .wdata_in                               ({(IFMAP_BITWIDTH*MAC_ROW){1'b0}}),
        .we_in                                  (1'b0),
        .rdata_out                              (ifmap_data)
    );

    SinglePortRam #(
        .BIT_WIDTH      (W_BITWIDTH),
        .RAM_WIDTH      (MAC_COL),
        .RAM_ADDR_BITS  (W_ADDR_BIT),
        .INIT_FILE_NAME (WEIGHT_DATA_PATH)
    )
    w_mem
    (
        .addr_in                                (w_addr),
        .clk                                    (clk),
        .wdata_in                               ({(W_BITWIDTH*MAC_COL){1'b0}}),
        .we_in                                  (1'b0),
        .rdata_out                              (w_data)
    );

    RWRam #(
        .BIT_WIDTH      (OFMAP_BITWIDTH),
        .RAM_WIDTH      (MAC_COL),
        .RAM_ADDR_BITS  (OFMAP_ADDR_BIT),
        .INIT_FILE_NAME (OFMAP_DATA_PATH)
    )
    o_mem
    (
        .clock                                  (clk),            
        .data                                   (ofmap_wdata),            
        .rdaddress                              (psum_addr_mux),                
        .wraddress                              (ofmap_addr),                
        .wren                                   (ofmap_wen),            
        .q                                      (psum_data)
    );


    int number=0;
    /*always_ff @ (posedge clk) begin
        //if (MAC_write_en_neg) begin
            $display("****************");
            $display("MAC_write_en_neg: %b",MAC_write_en_neg);
        //end
    end*/

    /****WEIGHT DEBUG****/
    `ifdef W_DEBUG
    always_ff @ (posedge clk) begin
        if (w_read_en) begin
            $display("****************");
            $display("w_read_en");
            $display("w_addr: %1d",w_addr);
        end
        if (w_Q_read_en) begin
            $display("****************");
            $display("w_Q_read_en");
            $display("w_data  : %x",w_data);
        end
    end
    `endif

    /****IFMAP DEBUG****/
    `ifdef IFMAP_DEBUG
    always_ff @ (posedge clk) begin
        if (ifmap_read_en) begin
            $display("****************");
            $display("ifmap_read_en");
            $display("ifmap_addr: %1d",ifmap_addr);
        end
        if (ifmap_Q_read_en) begin
            $display("****************");
            $display("ifmap_Q_read_en");
            $display("ifmap_addr: %1d",ifmap_addr);
        end
        $display("%b",Q_1_read_en);
        $display("Q_1_data  : %x",Q_1_data);
        if (mac_done) begin
            $display("mac_done");
        end
    end
    `endif

    /****OFMAP DEBUG****/
    `ifdef OFMAP_DEBUG
    always_ff @ (posedge clk) begin
        $display("****************");
        $display("%b",Q_2_write_en);
        if (ofmap_ready) begin
            $display("ofmap_ready");
            $display("ofmap_addr: %1d",ofmap_addr);
            $display("Q_2_data   : %x",Q_2_data);
            $display("psum_data  : %x",psum_data);
            $display("ofmap_wdata: %x",ofmap_wdata);
        end
        if (ofmap_write_done) begin
            $display("ofmap_write_done %1d",number++);
            $stop();
        end
    end
    `endif

endmodule